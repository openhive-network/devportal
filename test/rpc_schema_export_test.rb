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
        assert openapi.dig('paths', "/#{name}", 'post'), "Expected OpenAPI path /#{name}"
      end

      condenser = openrpc['methods'].find { |method| method['name'] == 'condenser_api.get_dynamic_global_properties' }
      assert_equal 'array', condenser.dig('params', 0, 'schema', 'type')

      database = openrpc['methods'].find { |method| method['name'] == 'database_api.find_accounts' }
      assert_equal 'object', database.dig('params', 0, 'schema', 'type')
      assert database.dig('params', 0, 'schema', 'properties', 'accounts')

      refute openrpc['methods'].any? { |method| method['name'].to_s.start_with?('broadcast_ops') }
    end
  end

  def test_built_site_publishes_schema_and_links_it
    site_dir_for_assertions do |site_dir|
      openrpc_path = File.join(site_dir, 'openrpc.json')
      openapi_path = File.join(site_dir, 'openapi.json')
      assert File.exist?(openrpc_path), 'Expected openrpc.json in the Jekyll build'
      assert File.exist?(openapi_path), 'Expected openapi.json in the Jekyll build'

      openrpc = JSON.parse(File.read(openrpc_path))
      names = openrpc['methods'].map { |method| method['name'] }
      EXPECTED_METHODS.each { |name| assert_includes names, name }

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
end
