require_relative 'test_helper'

class JavascriptTutorialRegressionsTest < Minitest::Test
  include JekyllBuildTestHelper

  def test_get_account_comments_no_longer_recommends_get_state
    sources = [project_path('_tutorials-javascript', 'get_account_comments.md')]
    sources += Dir[project_path('tutorials', 'javascript', '09_get_account_comments', '**', '*')].select { |path| File.file?(path) }

    sources.each do |source_path|
      source = File.read(source_path)
      refute_match(/\bget_state\b/, source, "#{source_path} should not use deprecated get_state")
      refute_match(/\bgetState\b/, source, "#{source_path} should not use deprecated getState")
    end
  end

  def test_claim_rewards_uses_dhive_private_key_and_no_sc2_dependency
    markdown = File.read(project_path('_tutorials-javascript', 'claim_rewards.md'))
    app_js = File.read(project_path('tutorials', 'javascript', '23_claim_rewards', 'public', 'app.js'))
    package_json = File.read(project_path('tutorials', 'javascript', '23_claim_rewards', 'package.json'))

    assert_includes markdown, "require('@hiveio/dhive')"
    assert_includes markdown, 'dhive.PrivateKey.fromString'
    assert_includes app_js, "require('@hiveio/dhive')"
    assert_includes app_js, 'dhive.PrivateKey.fromString'
    assert_includes package_json, '"@hiveio/dhive"'

    [markdown, app_js, package_json].each do |source|
      refute_match(/\bsc2\b/i, source)
    end
  end
end
