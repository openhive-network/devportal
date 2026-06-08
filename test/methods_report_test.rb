require_relative 'test_helper'
require_relative '../lib/verify/methods_report'
require 'json'

class MethodsReportTest < Minitest::Test
  include JekyllBuildTestHelper

  def test_compare_method_detects_openapi_cpp_disagreement
    report = Verify::MethodsReport.new(project_root: project_path)

    method = report.compare_method(
      'database_api.verify_account_authority',
      {
        status: 'active',
        obsolete: false,
        parameter_keys: %w[account level signers],
        response_keys: %w[valid]
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

    assert_equal 'mismatch', method.fetch(:classification)
    assert method.fetch(:notes).any? { |note| note.include?('OpenAPI parameter fields differ') }
    assert method.fetch(:notes).any? { |note| note.include?('OpenAPI and C++ parameter fields differ') }
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
