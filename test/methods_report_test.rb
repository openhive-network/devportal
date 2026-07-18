require_relative 'test_helper'
require_relative '../lib/verify/methods_report'
require 'json'

class MethodsReportTest < Minitest::Test
  include JekyllBuildTestHelper

  def test_compare_method_verifies_docs_that_match_cpp_when_openapi_disagrees
    report = Verify::MethodsReport.new(project_root: project_path)

    method = report.compare_method(
      'database_api.verify_account_authority',
      {
        status: 'active',
        obsolete: false,
        parameter_keys: %w[account level signers],
        response_keys: %w[valid],
        parameter_shape: 'object',
        response_shape: 'object'
      },
      {
        request_keys: %w[account signers],
        response_keys: %w[valid],
        source_references: []
      },
      {
        args_keys: %w[account level signers],
        return_keys: %w[valid],
        source_references: []
      }
    )

    assert_equal 'verified', method.fetch(:classification)
    assert method.fetch(:source_disagreement)
    assert method.fetch(:notes).any? { |note| note.include?('OpenAPI parameter fields differ') }
    assert method.fetch(:notes).any? { |note| note.include?('OpenAPI and C++ parameter fields differ') }
  end

  def test_compare_method_reports_mismatch_when_docs_match_neither_source
    report = Verify::MethodsReport.new(project_root: project_path)

    method = report.compare_method(
      'sample_api.get_thing',
      {
        status: 'active',
        obsolete: false,
        parameter_keys: %w[legacy_id],
        response_keys: %w[legacy_value],
        parameter_shape: 'object',
        response_shape: 'object'
      },
      {
        request_keys: %w[id],
        response_keys: %w[value],
        source_references: []
      },
      {
        args_keys: %w[id include_future],
        return_keys: %w[value],
        source_references: []
      }
    )

    assert_equal 'mismatch', method.fetch(:classification)
    assert method.fetch(:notes).any? { |note| note.include?('OpenAPI parameter fields differ') }
    assert method.fetch(:notes).any? { |note| note.include?('C++ parameter fields differ') }
  end

  def test_compare_method_verifies_positional_openapi_shapes
    report = Verify::MethodsReport.new(project_root: project_path)

    method = report.compare_method(
      'condenser_api.get_accounts',
      {
        status: 'active',
        obsolete: false,
        parameter_keys: [],
        response_keys: [],
        parameter_shape: 'array',
        response_shape: 'array'
      },
      {
        request_keys: nil,
        response_keys: nil,
        request_shape: 'array',
        response_shape: 'array',
        source_references: []
      },
      nil
    )

    assert_equal 'verified', method.fetch(:classification)
    assert_empty method.fetch(:notes)
  end

  def test_documented_shapes_accept_yaml_native_values_and_scalar_examples
    report = Verify::MethodsReport.new(project_root: project_path)

    assert_equal %w[id name], report.send(:json_top_level_keys, { 'name' => 'alice', 'id' => 1 })
    assert_equal 'object', report.send(:json_shape, { 'id' => 1 })
    assert_equal 'array', report.send(:json_shape, [{ 'id' => 1 }])
    assert_equal 'null', report.send(:json_shape, nil)
    assert_equal 'string', report.send(:json_shape, '')
  end

  def test_cpp_source_resolves_wallet_bridge_shapes_and_cross_api_aliases
    Dir.mktmpdir('cpp-source-') do |root|
      apis_root = File.join(root, 'apis')
      database_dir = File.join(apis_root, 'database_api')
      wallet_dir = File.join(apis_root, 'wallet_bridge_api')
      FileUtils.mkdir_p(database_dir)
      FileUtils.mkdir_p(wallet_dir)

      File.write(
        File.join(database_dir, 'database_api.hpp'),
        <<~CPP
          struct shared_result {};
          typedef shared_result get_shared_return;
          FC_REFLECT(database_api::shared_result, (id)(value))
        CPP
      )
      File.write(
        File.join(wallet_dir, 'wallet_bridge_api.hpp'),
        <<~CPP
          typedef variant get_shared_args;
          typedef database_api::get_shared_return get_shared_return;
          typedef variant list_items_args;
          typedef std::vector<database_api::shared_result> list_items_return;
          typedef variant maybe_item_args;
          typedef fc::optional<database_api::shared_result> maybe_item_return;
          DECLARE_API((get_shared)(list_items)(maybe_item));
        CPP
      )

      methods = Verify::CppSource.new(apis_root, project_root: root).load.fetch(:methods)
      get_shared = methods.fetch('wallet_bridge_api.get_shared')
      list_items = methods.fetch('wallet_bridge_api.list_items')
      maybe_item = methods.fetch('wallet_bridge_api.maybe_item')

      assert_equal 'array', get_shared.fetch(:args_shape)
      assert_equal 'object', get_shared.fetch(:return_shape)
      assert_equal %w[id value], get_shared.fetch(:return_keys)
      assert_equal 'array', list_items.fetch(:return_shape)
      assert_equal 'object|null', maybe_item.fetch(:return_shape)
    end
  end

  def test_compare_method_classifies_source_only_and_docs_only
    report = Verify::MethodsReport.new(project_root: project_path)

    source_only = report.compare_method(
      'block_api.get_block',
      nil,
      { request_keys: %w[block_num], response_keys: %w[block], source_references: [] },
      nil
    )
    docs_only = report.compare_method(
      'fake_api.missing',
      { status: 'active', obsolete: false, parameter_keys: [], response_keys: [] },
      nil,
      nil
    )

    assert_equal 'source_only', source_only.fetch(:classification)
    assert_equal 'docs_only', docs_only.fetch(:classification)
  end

  def test_write_generates_json_and_markdown_to_reports_dir
    Dir.mktmpdir('methods-report-') do |root|
      project_root = File.join(root, 'devportal')
      hive_root = File.join(root, 'hive')
      reports_dir = File.join(project_root, 'reports')

      FileUtils.mkdir_p(File.join(project_root, '_data', 'apidefinitions'))
      File.write(
        File.join(project_root, '_data', 'apidefinitions', 'sample_api.yml'),
        [
          {
            'name' => 'sample_api',
            'methods' => [
              {
                'api_method' => 'sample_api.get_thing',
                'parameter_json' => '{"id":0}',
                'expected_response_json' => '{"thing":null,"extra":true}'
              },
              {
                'api_method' => 'sample_api.no_params',
                'parameter_json' => '{}',
                'expected_response_json' => '{"ok":true}'
              }
            ]
          }
        ].to_yaml
      )

      apis_root = File.join(hive_root, 'libraries', 'plugins', 'apis')
      FileUtils.mkdir_p(File.join(apis_root, 'documentation'))
      File.write(
        File.join(apis_root, 'documentation', 'openapi.json'),
        JSON.pretty_generate(
          'paths' => {
            'sample_api.get_thing' => {
              'post' => {
                'requestBody' => {
                  'content' => {
                    'application/json' => {
                      'schema' => { '$ref' => '#/components/schemas/get_thing' }
                    }
                  }
                },
                'responses' => {
                  '200' => {
                    'content' => {
                      'application/json' => {
                        'schema' => { '$ref' => '#/components/schemas/get_thing_response' }
                      }
                    }
                  }
                }
            }
          },
          'sample_api.no_params' => {
            'post' => {
              'responses' => {
                '200' => {
                  'content' => {
                    'application/json' => {
                      'schema' => { '$ref' => '#/components/schemas/no_params_response' }
                    }
                  }
                }
              }
            }
          }
        },
          'components' => {
            'schemas' => {
              'get_thing' => {
                '$ref' => '#/components/schemas/get_thing_alias'
              },
              'get_thing_alias' => {
                'type' => 'object',
                'properties' => { 'id' => { 'type' => 'integer' } }
              },
              'get_thing_response' => {
                'allOf' => [
                  { '$ref' => '#/components/schemas/get_thing_response_base' },
                  {
                    'type' => 'object',
                    'properties' => { 'extra' => { 'type' => 'boolean' } }
                  }
                ]
              },
              'get_thing_response_base' => {
                'type' => 'object',
                'properties' => { 'thing' => { 'type' => 'object' } }
              },
              'no_params_response' => {
                'type' => 'object',
                'properties' => { 'ok' => { 'type' => 'boolean' } }
              }
            }
          }
        )
      )
      FileUtils.mkdir_p(File.join(apis_root, 'sample_api'))
      File.write(
        File.join(apis_root, 'sample_api', 'sample_api.cpp'),
        <<~CPP
          DECLARE_API((get_thing))
          DEFINE_API_IMPL( sample_api_impl, get_thing )
          {
          }
          struct get_thing_args { int id; };
          struct get_thing_return { int thing; };
          FC_REFLECT( hive::plugins::sample_api::get_thing_args,
            (id) )
          FC_REFLECT( hive::plugins::sample_api::get_thing_return,
            (thing)(extra) )
          DECLARE_API((no_params))
          DEFINE_API_IMPL( sample_api_impl, no_params )
          {
          }
          typedef void_type no_params_args;
          struct no_params_return { bool ok; };
          FC_REFLECT( hive::plugins::sample_api::no_params_return,
            (ok) )
        CPP
      )

      result = Verify::MethodsReport.new(
        project_root: project_root,
        hive_root: hive_root,
        reports_dir: reports_dir
      ).write

      assert File.exist?(result.fetch(:json))
      assert File.exist?(result.fetch(:markdown))
      assert_equal 2, result.fetch(:report).fetch(:summary).fetch(:method_count)
      assert_equal 2, result.fetch(:report).fetch(:summary).fetch(:classifications).fetch('verified')
      assert_includes File.read(result.fetch(:markdown)), 'sample_api'
    end
  end
end
