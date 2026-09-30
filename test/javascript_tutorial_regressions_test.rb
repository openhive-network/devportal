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

  def test_workerbee_errors_reconnect_uses_async_iterable_adapter
    markdown = File.read(project_path('_tutorials-recipes', 'workerbee-errors-reconnect.md'))
    code_blocks = markdown.scan(/```(?:typescript|ts|js|javascript)?\n(.*?)```/m).map(&:first).join("\n")

    # Published @hiveio/workerbee@1.28.4-rc1 returns AsyncIterator from iterate(),
    # not AsyncIterable — code samples must not for-await the raw iterate() result.
    refute_match(
      /for await\s*\([^)]*\bof\s+bot\.iterate\s*\(/,
      code_blocks,
      'workerbee-errors-reconnect code samples must not for-await bot.iterate(...) directly'
    )
    assert_includes code_blocks, 'asAsyncIterable'
    assert_includes code_blocks, 'asAsyncIterable(bot.iterate(true))'
    assert_match(
      /asAsyncIterable\(\s*\n?\s*bot\.iterate\(\(err\)/,
      code_blocks,
      'soft-error iterate sample should also go through asAsyncIterable'
    )
  end

  def test_workerbee_errors_reconnect_subscribes_initial_bot
    markdown = File.read(project_path('_tutorials-recipes', 'workerbee-errors-reconnect.md'))
    code_blocks = markdown.scan(/```(?:typescript|ts|js|javascript)?\n(.*?)```/m).map(&:first).join("\n")

    assert_includes code_blocks, 'function subscribeLive'
    # Initial subscription must appear after connect(0), not only inside reconnect.
    assert_match(
      /let \{ bot, endpointIndex \} = await connect\(0\);.*subscribeLive\(bot,/m,
      code_blocks,
      'reconnect sample must subscribe the initial bot after connect(0)'
    )
    # Shared helper used from reconnect path as well
    assert_match(
      /\(\{ bot, endpointIndex \} = await connect\(endpointIndex \+ 1\)\);\s*\n\s*subscribeLive\(bot,/m,
      code_blocks,
      'reconnect path must resubscribe via subscribeLive'
    )
  end
end
