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
      source_disagreement
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
      openapi_param_shape = openapi_method && openapi_method[:request_shape]
      openapi_response_shape = openapi_method && openapi_method[:response_shape]
      cpp_param_shape = cpp_method && cpp_method[:args_shape]
      cpp_response_shape = cpp_method && cpp_method[:return_shape]
      doc_param_shape = doc && doc[:parameter_shape]
      doc_response_shape = doc && doc[:response_shape]
      doc_param_value = doc && doc[:parameter_value]
      doc_response_value = doc && doc[:response_value]
      openapi_param_errors = validation_errors(openapi_method, :request_validator, doc_param_value)
      openapi_response_errors = validation_errors(openapi_method, :response_validator, doc_response_value)
      cpp_param_errors = validate_constraints(doc_param_value, cpp_method && cpp_method[:args_constraints])

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
            doc_param_shape: doc_param_shape,
            openapi_param_shape: openapi_param_shape,
            cpp_param_shape: cpp_param_shape,
            doc_response_shape: doc_response_shape,
            openapi_response_shape: openapi_response_shape,
            cpp_response_shape: cpp_response_shape,
            openapi_param_errors: openapi_param_errors,
            openapi_response_errors: openapi_response_errors,
            cpp_param_errors: cpp_param_errors,
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
        openapi: source_details(openapi_method, openapi_params, openapi_response, openapi_param_shape, openapi_response_shape),
        cpp: source_details(
          cpp_method, cpp_params, cpp_response, cpp_param_shape, cpp_response_shape,
          cpp_method && cpp_method[:args_constraints]
        ),
        documented_fields: {
          parameters: doc_params || [],
          response: doc_response || []
        },
        documented_shapes: {
          parameters: doc_param_shape,
          response: doc_response_shape
        },
        source_disagreement: classification == 'source_disagreement' ||
          notes.any? { |note| note.start_with?('OpenAPI and C++') },
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
      lines << "- source disagreements: #{report.fetch(:summary).fetch(:source_disagreement_count)}"
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

    def compare_fields(name:, doc_params:, openapi_params:, cpp_params:, doc_response:, openapi_response:, cpp_response:,
      doc_param_shape:, openapi_param_shape:, cpp_param_shape:, doc_response_shape:, openapi_response_shape:,
      cpp_response_shape:, openapi_param_errors:, openapi_response_errors:, cpp_param_errors:, notes:)
      source_results = {}

      [
        ['OpenAPI', openapi_params, openapi_response, openapi_param_shape, openapi_response_shape,
          openapi_param_errors, openapi_response_errors],
        ['C++', cpp_params, cpp_response, cpp_param_shape, cpp_response_shape, cpp_param_errors, []]
      ].each do |source_name, params, response, param_shape, response_shape, param_errors, response_errors|
        source_known = false
        source_matches = true

        [
          ['parameter', doc_params, params, doc_param_shape, param_shape],
          ['response', doc_response, response, doc_response_shape, response_shape]
        ].each do |kind, docs, source, docs_shape, source_shape|
          if source
            source_known = true
            missing = source - docs
            extra = docs - source
            next if missing.empty? && extra.empty?

            source_matches = false
            notes << "#{source_name} #{kind} fields differ; source-only: #{list_or_none(missing)}; docs-only: #{list_or_none(extra)}"
            next
          end

          next unless source_shape

          source_known = true
          next if shape_matches?(docs_shape, source_shape)

          source_matches = false
          notes << "#{source_name} #{kind} shapes differ; source: #{source_shape}; docs: #{docs_shape || 'unknown'}"
        end

        Array(param_errors).each do |error|
          source_known = true
          source_matches = false
          notes << "#{source_name} parameter example invalid: #{error}"
        end
        Array(response_errors).each do |error|
          source_known = true
          source_matches = false
          notes << "#{source_name} response example invalid: #{error}"
        end

        source_results[source_name] = source_known ? source_matches : nil
      end

      contracts_disagree = false
      if openapi_params && cpp_params && openapi_params != cpp_params
        contracts_disagree = true
        notes << "OpenAPI and C++ parameter fields differ; OpenAPI: #{openapi_params.join(', ')}; C++: #{cpp_params.join(', ')}"
      end

      if openapi_response && cpp_response && openapi_response != cpp_response
        contracts_disagree = true
        notes << "OpenAPI and C++ response fields differ; OpenAPI: #{openapi_response.join(', ')}; C++: #{cpp_response.join(', ')}"
      end

      if openapi_param_shape && cpp_param_shape && !shapes_overlap?(openapi_param_shape, cpp_param_shape)
        contracts_disagree = true
        notes << "OpenAPI and C++ parameter shapes differ; OpenAPI: #{openapi_param_shape}; C++: #{cpp_param_shape}"
      end
      if openapi_response_shape && cpp_response_shape && !shapes_overlap?(openapi_response_shape, cpp_response_shape)
        contracts_disagree = true
        notes << "OpenAPI and C++ response shapes differ; OpenAPI: #{openapi_response_shape}; C++: #{cpp_response_shape}"
      end

      known_results = source_results.values.compact
      if contracts_disagree || known_results.uniq.length > 1
        notes << 'OpenAPI and C++ do not support the same documented contract' if known_results.uniq.length > 1
        return 'source_disagreement'
      end
      return 'verified' if !known_results.empty? && known_results.all?
      return 'mismatch' unless known_results.empty?

      notes << "source method exists but schema fields could not be extracted for #{name}"
      'insufficient_source'
    end

    def source_details(method, params, response, param_shape = nil, response_shape = nil, parameter_constraints = nil)
      {
        present: !!method,
        parameter_fields: params || [],
        response_fields: response || [],
        parameter_shape: param_shape,
        response_shape: response_shape,
        parameter_constraints: parameter_constraints
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
              response_keys: json_top_level_keys(method['expected_response_json']),
              parameter_shape: json_shape(method['parameter_json']),
              response_shape: json_shape(method['expected_response_json']),
              parameter_value: documented_json_value(method['parameter_json']),
              response_value: documented_json_value(method['expected_response_json'])
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

      parsed = documented_json_value(value)
      return parsed.keys.sort if parsed.is_a?(Hash)

      []
    end

    def json_shape(value)
      value_shape(documented_json_value(value))
    end

    def documented_json_value(value)
      return value unless value.is_a?(String)

      JSON.parse(value)
    rescue JSON::ParserError
      value
    end

    def value_shape(value)
      case value
      when Hash
        'object'
      when Array
        return 'array' if value.empty?

        "array[#{value.map { |item| value_shape(item) }.uniq.sort.join('|')}]"
      when String
        'string'
      when Integer
        'integer'
      when Float
        'number'
      when TrueClass, FalseClass
        'boolean'
      when NilClass
        'null'
      else
        value.class.name.downcase
      end
    end

    def shape_matches?(documented, source)
      return false unless documented && source

      source.split('|').any? do |candidate|
        candidate == documented ||
          (candidate == 'array' && documented.start_with?('array[')) ||
          (candidate == 'array[array]' && documented.start_with?('array[array'))
      end
    end

    def shapes_overlap?(left, right)
      left.split('|').any? do |left_shape|
        right.split('|').any? do |right_shape|
          left_base = left_shape.split('[', 2).first
          right_base = right_shape.split('[', 2).first
          left_base == right_base
        end
      end
    end

    def validation_errors(method, validator_key, value)
      return [] unless method && method[validator_key]

      method[validator_key].call(value)
    end

    def validate_constraints(value, constraints, path = '$')
      return [] unless constraints
      return ["#{path} must be an array"] unless value.is_a?(Array)

      errors = []
      min_items = constraints[:min_items]
      max_items = constraints[:max_items]
      errors << "#{path} must contain at least #{min_items} item(s)" if min_items && value.length < min_items
      errors << "#{path} must contain at most #{max_items} item(s)" if max_items && value.length > max_items
      if constraints[:item] && !value.empty?
        errors.concat(validate_constraints(value.first, constraints[:item], "#{path}[0]"))
      end
      errors
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
        classifications: classification_counts(method_reports),
        source_disagreement_count: method_reports.count { |method| method[:source_disagreement] }
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
            request_shape: schema_shape(request_schema, schemas),
            response_shape: schema_shape(response_schema, schemas),
            request_validator: schema_validator(
              operation.dig('requestBody', 'content', 'application/json', 'schema'), schemas
            ),
            response_validator: schema_validator(
              operation.dig('responses', '200', 'content', 'application/json', 'schema'), schemas
            ),
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

    def schema_shape(schema, schemas)
      resolved = resolve_schema(schema, schemas)
      return nil unless resolved

      alternatives = resolved['oneOf'] || resolved['anyOf']
      if alternatives
        shapes = alternatives.filter_map { |item| schema_shape(item, schemas) }.uniq.sort
        return shapes.join('|') unless shapes.empty?
      end

      type = resolved['type']
      type = 'object' if type.nil? && resolved['properties']
      return nil unless type

      Array(type).map(&:to_s).uniq.sort.join('|')
    end

    def schema_validator(schema, schemas)
      return nil unless schema

      ->(value) { validate_value(value, schema, schemas) }
    end

    def validate_value(value, schema, schemas, path = '$', seen = Set.new)
      return [] unless schema

      if schema['$ref']
        key = schema['$ref'].split('/').last
        marker = [key, value.object_id]
        return [] if seen.include?(marker)

        return validate_value(value, schemas[key], schemas, path, seen | [marker])
      end

      if schema['allOf']
        return schema['allOf'].flat_map { |item| validate_value(value, item, schemas, path, seen) }.uniq
      end

      alternatives = schema['oneOf'] || schema['anyOf']
      if alternatives
        alternatives_errors = alternatives.map { |item| validate_value(value, item, schemas, path, seen) }
        return [] if alternatives_errors.any?(&:empty?)

        best_errors = alternatives_errors.min_by(&:length)
        return ["#{path} does not match any allowed schema: #{best_errors.join('; ')}"]
      end

      types = Array(schema['type']).map(&:to_s)
      types << 'object' if types.empty? && schema['properties']
      types << 'array' if types.empty? && (schema['items'] || schema['prefixItems'])
      unless types.empty? || types.any? { |type| value_matches_type?(value, type) }
        return ["#{path} must be #{types.join(' or ')}, got #{ruby_type(value)}"]
      end

      if schema.key?('enum') && !schema['enum'].include?(value)
        return ["#{path} must be one of #{schema['enum'].inspect}"]
      end

      errors = []
      if value.is_a?(Hash) && (types.include?('object') || schema['properties'])
        required = Array(schema['required'])
        missing = required - value.keys
        errors << "#{path} missing required field(s): #{missing.join(', ')}" unless missing.empty?

        properties = schema.fetch('properties', {})
        properties.each do |key, property_schema|
          next unless value.key?(key)

          errors.concat(validate_value(value[key], property_schema, schemas, "#{path}.#{key}", seen))
        end
        if schema['additionalProperties'] == false
          extra = value.keys - properties.keys
          errors << "#{path} has unexpected field(s): #{extra.join(', ')}" unless extra.empty?
        end
      end

      if value.is_a?(Array) && (types.include?('array') || schema['items'] || schema['prefixItems'])
        min_items = schema['minItems']
        max_items = schema['maxItems']
        errors << "#{path} must contain at least #{min_items} item(s)" if min_items && value.length < min_items
        errors << "#{path} must contain at most #{max_items} item(s)" if max_items && value.length > max_items

        Array(schema['prefixItems']).each_with_index do |item_schema, index|
          next unless index < value.length

          errors.concat(validate_value(value[index], item_schema, schemas, "#{path}[#{index}]", seen))
        end
        if schema['items'].is_a?(Hash)
          start_index = schema['prefixItems'] ? schema['prefixItems'].length : 0
          value.each_with_index do |item, index|
            next if index < start_index

            errors.concat(validate_value(item, schema['items'], schemas, "#{path}[#{index}]", seen))
          end
        elsif schema['items'] == false && schema['prefixItems'] && value.length > schema['prefixItems'].length
          errors << "#{path} contains items beyond the positional schema"
        end
      end
      errors.uniq
    end

    def value_matches_type?(value, type)
      case type
      when 'object' then value.is_a?(Hash)
      when 'array' then value.is_a?(Array)
      when 'string' then value.is_a?(String)
      when 'integer' then value.is_a?(Integer)
      when 'number' then value.is_a?(Numeric)
      when 'boolean' then value == true || value == false
      when 'null' then value.nil?
      else true
      end
    end

    def ruby_type(value)
      case value
      when Hash then 'object'
      when Array then 'array'
      when String then 'string'
      when Integer then 'integer'
      when Numeric then 'number'
      when TrueClass, FalseClass then 'boolean'
      when NilClass then 'null'
      else value.class.name
      end
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
      all_files = api_dirs.flat_map { |api_dir| Dir[File.join(api_dir, '**', '*.{hpp,cpp}')].sort }
      global_reflections, global_aliases = reflected_fields(all_files)

      api_dirs.each do |api_dir|
        api_name = File.basename(api_dir)
        files = Dir[File.join(api_dir, '**', '*.{hpp,cpp}')].sort
        file_texts = files.to_h { |file_name| [file_name, File.read(file_name)] }
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
          implementation = implementation_body(method_name, file_texts)
          nested_positional = api_name == 'wallet_bridge_api' &&
            implementation.to_s.match?(/args\.get_array\(\)\.at\(0\)\.is_array\(\)/)
          methods[name] = {
            args_keys: keys_for("#{method_name}_args", reflections, aliases, global_reflections, global_aliases),
            return_keys: keys_for("#{method_name}_return", reflections, aliases, global_reflections, global_aliases),
            args_shape: shape_for(
              "#{method_name}_args", reflections, aliases, global_reflections, global_aliases,
              positional_variant: api_name == 'wallet_bridge_api', nested_positional: nested_positional
            ),
            return_shape: shape_for(
              "#{method_name}_return", reflections, aliases, global_reflections, global_aliases
            ),
            args_constraints: positional_constraints(implementation, nested_positional),
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
        api_namespace = api_namespace_for(file_name)
        lines.each_with_index do |line, index|
          line.scan(/DEFINE_API_ARGS\s*\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*,\s*(.*?)\s*,\s*(.*?)\s*\)/) do |method_name, args_type, return_type|
            next if method_name == 'api_name'

            aliases["#{method_name}_args"] = qualify_alias_target(normalize_type(args_type), api_namespace)
            aliases["#{method_name}_return"] = qualify_alias_target(normalize_type(return_type), api_namespace)
          end

          line.scan(/typedef\s+(.+?)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;/) do |target, name|
            normalized_target = qualify_alias_target(normalize_type(target), api_namespace)
            aliases[name] = normalized_target
            aliases["#{api_namespace}::#{name}"] = normalized_target if api_namespace
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
          match = text.match(/FC_REFLECT\s*\(\s*([a-zA-Z_][a-zA-Z0-9_:]*)\s*,(.*)\)\s*$/m)
          next unless match

          fields = match[2].scan(/\(([a-zA-Z_][a-zA-Z0-9_]*)\)/).flatten.sort
          reflected_type = match[1]
          reflections[reflected_type] = fields
          reflections[short_type(reflected_type)] = fields
          type_parts = reflected_type.split('::')
          reflections[type_parts.last(2).join('::')] = fields if type_parts.length > 1
        end
      end

      [reflections, aliases]
    end

    def keys_for(name, reflections, aliases, global_reflections, global_aliases)
      return reflections[name] if reflections.key?(name)

      resolved = resolve_alias(name, aliases, global_aliases)
      return [] if short_type(resolved) == 'void_type'
      return nil if optional_type?(resolved) || collection_type?(resolved)

      scalar = scalar_shape(resolved)
      return nil if scalar && scalar != 'object'

      reflections[resolved] || reflections[short_type(resolved)] ||
        global_reflections[resolved] || global_reflections[short_type(resolved)]
    end

    def shape_for(name, reflections, aliases, global_reflections, global_aliases, positional_variant: false,
      nested_positional: false)
      return 'object' if reflections.key?(name)

      resolved = resolve_alias(name, aliases, global_aliases)
      normalized = normalize_type(resolved)

      if positional_variant && short_type(normalized) == 'variant'
        return nested_positional ? 'array[array]' : 'array'
      end
      return optional_shape(normalized, reflections, global_reflections) if optional_type?(normalized)
      return 'array' if collection_type?(normalized)

      scalar = scalar_shape(normalized)
      return scalar if scalar

      fields = reflections[normalized] || reflections[short_type(normalized)] ||
        global_reflections[normalized] || global_reflections[short_type(normalized)]
      fields ? 'object' : nil
    end

    def implementation_body(method_name, file_texts)
      pattern = /DEFINE_API_IMPL\s*\([^,]+,\s*#{Regexp.escape(method_name)}\s*\)(.*?)(?=DEFINE_API_IMPL|\z)/m
      file_texts.each_value do |text|
        match = text.match(pattern)
        return match[1] if match
      end
      nil
    end

    def positional_constraints(implementation, nested_positional)
      return nil unless implementation

      if nested_positional
        inner_minimum = implementation[/verify_args\s*\(\s*arguments\s*,\s*(\d+)\s*\)/, 1]
        constraints = { min_items: 1, item: {} }
        constraints[:item][:min_items] = inner_minimum.to_i if inner_minimum
        return constraints
      end

      exact_size = implementation[/CHECK_ARG_SIZE\s*\(\s*(\d+)\s*\)/, 1]
      return { min_items: exact_size.to_i, max_items: exact_size.to_i } if exact_size

      minimum = implementation[/verify_args\s*\(\s*args\s*,\s*(\d+)\s*\)/, 1]
      minimum ? { min_items: minimum.to_i } : nil
    end

    def resolve_alias(name, aliases, global_aliases)
      seen = Set.new
      current = normalize_type(name)
      loop do
        lookup_name = short_type(current)
        target = aliases[current] || global_aliases[current]
        unless current.include?('::')
          target ||= aliases[lookup_name] || global_aliases[lookup_name]
        end
        break unless target && !seen.include?(current)

        seen << current
        current = normalize_type(target)
      end
      current
    end

    def optional_shape(type, reflections, global_reflections)
      inner = type[/\A(?:fc::)?optional<(.+)>\z/, 1]
      return 'null' unless inner

      normalized = normalize_type(inner)
      inner_shape = scalar_shape(normalized)
      inner_shape ||= 'array' if collection_type?(normalized)
      inner_shape ||= 'object' if reflections[normalized] || reflections[short_type(normalized)] ||
        global_reflections[normalized] || global_reflections[short_type(normalized)]
      inner_shape ? "#{inner_shape}|null" : 'null'
    end

    def optional_type?(type)
      normalize_type(type).match?(/\A(?:fc::)?optional</)
    end

    def collection_type?(type)
      normalize_type(type).match?(/\A(?:(?:std|fc)::)?(?:vector|set|flat_set|map)</)
    end

    def scalar_shape(type)
      name = short_type(normalize_type(type))
      return 'object' if name == 'void_type'
      return 'object' if %w[variant_object mutable_variant_object].include?(name)
      return 'object' if name == 'price' || name.end_with?('_object', '_properties', '_transaction')
      return 'boolean' if name == 'bool'
      return 'integer' if name.match?(/\A(?:u?int(?:8|16|32|64)_t|size_t|int|long)\z/)
      return 'number' if %w[float double].include?(name)
      return 'string' if name == 'string' || name.end_with?('_type', '_version')

      nil
    end

    def normalize_type(type)
      type.to_s.gsub(/\s+/, '').sub(/\Aconst/, '').sub(/&\z/, '')
    end

    def short_type(type)
      normalize_type(type).split('::').last
    end

    def api_namespace_for(file_name)
      relative = Pathname.new(file_name).relative_path_from(Pathname.new(@apis_root)).to_s
      relative.split(File::SEPARATOR).first
    rescue ArgumentError
      nil
    end

    def qualify_alias_target(type, api_namespace)
      return type unless api_namespace
      return type if type.include?('::') || type.include?('<')
      return type if %w[
        bool double float int long size_t string variant void
        int8_t int16_t int32_t int64_t uint8_t uint16_t uint32_t uint64_t
      ].include?(type)

      "#{api_namespace}::#{type}"
    end

    def relative_path(path)
      Pathname.new(path).relative_path_from(Pathname.new(@project_root)).to_s
    rescue ArgumentError
      path
    end
  end
end
