require_relative 'test_helper'
require 'json'

class RpcSchemaExportTest < Minitest::Test
  include JekyllBuildTestHelper

  EXPECTED_METHODS = %w[
    condenser_api.get_dynamic_global_properties
    database_api.get_dynamic_global_properties
    database_api.find_accounts
    rc_api.find_rc_accounts
    bridge.get_post
  ].freeze

  def test_rake_export_writes_valid_openrpc_and_openapi
    lib = File.expand_path('../lib', __dir__)
    $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
    require 'export/rpc_schema'

    Dir.mktmpdir('devportal-rpc-schema-') do |dir|
      Export::RpcSchema.new(
        api_data_path: project_path('_data', 'apidefinitions')
      ).write(dir)

      openrpc = JSON.parse(File.read(File.join(dir, 'openrpc.json')))
      openapi = JSON.parse(File.read(File.join(dir, 'openapi.json')))

      assert_equal '1.3.2', openrpc['openrpc']
      assert_equal 'Hive JSON-RPC', openrpc.dig('info', 'title')
      assert_equal '3.0.3', openapi['openapi']
      assert openrpc['methods'].is_a?(Array)
      assert openrpc['methods'].length > 100, 'Expected the export to cover documented JSON-RPC methods'

      names = openrpc['methods'].map { |method| method['name'] }
      EXPECTED_METHODS.each do |name|
        assert_includes names, name
      end

      assert openapi.dig('paths', '/', 'post'), 'Expected a single OpenAPI POST / JSON-RPC endpoint'
      refute openapi['paths'].key?('/database_api.find_accounts'),
        'OpenAPI must not advertise per-method URL paths that 404 on api.hive.blog'

      catalog_names = Array(openapi['x-hive-methods']).map { |entry| entry['name'] }
      EXPECTED_METHODS.each { |name| assert_includes catalog_names, name }

      condenser = openrpc['methods'].find { |method| method['name'] == 'condenser_api.get_dynamic_global_properties' }
      assert_equal 'by-position', condenser['paramStructure']
      assert_equal [], condenser['params'], 'No-arg methods must emit an empty params descriptor list'

      database = openrpc['methods'].find { |method| method['name'] == 'database_api.find_accounts' }
      assert_equal 'by-name', database['paramStructure']
      param_names = database['params'].map { |descriptor| descriptor['name'] }
      assert_includes param_names, 'accounts'
      refute_includes param_names, 'params',
        'OpenRPC must describe individual RPC args, not a nested params envelope'
      accounts = database['params'].find { |descriptor| descriptor['name'] == 'accounts' }
      assert_equal 'array', accounts.dig('schema', 'type')
      assert accounts['required'], 'accounts is present in every documented call'
      delayed = database['params'].find { |descriptor| descriptor['name'] == 'delayed_votes_active' }
      assert delayed, 'Expected delayed_votes_active descriptor'
      refute delayed['required'],
        'delayed_votes_active is omitted from documented curl examples and must not be required'

      example = Array(database['examples']).first
      assert example, 'Expected documented curl examples on database_api.find_accounts'
      example_names = example['params'].map { |item| item['name'] }
      refute_includes example_names, 'params'
      assert_includes example_names, 'accounts'

      history = openrpc['methods'].find { |method| method['name'] == 'condenser_api.get_account_history' }
      assert_equal 'by-position', history['paramStructure']
      assert history['params'].length >= 3
      history_names = history['params'].map { |descriptor| descriptor['name'] }
      assert_equal history_names.uniq, history_names
      assert_includes history_names, 'account'

      refute openrpc['methods'].any? { |method| method['name'].to_s.start_with?('broadcast_ops') }
    end
  end

  def test_inferred_schemas_accept_documented_examples
    lib = File.expand_path('../lib', __dir__)
    $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
    require 'export/rpc_schema'

    exporter = Export::RpcSchema.new(
      api_data_path: project_path('_data', 'apidefinitions')
    )
    built = exporter.build
    openrpc = exporter.openrpc_document
    by_name = openrpc['methods'].each_with_object({}) { |method, memo| memo[method['name']] = method }

    param_failures = []
    result_failures = []

    built[:methods].each do |method|
      name = method['api_method'].to_s
      entry = by_name[name]
      next unless entry

      parsed_params = parse_jsonish(method['parameter_json'])
      unless parsed_params.nil?
        errors = validate_params_example(parsed_params, entry)
        param_failures << "#{name}: #{errors.join('; ')}" unless errors.empty?
      end

      parsed_result = parse_jsonish(method['expected_response_json'])
      next if parsed_result.nil?

      result_schema = entry.dig('result', 'schema') || {}
      errors = validate_against_schema(parsed_result, result_schema, '$.result')
      result_failures << "#{name}: #{errors.join('; ')}" unless errors.empty?
    end

    # Spot-check the mixed-tuple cases called out in review.
    history_params = by_name.fetch('condenser_api.get_account_history')
    assert_empty validate_params_example(['hiveio', 1000, 1000], history_params),
      'Mixed positional params for get_account_history must validate'

    account_history = by_name.fetch('account_history_api.get_account_history')
    sample_history = { 'history' => [[99, { 'trx_id' => '0' * 40, 'block' => 0 }]] }
    assert_empty validate_against_schema(sample_history, account_history.dig('result', 'schema'), '$.result'),
      'Mixed history tuples must validate against the inferred result schema'

    assert_empty param_failures.take(10),
      "Parameter examples must satisfy inferred schemas (showing up to 10):\n#{param_failures.take(10).join("\n")}"
    assert_empty result_failures.take(10),
      "Result examples must satisfy inferred schemas (showing up to 10):\n#{result_failures.take(10).join("\n")}"
  end

  def test_optional_args_and_curl_types_in_descriptors
    lib = File.expand_path('../lib', __dir__)
    $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
    require 'export/rpc_schema'

    exporter = Export::RpcSchema.new(
      api_data_path: project_path('_data', 'apidefinitions')
    )
    openrpc = exporter.openrpc_document
    by_name = openrpc['methods'].each_with_object({}) { |method, memo| memo[method['name']] = method }

    find_accounts = by_name.fetch('database_api.find_accounts')
    delayed = find_accounts['params'].find { |descriptor| descriptor['name'] == 'delayed_votes_active' }
    refute delayed['required'], 'find_accounts delayed_votes_active must be optional'

    history = by_name.fetch('account_history_api.get_account_history')
    start = history['params'].find { |descriptor| descriptor['name'] == 'start' }
    assert start['required']
    assert_empty validate_against_schema(1000, start['schema'], '$.params.start'),
      'get_account_history start must accept documented curl integer 1000'
    assert_empty validate_against_schema('-1', start['schema'], '$.params.start'),
      'get_account_history start must still accept the parameter_json string form'
    %w[include_reversible operation_filter_low operation_filter_high].each do |name|
      descriptor = history['params'].find { |item| item['name'] == name }
      refute descriptor['required'], "#{name} is documented optional / omitted from curls"
    end

    followers = by_name.fetch('condenser_api.get_followers')
    start_pos = followers['params'].find { |descriptor| descriptor['name'] == 'start' }
    assert_empty validate_against_schema(nil, start_pos['schema'], '$.params.start'),
      'get_followers start must accept documented curl null'

    # Every emitted example must satisfy requiredness and descriptor schemas.
    required_failures = []
    type_failures = []
    openrpc['methods'].each do |entry|
      examples = Array(entry['examples'])
      descriptors = Array(entry['params'])
      required_names = descriptors.select { |descriptor| descriptor['required'] }.map { |descriptor| descriptor['name'] }

      examples.each_with_index do |example, index|
        present = Array(example['params']).map { |item| item['name'] }
        missing = required_names - present
        unless missing.empty?
          required_failures << "#{entry['name']} example#{index + 1} omits required #{missing.join(', ')}"
        end

        Array(example['params']).each do |item|
          descriptor = descriptors.find { |candidate| candidate['name'] == item['name'] }
          unless descriptor
            type_failures << "#{entry['name']} example#{index + 1}: no descriptor for #{item['name']}"
            next
          end

          errors = validate_against_schema(item['value'], descriptor['schema'], "$.#{item['name']}")
          type_failures << "#{entry['name']} example#{index + 1}: #{errors.join('; ')}" unless errors.empty?
        end
      end
    end

    assert_empty required_failures.take(10),
      "Exported examples must include every required argument (showing up to 10):\n#{required_failures.take(10).join("\n")}"
    assert_empty type_failures.take(10),
      "Exported example values must satisfy descriptor schemas (showing up to 10):\n#{type_failures.take(10).join("\n")}"

    # Curl-documented positional args must become descriptors even when
    # parameter_json is empty or shorter (review: descriptor coverage).
    list_rc = by_name.fetch('condenser_api.list_rc_accounts')
    assert_equal 2, list_rc['params'].length,
      'list_rc_accounts curl ["ecency", 10] requires two descriptors'
    assert list_rc['params'].all? { |descriptor| descriptor['required'] },
      'both list_rc_accounts curl args are present in every documented call'

    find_rc = by_name.fetch('condenser_api.find_rc_accounts')
    assert_equal 1, find_rc['params'].length
    assert find_rc['params'].first['required']

    get_accounts = by_name.fetch('condenser_api.get_accounts')
    assert_equal 2, get_accounts['params'].length,
      'get_accounts must retain trailing delayed_votes_active from curl'
    delayed = get_accounts['params'].find { |descriptor| descriptor['name'] == 'delayed_votes_active' }
    assert delayed, 'Expected delayed_votes_active descriptor name from purpose'
    refute delayed['required'], 'delayed_votes_active is omitted from the short curl example'
  end

  def test_built_site_publishes_schema_and_links_it
    site_dir_for_assertions do |site_dir|
      openrpc_path = File.join(site_dir, 'openrpc.json')
      openapi_path = File.join(site_dir, 'openapi.json')
      assert File.exist?(openrpc_path), 'Expected openrpc.json in the Jekyll build'
      assert File.exist?(openapi_path), 'Expected openapi.json in the Jekyll build'

      openrpc = JSON.parse(File.read(openrpc_path))
      openapi = JSON.parse(File.read(openapi_path))
      names = openrpc['methods'].map { |method| method['name'] }
      EXPECTED_METHODS.each { |name| assert_includes names, name }

      assert openapi.dig('paths', '/', 'post')
      refute openapi['paths'].keys.any? { |path| path != '/' }

      llms = File.read(File.join(site_dir, 'llms.txt'))
      assert_includes llms, 'https://developers.hive.io/openrpc.json'
      assert_includes llms, 'https://developers.hive.io/openapi.json'

      agents = File.read(File.join(site_dir, 'quickstart', 'building_agents.html'))
      assert_includes agents, 'openrpc.json'
      assert_includes agents, 'openapi.json'

      resources = File.read(File.join(site_dir, 'resources', 'index.html'))
      assert_includes resources, 'openrpc.json'
      assert_includes resources, 'openapi.json'

      refute File.exist?(File.join(site_dir, 'es', 'openrpc.json')),
        'Expected openrpc.json only at the site root'
    end
  end

  private

  def parse_jsonish(value)
    return nil if value.nil?
    return value if value.is_a?(Hash) || value.is_a?(Array) || value.is_a?(Numeric) || value == true || value == false

    text = value.to_s.strip
    return nil if text.empty?

    JSON.parse(text)
  rescue JSON::ParserError
    nil
  end

  def validate_params_example(parsed_params, openrpc_method)
    structure = openrpc_method['paramStructure']
    descriptors = Array(openrpc_method['params'])

    if structure == 'by-position'
      values = parsed_params.is_a?(Array) ? parsed_params : [parsed_params]
      errors = []
      descriptors.each_with_index do |descriptor, index|
        next if index >= values.length

        errors.concat(validate_against_schema(values[index], descriptor['schema'], "$.params[#{index}]"))
      end
      errors
    else
      hash = parsed_params.is_a?(Hash) ? parsed_params : nil
      return ["$.params must be an object for by-name methods"] if hash.nil?

      errors = []
      descriptors.each do |descriptor|
        key = descriptor['name']
        next unless hash.key?(key)

        errors.concat(validate_against_schema(hash[key], descriptor['schema'], "$.params.#{key}"))
      end
      errors
    end
  end

  def validate_against_schema(value, schema, path)
    return [] if schema.nil? || schema.empty?

    if schema['anyOf']
      alt_errors = schema['anyOf'].map { |item| validate_against_schema(value, item, path) }
      return [] if alt_errors.any?(&:empty?)

      return ["#{path} does not match any anyOf alternative"]
    end

    types = Array(schema['type']).map(&:to_s)
    unless types.empty? || types.any? { |type| value_matches_type?(value, type) }
      return ["#{path} must be #{types.join(' or ')}, got #{ruby_type(value)}"]
    end

    errors = []
    if value.is_a?(Hash) && (types.include?('object') || schema['properties'])
      Array(schema['properties']).each do |key, property_schema|
        next unless value.key?(key)

        errors.concat(validate_against_schema(value[key], property_schema, "#{path}.#{key}"))
      end
    end

    if value.is_a?(Array) && (types.include?('array') || schema.key?('items'))
      item_schema = schema['items']
      if item_schema.is_a?(Hash)
        value.each_with_index do |item, index|
          errors.concat(validate_against_schema(item, item_schema, "#{path}[#{index}]"))
        end
      end
    end
    errors
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
end
