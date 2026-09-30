require 'fileutils'
require 'json'
require 'yaml'

module Export
  # Builds OpenRPC (and a thin OpenAPI 3 JSON-RPC overlay) from
  # _data/apidefinitions YAML. Descriptions and example shapes come from the
  # portal docs; they are not a wire-level Hive schema.
  class RpcSchema
    OPENRPC_VERSION = '1.3.2'.freeze
    OPENAPI_VERSION = '3.0.3'.freeze
    SCHEMA_DRAFT = 'https://json-schema.org/draft-07/schema#'.freeze
    DEFAULT_NODE = 'https://api.hive.blog'.freeze
    SKIP_FILES = %w(broadcast_ops.yml broadcast_ops_customs.yml).freeze

    def initialize(api_data_path:, docs_url: 'https://developers.hive.io')
      @api_data_path = api_data_path
      @docs_url = docs_url.sub(%r{/+\z}, '')
    end

    def build
      methods = []
      namespaces = []

      Dir[File.join(@api_data_path, '*.yml')].sort.each do |file_name|
        next if SKIP_FILES.include?(File.basename(file_name))

        YAML.load_file(file_name).each do |section|
          next unless section.is_a?(Hash) && section['methods']

          namespace_name = namespace_label(section, file_name)
          namespaces << {
            'name' => namespace_name,
            'summary' => first_line(section['description']),
            'description' => clean_text(section['description'])
          }

          Array(section['methods']).each do |method|
            api_method = method['api_method'].to_s
            next if api_method.empty?

            methods << method.merge(
              '_namespace' => namespace_name,
              '_api' => api_method.split('.', 2).first
            )
          end
        end
      end

      methods.sort_by! { |method| method['api_method'].to_s }
      { methods: methods, namespaces: namespaces }
    end

    def openrpc_document
      built = build
      {
        'openrpc' => OPENRPC_VERSION,
        'info' => {
          'title' => 'Hive JSON-RPC',
          'version' => '0.0.0',
          'description' => info_description,
          'license' => {
            'name' => 'MIT',
            'url' => 'https://gitlab.syncad.com/hive/devportal/-/blob/develop/LICENSE'
          }
        },
        'servers' => [
          {
            'name' => 'Hive public API',
            'url' => DEFAULT_NODE,
            'description' => 'Public HTTPS JSON-RPC node. Other public nodes are listed on the Hive Nodes page.'
          }
        ],
        'methods' => built[:methods].map { |method| openrpc_method(method) },
        'components' => {
          'contentDescriptors' => {},
          'schemas' => {}
        },
        'externalDocs' => {
          'description' => 'Hive JSON-RPC API reference',
          'url' => "#{@docs_url}/apidefinitions/"
        },
        'x-hive-namespaces' => built[:namespaces]
      }
    end

    def openapi_document
      built = build
      method_catalog = built[:methods].map { |method| openapi_method_entry(method) }

      {
        'openapi' => OPENAPI_VERSION,
        'info' => {
          'title' => 'Hive JSON-RPC',
          'version' => '0.0.0',
          'description' => info_description + "\n\nHive exposes a single HTTP POST `/` JSON-RPC 2.0 endpoint. Method names live in the request body (`method`), not in the URL path. Per-method parameter shapes are listed under `x-hive-methods` and in `openrpc.json`."
        },
        'servers' => [
          { 'url' => DEFAULT_NODE, 'description' => 'Public HTTPS JSON-RPC node' }
        ],
        'paths' => {
          '/' => openapi_root_path(built[:methods])
        },
        'components' => {
          'schemas' => {
            'JsonRpcRequest' => {
              'type' => 'object',
              'required' => %w(jsonrpc method id),
              'properties' => {
                'jsonrpc' => { 'type' => 'string', 'enum' => ['2.0'] },
                'method' => { 'type' => 'string', 'description' => 'Fully qualified method name, for example database_api.get_dynamic_global_properties.' },
                'params' => { 'description' => 'Named object for AppBase methods, positional array for condenser_api. See x-hive-methods and openrpc.json.' },
                'id' => { 'description' => 'Client-chosen request id.' }
              }
            },
            'JsonRpcResponse' => {
              'type' => 'object',
              'properties' => {
                'jsonrpc' => { 'type' => 'string' },
                'id' => {},
                'result' => { 'description' => 'Present on success. Field-level shape is in openrpc.json.' },
                'error' => {
                  'type' => 'object',
                  'properties' => {
                    'code' => { 'type' => 'integer' },
                    'message' => { 'type' => 'string' },
                    'data' => {}
                  }
                }
              }
            }
          }
        },
        'externalDocs' => {
          'description' => 'Hive JSON-RPC API reference',
          'url' => "#{@docs_url}/apidefinitions/"
        },
        'x-hive-namespaces' => built[:namespaces].map { |namespace| namespace['name'] },
        'x-hive-methods' => method_catalog
      }
    end

    def write(destination)
      FileUtils.mkdir_p(destination)
      openrpc_path = File.join(destination, 'openrpc.json')
      openapi_path = File.join(destination, 'openapi.json')
      File.write(openrpc_path, JSON.pretty_generate(openrpc_document) + "\n")
      File.write(openapi_path, JSON.pretty_generate(openapi_document) + "\n")
      { openrpc: openrpc_path, openapi: openapi_path }
    end

    private

    def info_description
      <<~TEXT.chomp
        Machine-readable export of the Hive JSON-RPC methods documented on the Hive Developer Portal.

        Generated from `_data/apidefinitions`. Parameter and result schemas are inferred from the documented example shapes (`parameter_json` / `expected_response_json`) and are illustrative, not a complete on-chain type system. Prefer the HTML API reference when a field is missing or marked obsolete.

        AppBase methods use a named-parameter object. `condenser_api` methods use a positional parameter array (legacy argument order).
      TEXT
    end

    def openrpc_method(method)
      name = method['api_method'].to_s
      api, short_name = name.split('.', 2)
      summary = first_line(method['purpose'])
      description = method_description(method)
      param_info = params_info_for(method, api)
      result_schema = result_schema_for(method)

      entry = {
        'name' => name,
        'summary' => summary,
        'description' => description,
        'paramStructure' => param_info[:structure],
        'params' => param_info[:descriptors],
        'result' => {
          'name' => 'result',
          'description' => 'JSON-RPC result. Shape is inferred from the documented example when one exists.',
          'schema' => result_schema
        },
        'x-hive-api' => api,
        'x-hive-method' => short_name,
        'externalDocs' => {
          'description' => 'Portal reference',
          'url' => "#{@docs_url}/apidefinitions/##{name}"
        }
      }

      entry['deprecated'] = true if obsolete?(method)
      entry['x-hive-disabled'] = true if method['disabled']
      entry['x-hive-since'] = method['since'].to_s if method['since']
      entry['x-hive-successors'] = Array(method['successors']) if method['successors']
      examples = example_pairings(method, param_info)
      entry['examples'] = examples unless examples.empty?
      entry
    end

    def openapi_root_path(methods)
      examples = openapi_request_examples(methods)
      {
        'post' => {
          'operationId' => 'jsonrpc',
          'summary' => 'Hive JSON-RPC 2.0',
          'description' => 'Call any documented Hive JSON-RPC method with HTTP POST to `/`. The method name is in the JSON-RPC body, not the URL. Application errors typically return HTTP 200 with an `error` object. Per-method discovery lives in `x-hive-methods` and in openrpc.json.',
          'requestBody' => {
            'required' => true,
            'content' => {
              'application/json' => {
                'schema' => { '$ref' => '#/components/schemas/JsonRpcRequest' },
                'examples' => examples
              }
            }
          },
          'responses' => {
            '200' => {
              'description' => 'JSON-RPC response. Application errors use HTTP 200 with an `error` object. Result shape is in the OpenRPC document.',
              'content' => {
                'application/json' => {
                  'schema' => { '$ref' => '#/components/schemas/JsonRpcResponse' }
                }
              }
            }
          }
        }
      }
    end

    def openapi_method_entry(method)
      name = method['api_method'].to_s
      api = name.split('.', 2).first
      param_info = params_info_for(method, api)
      entry = {
        'name' => name,
        'summary' => first_line(method['purpose']),
        'paramStructure' => param_info[:structure],
        'params' => param_info[:descriptors],
        'x-hive-api' => api
      }
      entry['deprecated'] = true if obsolete?(method)
      entry['disabled'] = true if method['disabled']
      entry
    end

    def openapi_request_examples(methods)
      preferred = %w[
        database_api.find_accounts
        database_api.get_dynamic_global_properties
        condenser_api.get_dynamic_global_properties
        condenser_api.get_account_history
      ]
      by_name = methods.each_with_object({}) { |method, memo| memo[method['api_method'].to_s] = method }
      selected = preferred.filter_map { |name| by_name[name] }
      selected = methods.first(4) if selected.empty?

      selected.each_with_object({}) do |method, memo|
        name = method['api_method'].to_s
        api = name.split('.', 2).first
        memo[name.tr('.', '_')] = {
          'summary' => name,
          'value' => {
            'jsonrpc' => '2.0',
            'method' => name,
            'params' => params_example(method, api),
            'id' => 1
          }
        }
      end
    end

    def params_example(method, api)
      parsed = parse_example(method['parameter_json'])
      return parsed unless parsed.nil?

      api == 'condenser_api' ? [] : {}
    end

    # Returns :structure ("by-name" / "by-position"), :descriptors (OpenRPC
    # Content Descriptor list), and :names (descriptor names in order).
    #
    # Requiredness comes from purpose "(optional)" markers and from curl
    # examples: an argument omitted by any documented curl is not required.
    # Schemas are inferred from parameter_json plus every curl argument value
    # so documented alternatives (string vs int, null, etc.) remain valid.
    def params_info_for(method, api)
      parsed = parse_example(method['parameter_json'])
      positional = api == 'condenser_api' || parsed.is_a?(Array)
      structure = positional ? 'by-position' : 'by-name'
      curl_params = curl_params_examples(method)

      if parsed.nil?
        return { structure: structure, descriptors: [], names: [] }
      end

      if positional
        values = parsed.is_a?(Array) ? parsed : [parsed]
        return { structure: structure, descriptors: [], names: [] } if values.empty?

        names = positional_param_names(method, values.length)
        descriptors = values.each_with_index.map do |value, index|
          samples = positional_samples(value, curl_params, index)
          {
            'name' => names[index],
            'required' => positional_arg_required?(method, names[index], index, curl_params),
            'schema' => schema_from_samples(samples)
          }
        end
        { structure: structure, descriptors: descriptors, names: names }
      else
        hash = parsed.is_a?(Hash) ? parsed : {}
        return { structure: structure, descriptors: [], names: [] } if hash.empty?

        names = hash.keys.map(&:to_s)
        descriptors = hash.map do |key, value|
          key_s = key.to_s
          samples = named_samples(value, curl_params, key_s)
          {
            'name' => key_s,
            'required' => named_arg_required?(method, key_s, curl_params),
            'schema' => schema_from_samples(samples)
          }
        end
        { structure: structure, descriptors: descriptors, names: names }
      end
    end

    # Raw `params` payloads from documented curl_examples (Hash or Array).
    def curl_params_examples(method)
      Array(method['curl_examples']).filter_map do |example|
        parsed = parse_example(example.to_s.strip)
        next unless parsed.is_a?(Hash) && parsed.key?('params')

        parsed['params']
      end
    end

    # Include JSON nulls; filter_map would drop them and lose null alternatives.
    def positional_samples(base, curl_params, index)
      samples = [base]
      curl_params.each do |params|
        values = case params
                 when Array then params
                 when nil then []
                 else [params]
                 end
        samples << values[index] if index < values.length
      end
      samples
    end

    def named_samples(base, curl_params, name)
      samples = [base]
      curl_params.each do |params|
        next unless params.is_a?(Hash) && params.key?(name)

        samples << params[name]
      end
      samples
    end

    # Mark optional when purpose says so, or when any documented curl omits it.
    def named_arg_required?(method, name, curl_params)
      return false if optional_in_purpose?(method, name)

      named = curl_params.select { |params| params.is_a?(Hash) }
      return true if named.empty?

      named.all? { |params| params.key?(name) }
    end

    def positional_arg_required?(method, name, index, curl_params)
      return false if optional_in_purpose?(method, name)

      arrays = curl_params.select { |params| params.is_a?(Array) }
      return true if arrays.empty?

      arrays.all? { |params| params.length > index }
    end

    def optional_in_purpose?(method, name)
      purpose = method['purpose'].to_s
      return false if purpose.empty?

      escaped = Regexp.escape(name)
      # `name` ... (optional) / [optional]
      # `name:type` (optional)
      # name (optional) — e.g. "last_id (optional)"
      purpose.match?(/`#{escaped}(?::[^`]*)?`[^\n`]{0,100}(\(|\[)optional(\)|\])/i) ||
        purpose.match?(/\b#{escaped}\b[^\n.]{0,80}\(optional\)/i)
    end

    def schema_from_samples(samples)
      return {} if samples.nil? || samples.empty?

      samples.map { |sample| schema_for(sample) }.reduce { |left, right| merge_schemas(left, right) }
    end

    def positional_param_names(method, count)
      purpose = method['purpose'].to_s
      names = purpose.scan(/\*\s*`([A-Za-z_][A-Za-z0-9_]*)\s*:/).flatten
      if names.length < count
        table_names = purpose.scan(/\|\s*`([A-Za-z_][A-Za-z0-9_]*)`/).flatten.uniq
        names = table_names if table_names.length >= count
      end
      Array.new(count) { |index| names[index] || "arg#{index}" }
    end

    def result_schema_for(method)
      parsed = parse_example(method['expected_response_json'])
      return {} if parsed.nil?

      schema_for(parsed)
    end

    def schema_for(value)
      case value
      when Hash
        properties = {}
        value.each do |key, child|
          properties[key.to_s] = schema_for(child)
        end
        { 'type' => 'object', 'properties' => properties }
      when Array
        array_schema(value)
      when String
        { 'type' => 'string' }
      when Integer
        { 'type' => 'integer' }
      when Float
        { 'type' => 'number' }
      when TrueClass, FalseClass
        { 'type' => 'boolean' }
      when NilClass
        { 'type' => 'null' }
      else
        {}
      end
    end

    def array_schema(value)
      return { 'type' => 'array' } unless value.is_a?(Array)

      if value.empty?
        { 'type' => 'array', 'items' => {} }
      elsif value.all? { |item| item.is_a?(Hash) }
        # Merge per-item object schemas so conflicting scalar field types
        # become anyOf instead of keeping only the last example value.
        item_schemas = value.map { |item| schema_for(item) }
        { 'type' => 'array', 'items' => item_schemas.reduce { |left, right| merge_schemas(left, right) } }
      else
        item_schemas = value.map { |item| schema_for(item) }
        unique = uniq_schemas(item_schemas)
        if unique.length == 1
          { 'type' => 'array', 'items' => unique.first }
        else
          # Mixed tuples (e.g. [index, operationObject]). anyOf keeps OpenAPI
          # 3.0.3 compatibility while accepting every observed item type.
          { 'type' => 'array', 'items' => { 'anyOf' => unique } }
        end
      end
    end

    def uniq_schemas(schemas)
      schemas.each_with_object([]) do |schema, memo|
        memo << schema unless memo.any? { |existing| existing == schema }
      end
    end

    def merge_schemas(left, right)
      return right if left.nil? || left.empty?
      return left if right.nil? || right.empty?
      return left if left == right

      if left['type'] == 'object' && right['type'] == 'object'
        keys = left.fetch('properties', {}).keys | right.fetch('properties', {}).keys
        properties = {}
        keys.each do |key|
          properties[key] = merge_schemas(left.dig('properties', key), right.dig('properties', key))
        end
        return { 'type' => 'object', 'properties' => properties }
      end

      if left['type'] == 'array' && right['type'] == 'array'
        return { 'type' => 'array', 'items' => merge_schemas(left['items'], right['items']) }
      end

      alternatives = []
      [left, right].each do |schema|
        if schema.is_a?(Hash) && schema['anyOf']
          schema['anyOf'].each { |item| alternatives << item unless alternatives.any? { |existing| existing == item } }
        elsif schema
          alternatives << schema unless alternatives.any? { |existing| existing == schema }
        end
      end
      alternatives.length == 1 ? alternatives.first : { 'anyOf' => alternatives }
    end

    def parse_example(value)
      return nil if value.nil?
      return value if value.is_a?(Hash) || value.is_a?(Array) || value.is_a?(Integer) || value.is_a?(Float) || value == true || value == false

      text = value.to_s.strip
      return nil if text.empty?

      JSON.parse(text)
    rescue JSON::ParserError
      nil
    end

    def method_description(method)
      parts = []
      purpose = clean_text(method['purpose'])
      parts << purpose if purpose && !purpose.empty?
      parts << 'Marked obsolete in the portal docs. Prefer a listed successor when calling new code.' if obsolete?(method)
      parts << 'Documented as disabled.' if method['disabled']
      if method['successors']
        parts << "Successors: #{Array(method['successors']).join(', ')}."
      end
      parts << 'Schemas below are inferred from documented examples and may omit fields the node returns.'
      parts.join("\n\n")
    end

    def example_pairings(method, param_info)
      Array(method['curl_examples']).first(2).each_with_index.filter_map do |example, index|
        text = example.to_s.strip
        next if text.empty?

        parsed = parse_example(text)
        next unless parsed.is_a?(Hash)

        raw_params = parsed.key?('params') ? parsed['params'] : nil
        param_examples = example_param_values(raw_params, param_info)
        next if param_examples.nil?

        {
          'name' => "documentedExample#{index + 1}",
          'params' => param_examples
        }
      end
    end

    # Expand a curl JSON-RPC `params` value into OpenRPC Example Objects that
    # match the per-argument content descriptors (not a nested `params` envelope).
    def example_param_values(raw_params, param_info)
      names = param_info[:names]
      structure = param_info[:structure]

      if structure == 'by-position'
        values = case raw_params
                 when Array then raw_params
                 when nil then []
                 else [raw_params]
                 end
        # Allow shorter curl examples than the documented parameter_json arity.
        values.each_with_index.map do |value, index|
          name = names[index] || "arg#{index}"
          { 'name' => name, 'value' => value }
        end
      else
        hash = case raw_params
               when Hash then raw_params
               when nil then {}
               else nil
               end
        return nil if hash.nil?

        hash.map do |key, value|
          { 'name' => key.to_s, 'value' => value }
        end
      end
    end

    def obsolete?(method)
      !!method['removed'] || method['status'].to_s == 'obsolete'
    end

    def namespace_label(section, file_name)
      name = section['name'].to_s
      name = name.sub(/\Atitles\./, '').tr('_', ' ')
      name = File.basename(file_name, '.yml') if name.empty? || name.start_with?(':')
      name.sub(/\A:/, '')
    end

    def first_line(text)
      clean = clean_text(text)
      return '' if clean.nil? || clean.empty?

      line = clean.lines.first.to_s.strip
      line.length > 240 ? "#{line[0, 237]}..." : line
    end

    def clean_text(text)
      return nil if text.nil?

      text.to_s.gsub(/\r\n?/, "\n").strip
    end

  end
end
