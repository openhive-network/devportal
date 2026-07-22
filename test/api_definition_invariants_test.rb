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
      total_reward_fund_hive
      total_reward_shares2
    ].each do |field|
      assert_includes dgpo['expected_response_json'], %("#{field}")
    end

    # These are genuinely gone from the response. total_reward_fund_hive and
    # total_reward_shares2 used to be listed here too, but the node still
    # returns both (zero valued), so they are documented rather than refuted.
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

  def test_list_proposal_votes_documents_proposal_filtering_and_pagination
    [
      api_method('condenser_api.yml', 'condenser_api.list_proposal_votes'),
      api_method('database_api.yml', 'database_api.list_proposal_votes')
    ].each do |method|
      purpose = method['purpose'].to_s

      assert_includes purpose, 'does not stop when the result set reaches a different proposal'
      assert_includes purpose, 'Filter returned rows by `proposal.id`'
      assert_includes purpose, 'last row\'s `[proposal.id, voter]`'
      assert_includes purpose, '[10, "alice"]'
    end
  end

  def test_account_history_api_agreed_source_shapes_remain_documented
    get_transaction = api_method('account_history_api.yml', 'account_history_api.get_transaction')
    assert_equal %w[id include_reversible], get_transaction['parameter_json'].keys.sort
    assert_equal %w[
      block_num
      expiration
      extensions
      operations
      ref_block_num
      ref_block_prefix
      signatures
      transaction_id
      transaction_num
    ], JSON.parse(get_transaction['expected_response_json']).keys.sort

    enum_virtual_ops = api_method('account_history_api.yml', 'account_history_api.enum_virtual_ops')
    assert_equal %w[next_block_range_begin next_operation_begin ops ops_by_block],
      JSON.parse(enum_virtual_ops['expected_response_json']).keys.sort

    yaml = File.read(project_path('_data', 'apidefinitions', 'account_history_api.yml'))
    get_transaction_block = yaml.split(/^    - api_method: /).find do |method_block|
      method_block.start_with?('account_history_api.get_transaction')
    end
    assert_equal 1, get_transaction_block.scan(/^      parameter_json:/).size
    assert_equal 1, get_transaction_block.scan(/^      expected_response_json:/).size
  end

  def test_bridge_api_openapi_parameters_remain_documented
    expected_parameters = {
      'bridge.get_account_posts' => %w[account limit observer sort start_author start_permlink],
      'bridge.list_communities' => %w[last limit observer query sort],
      'bridge.list_subscribers' => %w[community last limit],
      'bridge.list_community_roles' => %w[community last limit],
      'bridge.get_relationship_between_accounts' => %w[account1 account2 observer],
      'bridge.get_post' => %w[author observer permlink]
    }

    expected_parameters.each do |method_name, keys|
      method = api_method('bridge.yml', method_name)
      parameters = method['parameter_json']
      parameters = JSON.parse(parameters) if parameters.is_a?(String)
      assert_equal keys, parameters.keys.sort, "Expected #{method_name} parameters to match OpenAPI"
    end

    get_post = JSON.parse(api_method('bridge.yml', 'bridge.get_post')['expected_response_json'])
    %w[
      author_role
      author_title
      community
      community_title
      parent_author
      parent_permlink
      reblogged_by
      reblogs
    ].each { |field| assert get_post.key?(field), "Expected bridge.get_post response to include #{field}" }
    refute get_post.key?('promoted')

    notifications = JSON.parse(api_method('bridge.yml', 'bridge.post_notifications')['expected_response_json'])
    assert_kind_of Array, notifications
    assert_kind_of Hash, notifications.first
  end

  def test_normalize_post_preserves_the_hivemind_runtime_contract
    normalize_post = api_method('bridge.yml', 'bridge.normalize_post')
    parameters = normalize_post['parameter_json']
    parameters = JSON.parse(parameters) if parameters.is_a?(String)
    normalize_response = JSON.parse(normalize_post['expected_response_json'])
    get_post_response = JSON.parse(api_method('bridge.yml', 'bridge.get_post')['expected_response_json'])

    assert_equal ['post'], parameters.keys
    assert_includes normalize_post['purpose'], 'live Bridge endpoint expects the post reference under `post`'
    assert_equal get_post_response.keys.sort, normalize_response.keys.sort
  end

  def test_small_api_schema_fields_remain_synchronized
    debug_generate = JSON.parse(api_method('debug_node_api.yml', 'debug_node_api.debug_generate_blocks')['parameter_json'])
    assert_equal %w[count debug_key miss_blocks skip], debug_generate.keys.sort

    debug_hardfork = JSON.parse(api_method('debug_node_api.yml', 'debug_node_api.debug_set_hardfork')['parameter_json'])
    assert_equal %w[hardfork_id hook_to_tx], debug_hardfork.keys.sort

    debug_vest_price = JSON.parse(api_method('debug_node_api.yml', 'debug_node_api.debug_set_vest_price')['parameter_json'])
    assert_equal %w[hook_to_tx vest_price], debug_vest_price.keys.sort

    db_head = JSON.parse(api_method('hive.yml', 'hive.db_head_state')['expected_response_json'])
    assert_equal %w[db_head_age db_head_block db_head_time], db_head.keys.sort

    reputations = JSON.parse(api_method('reputation_api.yml', 'reputation_api.get_account_reputations')['expected_response_json'])
    assert_equal ['reputations'], reputations.keys
    assert_kind_of Array, reputations['reputations']

    search = JSON.parse(api_method('search_api.yml', 'search_api.find_text')['parameter_json'])
    assert_equal %w[author limit observer pattern sort start_author start_permlink truncate_body], search.keys.sort

    broadcast = JSON.parse(api_method('wallet_bridge_api.yml', 'wallet_bridge_api.broadcast_transaction_synchronous')['expected_response_json'])
    assert_equal %w[block_num expired id rc_cost trx_num], broadcast.keys.sort
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

  def test_wallet_bridge_api_definitions_use_current_positional_contracts
    methods = YAML.load_file(
      project_path('_data', 'apidefinitions', 'wallet_bridge_api.yml')
    ).first.fetch('methods')

    assert_equal 35, methods.length
    methods.each do |method|
      refute_empty method.fetch('purpose').to_s,
        "Expected #{method.fetch('api_method')} to describe its behavior"
      params = method.fetch('parameter_json')
      assert_kind_of Array, params,
        "Expected #{method.fetch('api_method')} parameters to use a positional array"
      next if params.empty?

      assert_equal 1, params.length,
        "Expected #{method.fetch('api_method')} to receive one variant argument"
      assert_kind_of Array, params.first,
        "Expected #{method.fetch('api_method')} variant argument to contain the positional array"
    end
    assert_equal 29, methods.count { |method| !method.fetch('parameter_json').empty? }
    assert_equal 6, methods.count { |method| method.fetch('parameter_json').empty? }

    broadcast = methods.find do |method|
      method['api_method'] == 'wallet_bridge_api.broadcast_transaction_synchronous'
    end
    assert JSON.parse(broadcast.fetch('expected_response_json')).key?('rc_cost')

    dgpo = methods.find do |method|
      method['api_method'] == 'wallet_bridge_api.get_dynamic_global_properties'
    end
    dgpo_response = JSON.parse(dgpo.fetch('expected_response_json'))
    %w[required_actions_partition_percent].each do |field|
      refute dgpo_response.key?(field), "Expected Wallet Bridge DGPO to omit retired #{field}"
    end
    %w[total_reward_fund_hive total_reward_shares2].each do |field|
      assert dgpo_response.key?(field), "Expected Wallet Bridge DGPO to document returned #{field}"
    end

    version = methods.find { |method| method['api_method'] == 'wallet_bridge_api.get_version' }
    assert_equal %w[blockchain_version chain_id fc_revision haf_revision hive_revision node_type],
      JSON.parse(version.fetch('expected_response_json')).keys.sort

    active_witnesses = methods.find do |method|
      method['api_method'] == 'wallet_bridge_api.get_active_witnesses'
    end
    assert_equal [[true]], active_witnesses.fetch('parameter_json')
    assert JSON.parse(active_witnesses.fetch('expected_response_json')).key?('future_witnesses')

    witness_schedule = methods.find do |method|
      method['api_method'] == 'wallet_bridge_api.get_witness_schedule'
    end
    assert_equal [[true]], witness_schedule.fetch('parameter_json')
    witness_response = JSON.parse(witness_schedule.fetch('expected_response_json'))
    assert witness_response.key?('future_shuffled_witnesses')
    refute witness_response.key?('future_changes')
    assert_includes witness_schedule.fetch('purpose'), 'when unavailable'
  end

  def test_adversarial_optional_response_and_compatibility_contracts
    active_witnesses = api_method('database_api.yml', 'database_api.get_active_witnesses')
    assert_equal({ 'include_future' => true }, JSON.parse(active_witnesses.fetch('parameter_json')))
    assert JSON.parse(active_witnesses.fetch('expected_response_json')).key?('future_witnesses')

    signatures = api_method('database_api.yml', 'database_api.verify_signatures')
    assert JSON.parse(signatures.fetch('parameter_json')).key?('required_witness')
    assert_equal true, JSON.parse(signatures.fetch('expected_response_json')).fetch('valid')

    transaction = api_method('transaction_status_api.yml', 'transaction_status_api.find_transaction')
    assert_equal({ 'status' => 'too_old' }, JSON.parse(transaction.fetch('expected_response_json')))

    %w[bridge.get_post bridge.normalize_post].each do |name|
      refute JSON.parse(api_method('bridge.yml', name).fetch('expected_response_json')).key?('post_id')
    end

    active_votes = api_method('condenser_api.yml', 'condenser_api.get_active_votes')
    assert active_votes.fetch('curl_examples').any? { |example| JSON.parse(example).fetch('params').is_a?(Array) }
    assert active_votes.fetch('curl_examples').any? { |example| JSON.parse(example).fetch('params').is_a?(Hash) }

    %w[condenser_api.get_active_witnesses condenser_api.get_witness_schedule].each do |name|
      assert_equal [true], api_method('condenser_api.yml', name).fetch('parameter_json')
    end

    database_witnesses = api_method('database_api.yml', 'database_api.get_witness_schedule')
    assert_equal({ 'include_future' => true }, JSON.parse(database_witnesses.fetch('parameter_json')))
    assert JSON.parse(database_witnesses.fetch('expected_response_json')).key?('future_shuffled_witnesses')
    refute JSON.parse(database_witnesses.fetch('expected_response_json')).key?('future_changes')

    condenser_witnesses = api_method('condenser_api.yml', 'condenser_api.get_witness_schedule')
    refute condenser_witnesses.fetch('expected_response_json').key?('future_changes')

    lookup_names = api_method('condenser_api.yml', 'condenser_api.lookup_account_names')
    assert_equal [['hiveio'], true], lookup_names.fetch('parameter_json')

    conversions = api_method('condenser_api.yml', 'condenser_api.get_conversion_requests')
    assert_equal ['hiveio'], conversions.fetch('parameter_json')

    %w[bridge.get_ranked_posts bridge.get_account_posts].each do |name|
      response = JSON.parse(api_method('bridge.yml', name).fetch('expected_response_json'))
      assert_kind_of Integer, response.first.fetch('reblogs')
    end

    %w[
      condenser_api.get_blog
      condenser_api.get_blog_entries
      condenser_api.get_comment_discussions_by_payout
      condenser_api.get_content
      condenser_api.get_content_replies
      condenser_api.get_discussions_by_author_before_date
      condenser_api.get_follow_count
      condenser_api.get_followers
      condenser_api.get_following
      condenser_api.get_reblogged_by
      condenser_api.get_trending_tags
    ].each do |name|
      method = api_method('condenser_api.yml', name)
      assert_equal 'deprecated', method.fetch('status')
      assert_includes method.fetch('purpose'), 'public Hive API still routes'
    end
  end

  def test_all_curl_examples_are_strict_json
    Dir[project_path('_data', 'apidefinitions', '*.yml')].sort.each do |file|
      Array(YAML.load_file(file)).each do |section|
        Array(section['methods']).each do |method|
          Array(method['curl_examples']).each_with_index do |example, index|
            JSON.parse(example)
          rescue JSON::ParserError => error
            flunk "Invalid curl example #{index} for #{method['api_method']} in #{File.basename(file)}: #{error.message}"
          end
        end
      end
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

  def test_condenser_api_current_response_shapes_remain_documented
    %w[get_accounts lookup_account_names].each do |method_name|
      response = JSON.parse(
        api_method('condenser_api.yml', "condenser_api.#{method_name}").fetch('expected_response_json')
      )
      assert_kind_of Array, response
      assert_kind_of Hash, response.first
    end

    broadcast = api_method(
      'condenser_api.yml',
      'condenser_api.broadcast_transaction_synchronous'
    ).fetch('expected_response_json')
    assert broadcast.key?('rc_cost')

    fields_by_method = {
      'get_chain_properties' => %w[account_subsidy_budget account_subsidy_decay],
      'get_dynamic_global_properties' => %w[
        available_account_subsidies current_remove_threshold dhf_interval_ledger
        max_consecutive_recurrent_transfer_failures next_daily_maintenance_time
      ],
      'get_feed_history' => %w[current_min_history current_max_history market_median_history],
      'get_version' => %w[chain_id haf_revision node_type],
      'get_witness_schedule' => %w[
        account_subsidy_rd account_subsidy_witness_rd elected_weight
        min_witness_account_subsidy_decay
      ]
    }

    fields_by_method.each do |method_name, fields|
      response = api_method(
        'condenser_api.yml', "condenser_api.#{method_name}"
      ).fetch('expected_response_json')
      fields.each { |field| assert response.key?(field), "Expected #{method_name} to include #{field}" }
    end

    refute api_method(
      'condenser_api.yml', 'condenser_api.get_chain_properties'
    ).fetch('expected_response_json').key?('account_subsidy_limit')
    refute api_method(
      'condenser_api.yml', 'condenser_api.get_witness_schedule'
    ).fetch('expected_response_json').key?('top19_weight')
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
