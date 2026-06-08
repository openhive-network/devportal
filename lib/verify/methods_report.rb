require 'fileutils'
require 'json'
require 'open3'
require 'pathname'
require 'set'
require 'time'
require 'yaml'

module Verify
  class MethodsReport
    CLASSIFICATIONS = %w[
      verified
      mismatch
      docs_only
      source_only
      obsolete_in_docs_present_in_source
      insufficient_source
    ].freeze

    IGNORED_HIVE_API_DIRS = %w[
      api_generation
      documentation
      test_api
    ].freeze

    attr_reader :project_root, :hive_root, :reports_dir

    def initialize(project_root:, hive_root: nil, reports_dir: nil)
      @project_root = File.expand_path(project_root)
      @hive_root = File.expand_path(hive_root || File.join(@project_root, '..', 'hive'), @project_root)
      @reports_dir = File.expand_path(reports_dir || File.join(@project_root, 'reports'), @project_root)
    end

    def write
      report = build
      FileUtils.mkdir_p(reports_dir)
      json_path = File.join(reports_dir, 'verified-methods.json')
      md_path = File.join(reports_dir, 'verified-methods.md')

      File.write(json_path, "#{JSON.pretty_generate(report)}\n")
      File.write(md_path, render_markdown(report))

      {
        json: json_path,
        markdown: md_path,
        report: report
      }
    end

    def build
      validate_hive_source!

      docs = load_documented_methods
      openapi = OpenapiSource.new(openapi_path, project_root: project_root).load
      cpp = CppSource.new(apis_root, project_root: project_root).load

      all_names = (docs.keys.to_set | openapi[:methods].keys.to_set | cpp[:methods].keys.to_set).to_a.sort
      method_reports = all_names.map do |name|
        compare_method(name, docs[name], openapi[:methods][name], cpp[:methods][name])
      end

      namespaces = namespace_summary(method_reports)

      {
        metadata: metadata,
        summary: summary(method_reports, namespaces),
        namespaces: namespaces,
        methods: method_reports
      }
    end

    def compare_method(name, doc, openapi_method, cpp_method)
      namespace, method_name = name.split('.', 2)
      doc_status = doc ? doc[:status] : 'missing'
      source_present = !!openapi_method || !!cpp_method
      notes = []

      openapi_params = openapi_method && openapi_method[:request_keys]
      cpp_params = cpp_method && cpp_method[:args_keys]
      openapi_response = openapi_method && openapi_method[:response_keys]
      cpp_response = cpp_method && cpp_method[:return_keys]
      doc_params = doc && doc[:parameter_keys]
      doc_response = doc && doc[:response_keys]

      classification =
        if doc.nil?
          'source_only'
        elsif doc[:obsolete] && source_present
          'obsolete_in_docs_present_in_source'
        elsif !source_present
          'docs_only'
        else
          compare_fields(
            name: name,
            doc_params: doc_params,
            openapi_params: openapi_params,
            cpp_params: cpp_params,
            doc_response: doc_response,
            openapi_response: openapi_response,
            cpp_response: cpp_response,
            notes: notes
          )
        end

      notes << 'documented obsolete but still present in source' if classification == 'obsolete_in_docs_present_in_source'
      notes << 'documented method was not found in OpenAPI or C++ source' if classification == 'docs_only'
      notes << 'source method is absent from devportal docs' if classification == 'source_only'

      {
        name: name,
        namespace: namespace,
        method: method_name,
        doc_status: doc_status,
        classification: classification,
        documented: !!doc,
        openapi: source_details(openapi_method, openapi_params, openapi_response),
        cpp: source_details(cpp_method, cpp_params, cpp_response),
        documented_fields: {
          parameters: doc_params || [],
          response: doc_response || []
        },
        notes: notes.uniq,
        source_references: source_references(openapi_method, cpp_method)
      }
    end

    def render_markdown(report)
      lines = []
      meta = report.fetch(:metadata)

      lines << '# Verified Methods'
      lines << ''
      lines << "Generated: `#{meta.fetch(:generated_at)}`"
      lines << "Devportal SHA: `#{meta.fetch(:devportal_git_sha)}`"
      lines << "Hive SHA: `#{meta.fetch(:hive_git_sha)}`"
      lines << ''
      lines << '## Summary'
      lines << ''
      report.fetch(:summary).fetch(:classifications).each do |classification, count|
        lines << "- `#{classification}`: #{count}"
      end
      lines << "- namespaces: #{report.fetch(:summary).fetch(:namespace_count)}"
      lines << "- methods: #{report.fetch(:summary).fetch(:method_count)}"
      lines << ''

      report.fetch(:namespaces).each do |namespace|
        lines << "## #{namespace.fetch(:name)}"
        lines << ''
        lines << "| Method | Docs | OpenAPI | C++ | Result | Notes |"
        lines << "| --- | --- | --- | --- | --- | --- |"

        report.fetch(:methods).select { |method| method.fetch(:namespace) == namespace.fetch(:name) }.each do |method|
          lines << [
            method.fetch(:method),
            method.fetch(:doc_status),
            yes_no(method.dig(:openapi, :present)),
            yes_no(method.dig(:cpp, :present)),
            "`#{method.fetch(:classification)}`",
            markdown_notes(method.fetch(:notes))
          ].join(' | ').prepend('| ').concat(' |')
        end
        lines << ''
      end

      source_only = report.fetch(:methods).select { |method| method.fetch(:classification) == 'source_only' }
      unless source_only.empty?
        lines << '## Source-Only Methods'
        lines << ''
        source_only.group_by { |method| method.fetch(:namespace) }.sort.each do |namespace, methods|
          lines << "- `#{namespace}`: #{methods.map { |method| "`#{method.fetch(:method)}`" }.join(', ')}"
        end
        lines << ''
      end

      "#{lines.join("\n")}\n"
    end

    private

    def compare_fields(name:, doc_params:, openapi_params:, cpp_params:, doc_response:, openapi_response:, cpp_response:, notes:)
      mismatch = false
      known_source = false

      [
        ['parameter', doc_params, openapi_params, 'OpenAPI'],
        ['parameter', doc_params, cpp_params, 'C++'],
        ['response', doc_response, openapi_response, 'OpenAPI'],
        ['response', doc_response, cpp_response, 'C++']
      ].each do |kind, docs, source, source_name|
        next unless source

        known_source = true
        missing = source - docs
        extra = docs - source
        next if missing.empty? && extra.empty?

        mismatch = true
        notes << "#{source_name} #{kind} fields differ; source-only: #{list_or_none(missing)}; docs-only: #{list_or_none(extra)}"
      end

      if openapi_params && cpp_params && openapi_params != cpp_params
        mismatch = true
        notes << "OpenAPI and C++ parameter fields differ; OpenAPI: #{openapi_params.join(', ')}; C++: #{cpp_params.join(', ')}"
      end

      if openapi_response && cpp_response && openapi_response != cpp_response
        mismatch = true
        notes << "OpenAPI and C++ response fields differ; OpenAPI: #{openapi_response.join(', ')}; C++: #{cpp_response.join(', ')}"
      end

      return 'mismatch' if mismatch
      return 'verified' if known_source

      notes << "source method exists but schema fields could not be extracted for #{name}"
      'insufficient_source'
    end

    def source_details(method, params, response)
      {
        present: !!method,
        parameter_fields: params || [],
        response_fields: response || []
      }
    end

    def source_references(openapi_method, cpp_method)
      refs = []
      refs.concat(openapi_method[:source_references]) if openapi_method
      refs.concat(cpp_method[:source_references]) if cpp_method
      refs.uniq
    end

    def load_documented_methods
      methods = {}
      Dir[File.join(project_root, '_data', 'apidefinitions', '*.yml')].sort.each do |file_name|
        yml = YAML.load_file(file_name)
        Array(yml).each do |section|
          Array(section['methods']).each do |method|
            name = method['api_method']
            next unless name

            methods[name] = {
              name: name,
              file: relative_path(file_name),
              status: documented_status(method),
              obsolete: method['removed'] || method['status'].to_s == 'obsolete',
              parameter_keys: json_top_level_keys(method['parameter_json']),
              response_keys: json_top_level_keys(method['expected_response_json'])
            }
          end
        end
      end
      methods
    end

    def documented_status(method)
      return 'removed' if method['removed']
      return 'obsolete' if method['status'].to_s == 'obsolete'

      'active'
    end

    def json_top_level_keys(value)
      return [] if value.nil? || value.to_s.strip.empty?

      parsed = JSON.parse(value.to_s)
      return parsed.keys.sort if parsed.is_a?(Hash)

      []
    rescue JSON::ParserError
      []
    end

    def namespace_summary(method_reports)
      method_reports.group_by { |method| method[:namespace] }.sort.map do |namespace, methods|
        {
          name: namespace,
          method_count: methods.length,
          classifications: classification_counts(methods)
        }
      end
    end

    def summary(method_reports, namespaces)
      {
        method_count: method_reports.length,
        namespace_count: namespaces.length,
        classifications: classification_counts(method_reports)
      }
    end

    def classification_counts(methods)
      counts = CLASSIFICATIONS.to_h { |classification| [classification, 0] }
      methods.each { |method| counts[method[:classification]] += 1 }
      counts
    end

    def metadata
      {
        generated_at: Time.now.utc.iso8601,
        devportal_git_sha: git_sha(project_root),
        hive_git_sha: git_sha(hive_root),
        hive_root: relative_path(hive_root),
        openapi_path: relative_path(openapi_path)
      }
    end

    def git_sha(root)
      stdout, _stderr, status = Open3.capture3('git', 'rev-parse', 'HEAD', chdir: root)
      status.success? ? stdout.strip : 'unknown'
    end

    def openapi_path
      File.join(apis_root, 'documentation', 'openapi.json')
    end

    def apis_root
      File.join(hive_root, 'libraries', 'plugins', 'apis')
    end

    def validate_hive_source!
      fail "Hive source directory not found: #{hive_root}" unless Dir.exist?(hive_root)
      fail "Hive API source directory not found: #{apis_root}" unless Dir.exist?(apis_root)
      fail "Hive OpenAPI file not found: #{openapi_path}" unless File.exist?(openapi_path)
    end

    def relative_path(path)
      Pathname.new(path).relative_path_from(Pathname.new(project_root)).to_s
    rescue ArgumentError
      path
    end

    def yes_no(value)
      value ? 'yes' : 'no'
    end

    def markdown_notes(notes)
      return '' if notes.empty?

      notes.join('<br>').gsub('|', '\\|')
    end

    def list_or_none(values)
      values.empty? ? 'none' : values.join(', ')
    end
  end

  class OpenapiSource
    def initialize(path, project_root:)
      @path = path
      @project_root = project_root
    end

    def load
      json = JSON.parse(File.read(@path))
      schemas = json.fetch('components', {}).fetch('schemas', {})
      lines = File.readlines(@path)

      methods = json.fetch('paths', {}).to_h do |name, path_data|
        operation = path_data.fetch('post', {})
        request_schema = schema_for(operation.dig('requestBody', 'content', 'application/json', 'schema'), schemas)
        response_schema = schema_for(operation.dig('responses', '200', 'content', 'application/json', 'schema'), schemas)

        [
          name,
          {
            request_keys: property_keys(request_schema),
            response_keys: property_keys(response_schema),
            source_references: source_references(name, lines)
          }
        ]
      end

      { methods: methods }
    end

    private

    def schema_for(schema, schemas)
      resolve_schema(schema, schemas)
    end

    def resolve_schema(schema, schemas, seen = Set.new)
      return nil unless schema

      ref = schema['$ref']
      if ref
        key = ref.split('/').last
        return nil if seen.include?(key)

        seen << key
        return resolve_schema(schemas[key], schemas, seen)
      end

      return schema unless schema['allOf']

      schema['allOf'].each_with_object({ 'type' => 'object', 'properties' => {} }) do |item, merged|
        resolved = resolve_schema(item, schemas, seen.dup)
        next unless resolved

        merged['properties'].merge!(resolved.fetch('properties', {}))
      end
    end

    def property_keys(schema)
      return [] unless schema
      return [] if schema.empty?

      properties = schema.fetch('properties', {})
      return properties.keys.sort unless properties.empty?

      nil
    end

    def source_references(name, lines)
      index = lines.index { |line| line.include?("\"#{name}\"") }
      return [] unless index

      ["#{relative_path(@path)}:#{index + 1}"]
    end

    def relative_path(path)
      Pathname.new(path).relative_path_from(Pathname.new(@project_root)).to_s
    rescue ArgumentError
      path
    end
  end

  class CppSource
    def initialize(apis_root, project_root:)
      @apis_root = apis_root
      @project_root = project_root
    end

    def load
      methods = {}

      api_dirs.each do |api_dir|
        api_name = File.basename(api_dir)
        files = Dir[File.join(api_dir, '**', '*.{hpp,cpp}')].sort
        reflections, aliases = reflected_fields(files)
        method_names = Set.new
        references = Hash.new { |hash, key| hash[key] = [] }

        files.each do |file_name|
          lines = File.readlines(file_name)
          text = lines.join

          text.scan(/(?:DECLARE_API|DECLARE_API_IMPL)\s*\((.*?)\)\s*(?:;|\{|private:|public:|FC_REFLECT|\z)/m) do |match|
            match.first.scan(/\(([a-zA-Z_][a-zA-Z0-9_]*)\)/) do |method_match|
              method_names << method_match.first
            end
          end

          text.scan(/DEFINE_API_IMPL\s*\([^,]+,\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)/) do |match|
            method_names << match.first
          end

          method_names.each do |method_name|
            lines.each_with_index do |line, index|
              next unless line.include?(method_name) && line =~ /(DECLARE_API|DECLARE_API_IMPL|DEFINE_API_IMPL)/

              references[method_name] << "#{relative_path(file_name)}:#{index + 1}"
            end
          end
        end

        method_names.each do |method_name|
          name = "#{api_name}.#{method_name}"
          methods[name] = {
            args_keys: keys_for("#{method_name}_args", reflections, aliases),
            return_keys: keys_for("#{method_name}_return", reflections, aliases),
            source_references: references[method_name].uniq
          }
        end
      end

      { methods: methods }
    end

    private

    def api_dirs
      Dir[File.join(@apis_root, '*')].select do |path|
        File.directory?(path) && !MethodsReport::IGNORED_HIVE_API_DIRS.include?(File.basename(path))
      end.sort
    end

    def reflected_fields(files)
      reflections = {}
      aliases = {}

      files.each do |file_name|
        lines = File.readlines(file_name)
        lines.each_with_index do |line, index|
          line.scan(/typedef\s+([a-zA-Z_][a-zA-Z0-9_:<>]*)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;/) do |target, name|
            aliases[name] = target.split('::').last
          end

          next unless line.include?('FC_REFLECT(')

          block = [line]
          cursor = index + 1
          until block.join.include?(')') && block.join.count('(') <= block.join.count(')')
            break if cursor >= lines.length

            block << lines[cursor]
            cursor += 1
          end

          text = block.join
          match = text.match(/FC_REFLECT\s*\(\s*(?:[a-zA-Z_][a-zA-Z0-9_]*::)*([a-zA-Z_][a-zA-Z0-9_]*)\s*,(.*)\)\s*$/m)
          next unless match

          reflections[match[1]] = match[2].scan(/\(([a-zA-Z_][a-zA-Z0-9_]*)\)/).flatten.sort
        end
      end

      [reflections, aliases]
    end

    def keys_for(name, reflections, aliases)
      resolved = resolve_alias(name, aliases)
      return [] if resolved == 'void_type'

      reflections[resolved]
    end

    def resolve_alias(name, aliases)
      seen = Set.new
      current = name
      while aliases[current] && !seen.include?(current)
        seen << current
        current = aliases[current]
      end
      current
    end

    def relative_path(path)
      Pathname.new(path).relative_path_from(Pathname.new(@project_root)).to_s
    rescue ArgumentError
      path
    end
  end
end
