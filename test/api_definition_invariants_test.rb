require_relative 'test_helper'
require 'json'

class ApiDefinitionInvariantsTest < Minitest::Test
  include JekyllBuildTestHelper

  def test_verify_account_authority_is_documented_as_callable
    method = api_method('database_api.yml', 'database_api.verify_account_authority')

    refute method['disabled'], 'database_api.verify_account_authority should not be marked disabled'
    refute_match(/not implemented/i, method['purpose'].to_s)
    assert_file_includes project_path('_data', 'apidefinitions', 'database_api.yml'), 'database_api.verify_account_authority'
  end

  def test_historical_api_definition_regressions_remain_fixed
    find_comments = api_method('database_api.yml', 'database_api.find_comments')
    assert_includes find_comments['parameter_json'].to_s, '"comments"'
    refute_includes find_comments['parameter_json'].to_s, '"start"'

    get_transaction = api_method('account_history_api.yml', 'account_history_api.get_transaction')
    assert_includes get_transaction['purpose'], 'include_reversible'

    assert_equal 'obsolete', api_method('tags_api.yml', 'tags_api.get_active_votes')['status']
    assert api_method('block_api.yml', 'block_api.get_block_range')
    assert api_method('database_api.yml', 'database_api.get_comment_pending_payouts')
    assert api_method('database_api.yml', 'database_api.is_known_transaction')
    assert api_method('condenser_api.yml', 'condenser_api.is_known_transaction')
    assert_equal 'HF23', api_method('transaction_status_api.yml', 'transaction_status_api.find_transaction')['since']
  end

  def test_database_api_agreed_source_shapes_remain_documented
    find_savings_withdrawals = api_method('database_api.yml', 'database_api.find_savings_withdrawals')
    assert_includes find_savings_withdrawals['parameter_json'], '"account"'
    refute_includes find_savings_withdrawals['parameter_json'], '"start"'

    get_active_witnesses = api_method('database_api.yml', 'database_api.get_active_witnesses')
    assert_includes get_active_witnesses['expected_response_json'], '"future_witnesses"'

    get_feed_history = api_method('database_api.yml', 'database_api.get_feed_history')
    %w[current_min_history current_max_history market_median_history].each do |field|
      assert_includes get_feed_history['expected_response_json'], %("#{field}")
    end

    dgpo = api_method('database_api.yml', 'database_api.get_dynamic_global_properties')
    %w[
      current_remove_threshold
      dhf_interval_ledger
      early_voting_seconds
      max_consecutive_recurrent_transfer_failures
      max_open_recurrent_transfers
      max_recurrent_transfer_end_date
      mid_voting_seconds
      min_recurrent_transfers_recurrence
      next_daily_maintenance_time
      proposal_fund_percent
      vote_power_reserve_rate
    ].each do |field|
      assert_includes dgpo['expected_response_json'], %("#{field}")
    end

    %w[
      confidential_hbd_supply
      confidential_supply
      required_actions_partition_percent
      smt_creation_fee
      sps_fund_percent
      sps_interval_ledger
      target_votes_per_period
    ].each do |field|
      refute_includes dgpo['expected_response_json'], %("#{field}")
    end

    list_proposals = api_method('database_api.yml', 'database_api.list_proposals')
    assert_includes list_proposals['parameter_json'], '"last_id"'
  end

  def test_database_api_methods_have_single_client_docs_block
    yaml = File.read(project_path('_data', 'apidefinitions', 'database_api.yml'))
    yaml.split(/^  - api_method: /).drop(1).each do |method_block|
      method_name = method_block.lines.first.to_s.strip
      client_docs_blocks = method_block.scan(/^    client_docs:/).size

      assert_operator client_docs_blocks, :<=, 1,
        "Expected #{method_name} to define at most one client_docs block"
    end
  end

  def test_condenser_discussion_query_parameters_match_openapi
    common_keys = %w[limit observer start_author start_permlink tag truncate_body]
    %w[
      condenser_api.get_discussions_by_blog
      condenser_api.get_discussions_by_created
      condenser_api.get_discussions_by_feed
      condenser_api.get_discussions_by_hot
      condenser_api.get_discussions_by_trending
      condenser_api.get_post_discussions_by_payout
    ].each do |method_name|
      parameters = JSON.parse(api_method('condenser_api.yml', method_name)['parameter_json'])
      assert_equal common_keys, parameters.keys.sort, "Expected #{method_name} query fields to match OpenAPI"
    end

    %w[
      condenser_api.get_discussions_by_comments
      condenser_api.get_replies_by_last_update
    ].each do |method_name|
      parameters = JSON.parse(api_method('condenser_api.yml', method_name)['parameter_json'])
      assert_equal %w[limit observer start_author start_permlink truncate_body], parameters.keys.sort,
        "Expected #{method_name} query fields to match OpenAPI"
    end
  end

  def test_get_active_votes_preserves_the_live_positional_contract
    parameters = api_method('condenser_api.yml', 'condenser_api.get_active_votes')['parameter_json']

    assert_kind_of Array, parameters
    assert_equal 2, parameters.length
  end

  def test_hosted_openapi_links_use_openapi_glyph
    stylesheet = File.read(project_path('_sass', '_main.scss'))

    assert_includes stylesheet, "a[href*='api.hive.blog/?urls.primaryName=Legacy+Hive+JSON-RPC+API']"
    assert_match(
      /api\.hive\.blog\/\?urls\.primaryName=Legacy\+Hive\+JSON-RPC\+API'[^}]+languages\/openapi\.svg/m,
      stylesheet
    )
  end

  def test_all_openapi_sdk_references_use_hosted_hive_swagger
    hosted_swagger_url = 'https://api.hive.blog/?urls.primaryName=Legacy+Hive+JSON-RPC+API#/'
    links = Dir.glob(project_path('_data', '**', '*.{yml,yaml}')).flat_map do |path|
      File.readlines(path).grep(/\[openApi\]\(/).map { |line| [path, line.strip] }
    end

    refute_empty links
    links.each do |path, link|
      assert_includes link, hosted_swagger_url,
        "Expected #{path} openApi reference to use hosted Hive Swagger: #{link}"
      refute_match(%r{gitlab\.syncad\.com|petstore\.swagger\.io|/openapi/}, link)
    end
  end

  def test_openapi_covered_methods_have_sdk_reference
    hosted_swagger_url = 'https://api.hive.blog/?urls.primaryName=Legacy+Hive+JSON-RPC+API#/'
    covered_methods = File.readlines(project_path('test', 'fixtures', 'hived_openapi_methods.txt'), chomp: true).map do |line|
      line.split("\t", 2)
    end
    methods_by_name = all_api_method_entries.each_with_object({}) do |method, index|
      index[method.fetch('api_method')] = method
    end

    covered_methods.each do |method_name, swagger_anchor|
      method = methods_by_name.fetch(method_name) { flunk "Expected #{method_name} to be documented" }
      expected_link = "[openApi](#{hosted_swagger_url}#{swagger_anchor})"
      openapi_links = Array(method['client_docs']).select { |link| link.include?('[openApi]') }

      assert_equal [expected_link], openapi_links,
        "Expected #{method_name} to have exactly one hosted openApi SDK reference"
    end
  end

  def test_openapi_sdk_references_are_ordered_consistently
    client_doc_entries.each do |name, client_docs|
      next unless client_docs.any? { |link| link.include?('[openApi]') }

      labels = client_docs.map { |link| client_doc_label(link) }
      assert_equal labels.sort_by { |label| client_doc_label_sort_key(label) }, labels,
        "Expected #{name} client_docs to use canonical SDK Reference ordering"
    end
  end

  def test_duplicate_swagger_operation_ids_do_not_get_ambiguous_openapi_links
    %w[
      condenser_api.get_transaction
      condenser_api.get_transaction_hex
    ].each do |method_name|
      method = api_method('condenser_api.yml', method_name)

      refute Array(method['client_docs']).any? { |link| link.include?('[openApi]') },
        "Expected #{method_name} to avoid an ambiguous hosted Swagger deep link"
    end
  end

  def test_new_broadcast_operations_remain_documented
    ops = YAML.load_file(project_path('_data', 'apidefinitions', 'broadcast_ops.yml')).first.fetch('ops')
    names = ops.map { |entry| entry['name'] }

    %w[
      update_proposal
      hardfork_hive
      hardfork_hive_restore
      delayed_voting
      consolidate_treasury_balance
      effective_comment_vote
      ineffective_delete_comment
      sps_convert
    ].each do |operation|
      assert_includes names, operation
    end
  end

  private

  def all_api_definition_groups
    Dir.glob(project_path('_data', 'apidefinitions', '*.yml')).flat_map do |path|
      YAML.load_file(path)
    end
  end

  def all_api_method_entries
    all_api_definition_groups.flat_map { |group| Array(group['methods']) }
  end

  def client_doc_entries
    all_api_definition_groups.flat_map do |group|
      Array(group['methods']).map { |method| [method['api_method'], Array(method['client_docs'])] } +
        Array(group['ops']).map { |op| ["broadcast_ops.#{op['name']}", Array(op['client_docs'])] }
    end
  end

  def client_doc_label(link)
    link[/\[([^\]]+)\]/, 1].to_s
  end

  def client_doc_label_sort_key(label)
    rank = {
      'openApi' => 0,
      'hivexplorer' => 1,
      'hive-js' => 2,
      'beem' => 3,
      'hive-ruby' => 4,
      'hivesql' => 5
    }
    [rank.fetch(label, 99), label]
  end
end
