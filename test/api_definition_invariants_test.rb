require_relative 'test_helper'

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
end
