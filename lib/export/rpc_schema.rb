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
      paths = {}
      built[:methods].each do |method|
        name = method['api_method'].to_s
        paths["/#{name}"] = openapi_path(method)
      end

      {
        'openapi' => OPENAPI_VERSION,
        'info' => {
          'title' => 'Hive JSON-RPC',
          'version' => '0.0.0',
          'description' => info_description + "\n\nEach path is a JSON-RPC 2.0 method name. Call it with HTTP POST and a JSON-RPC envelope (`jsonrpc`, `method`, `params`, `id`). This is not a REST API."
        },
        'servers' => [
          { 'url' => DEFAULT_NODE, 'description' => 'Public HTTPS JSON-RPC node' }
        ],
        'paths' => paths,
        'components' => {
          'schemas' => {
            'JsonRpcRequest' => {
              'type' => 'object',
              'required' => %w(jsonrpc method id),
              'properties' => {
                'jsonrpc' => { 'type' => 'string', 'enum' => ['2.0'] },
                'method' => { 'type' => 'string', 'description' => 'Fully qualified method name, for example database_api.get_dynamic_global_properties.' },
                'params' => { 'description' => 'Named object for AppBase methods, positional array for condenser_api. See the operation example and x-hive-params.' },
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
        'x-hive-namespaces' => built[:namespaces].map { |namespace| namespace['name'] }
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
      params_schema = params_schema_for(method, api)
      result_schema = result_schema_for(method)

      entry = {
        'name' => name,
        'summary' => summary,
        'description' => description,
        'params' => [
          {
            'name' => params_schema[:name],
            'description' => params_schema[:description],
            'required' => params_schema[:required],
            'schema' => params_schema[:schema]
          }
        ],
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
      if method['curl_examples']
        entry['examples'] = curl_examples(method)
      end
      entry
    end

    def openapi_path(method)
      name = method['api_method'].to_s
      api = name.split('.', 2).first
      params_schema = params_schema_for(method, api)

      operation = {
        'operationId' => name.tr('.', '_'),
        'summary' => first_line(method['purpose']),
        'description' => method_description(method),
        'tags' => [api],
        'requestBody' => {
          'required' => true,
          'content' => {
            'application/json' => {
              'schema' => { '$ref' => '#/components/schemas/JsonRpcRequest' },
              'example' => {
                'jsonrpc' => '2.0',
                'method' => name,
                'params' => params_example(method, api),
                'id' => 1
              }
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
        },
        'x-hive-params' => params_schema[:schema]
      }
      operation['deprecated'] = true if obsolete?(method)
      { 'post' => operation }
    end

    def params_example(method, api)
      parsed = parse_example(method['parameter_json'])
      return parsed unless parsed.nil?

      api == 'condenser_api' ? [] : {}
    end

    def params_schema_for(method, api)
      parsed = parse_example(method['parameter_json'])
      positional = api == 'condenser_api' || parsed.is_a?(Array)

      if parsed.nil?
        return {
          name: positional ? 'params' : 'params',
          description: positional ? 'Positional JSON-RPC params array. No example is documented.' : 'Named JSON-RPC params object. No example is documented.',
          required: false,
          schema: positional ? { 'type' => 'array' } : { 'type' => 'object' }
        }
      end

      if positional
        {
          name: 'params',
          description: 'Positional JSON-RPC params array. Item schemas are inferred from the documented example.',
          required: !parsed.empty?,
          schema: array_schema(parsed)
        }
      else
        {
          name: 'params',
          description: 'Named JSON-RPC params object. Property schemas are inferred from the documented example.',
          required: parsed.is_a?(Hash) && !parsed.empty?,
          schema: schema_for(parsed)
        }
      end
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
        {}
      else
        {}
      end
    end

    def array_schema(value)
      return { 'type' => 'array' } unless value.is_a?(Array)

      if value.empty?
        { 'type' => 'array', 'items' => {} }
      elsif value.all? { |item| item.is_a?(Hash) }
        merged = {}
        value.each { |item| merged = deep_merge_example(merged, item) }
        { 'type' => 'array', 'items' => schema_for(merged) }
      else
        { 'type' => 'array', 'items' => schema_for(value.first) }
      end
    end

    def deep_merge_example(left, right)
      return right unless left.is_a?(Hash) && right.is_a?(Hash)

      merged = left.dup
      right.each do |key, value|
        merged[key] = merged.key?(key) ? deep_merge_example(merged[key], value) : value
      end
      merged
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

    def curl_examples(method)
      Array(method['curl_examples']).first(2).each_with_index.filter_map do |example, index|
        text = example.to_s.strip
        next if text.empty?

        parsed = parse_example(text)
        params = parsed.is_a?(Hash) ? parsed['params'] : nil
        {
          'name' => "documentedExample#{index + 1}",
          'params' => [
            {
              'name' => 'params',
              'value' => params.nil? ? text : params
            }
          ]
        }
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
