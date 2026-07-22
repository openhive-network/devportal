require_relative 'test_helper'

class JekyllBuildAssertionsTest < Minitest::Test
  include JekyllBuildTestHelper

  def test_vendor_is_excluded_and_full_layout_content_is_rendered
    vendor_existed = Dir.exist?(project_path('vendor'))
    sentinel = project_path('vendor', 'clawpatch-jekyll-exclude-sentinel.txt')
    FileUtils.mkdir_p(File.dirname(sentinel))
    File.write(sentinel, 'This file must not be copied into generated site output.')

    begin
      site_dir_for_assertions do |site_dir|
        refute File.exist?(File.join(site_dir, 'vendor', 'clawpatch-jekyll-exclude-sentinel.txt')),
          'Expected vendor sentinel to be excluded from generated site output'

        rendered_page = File.join(site_dir, 'nodeop', 'drone.html')
        assert_file_includes rendered_page, '<h3 id="drone">Drone</h3>'
        assert_file_excludes rendered_page, '### Drone'
      end
    ensure
      FileUtils.rm_f(sentinel)
      vendor_path = project_path('vendor')
      FileUtils.rmdir(vendor_path) if !vendor_existed && Dir.exist?(vendor_path) && Dir.empty?(vendor_path)
    end
  end

  def test_layout_and_api_template_guards_use_rendered_content_fields
    assert_file_excludes project_path('_layouts', 'full.html'), 'page.content'
    assert_file_excludes project_path('_layouts', 'main-script.html'), 'page.content'
    assert_file_includes project_path('_includes', 'api-template.html'), '{% if method.expected_response_json %}'
  end

  def test_main_script_layout_renders_markdown_descriptions
    site_dir_for_assertions do |site_dir|
      resources_index = File.join(site_dir, 'resources', 'index.html')

      assert_file_includes resources_index, '<em>SDK and client library links for building Hive applications.</em>'
      assert_file_excludes resources_index, '_SDK and client library links for building Hive applications._'
    end
  end

  def test_main_stylesheet_url_is_cache_busted
    site_dir_for_assertions do |site_dir|
      index = File.join(site_dir, 'index.html')

      assert_match %r{href="/css/style\.css\?v=\d+"}, File.read(index)
    end
  end

  def test_api_metadata_layout_does_not_need_content_spacer_hacks
    assert_file_includes project_path('_includes', 'api-template.html'), 'class="api-method-metadata"'
    assert_file_includes project_path('_includes', 'api-template.html'), 'class="api-method" markdown="1"'
    assert_file_includes project_path('_includes', 'api-template.html'), 'class="api-method-summary"'
    assert_file_excludes project_path('_includes', 'api-template.html'), 'style="float: right; list-style: none;"'
    assert_file_excludes project_path('_apidefinitions', 'broadcast-ops.md'), 'style="float: right; list-style: none;"'
    assert_file_excludes project_path('_apidefinitions', 'broadcast-ops-customs.md'), 'style="float: right; list-style: none;"'

    Dir[project_path('_data', 'apidefinitions', '*.yml')].each do |file_name|
      assert_file_excludes file_name, '<p>&nbsp;</p>'
    end
  end

  def test_header_logo_links_to_site_root
    assert_file_includes project_path('_layouts', 'default.html'), '<a href="{{ \'/\' | relative_url }}"  class="logo-link">'
    assert_file_excludes project_path('_sass', '_main.scss'), 'pointer-events: none;'
    assert_file_excludes project_path('_sass', '_main.scss'), 'cursor: default;'
  end

  def test_theme_switch_is_available_below_language_switch
    sidebar = File.read(project_path('_includes', 'sidebar.html'))
    assert_match %r{<div class="lang-switch">.*<div class="theme-switch" aria-label="Theme">}m, sidebar
    assert_file_includes project_path('_includes', 'sidebar.html'), 'data-theme-option="light"'
    assert_file_includes project_path('_includes', 'sidebar.html'), 'data-theme-option="dark"'
    assert_file_includes project_path('_includes', 'sidebar.html'), 'data-theme-option="system"'
    assert_file_includes project_path('_includes', 'sidebar.html'), 'class="fas fa-sun"'
    assert_file_includes project_path('_includes', 'sidebar.html'), 'class="fas fa-moon"'
    assert_file_includes project_path('_includes', 'sidebar.html'), 'class="fas fa-desktop"'
    assert_file_includes project_path('_layouts', 'default.html'), "localStorage.getItem('hive-devportal-theme')"
    assert_file_includes project_path('_layouts', 'default.html'), "localStorage.setItem('hive-devportal-theme', theme)"
    assert_file_includes project_path('_sass', '_main.scss'), "html[data-theme='dark']"
    assert_file_includes project_path('_sass', '_main.scss'), "html[data-theme='system']"
  end

  def test_api_definition_nav_positions_are_alphabetical
    expected_order = [
      'account-by-key-api.md',
      'account-history-api.md',
      'app-status-api.md',
      'block-api.md',
      'bridge.md',
      'chain-api.md',
      'condenser-api.md',
      'database-api.md',
      'debug-node-api.md',
      'follow-api.md',
      'hive.md',
      'jsonrpc.md',
      'market-history-api.md',
      'network-broadcast-api.md',
      'network-node-api.md',
      'node-status-api.md',
      'rc-api.md',
      'reputation-api.md',
      'rewards-api.md',
      'search-api.md',
      'tags-api.md',
      'transaction-status-api.md',
      'wallet-bridge-api.md',
      'witness-api.md',
      'broadcast-ops.md',
      'broadcast-ops-customs.md'
    ]

    actual_order = Dir[project_path('_apidefinitions', '*.md')]
      .reject { |path| File.basename(path) == '_defaults.md' }
      .sort_by { |path| File.read(path)[/^position:\s*(\d+)/, 1].to_i }
      .map { |path| File.basename(path) }

    assert_equal expected_order, actual_order
    assert_file_includes project_path('_includes', 'sidebar.html'), 'class="nav-group-separated"'
  end

  def test_text_sitemap_lists_public_urls_for_all_locales
    site_dir_for_assertions do |site_dir|
      sitemap_path = File.join(site_dir, 'sitemap.txt')
      assert File.exist?(sitemap_path), 'Expected sitemap.txt to be generated'

      urls = File.readlines(sitemap_path, chomp: true).map(&:strip).reject(&:empty?)

      assert_includes urls, 'https://developers.hive.io/'
      assert_includes urls, 'https://developers.hive.io/es/'
      assert_includes urls, 'https://developers.hive.io/apidefinitions/'
      assert_includes urls, 'https://developers.hive.io/es/apidefinitions/'
      assert_includes urls, 'https://developers.hive.io/quickstart/accounts.html'
      assert_includes urls, 'https://developers.hive.io/es/quickstart/accounts.html'

      urls.each do |url|
        assert_match %r{\Ahttps://developers\.hive\.io/}, url
        refute_match %r{/search/?\z}, url
        refute_match %r{/sitemap\.txt\z}, url
        refute_match %r{\.(css|js|png|svg|ico|gif|jpg|jpeg|xml)\z}, url
      end

      assert_urls_resolve_to_built_files(urls, site_dir, 'sitemap.txt')

      assert_equal urls, urls.uniq, 'Expected sitemap.txt URLs to be unique'

      Dir[File.join(site_dir, '*', 'sitemap.txt')].each do |localized_sitemap|
        flunk "Expected sitemap.txt to be generated only at the site root, but found #{localized_sitemap}"
      end
    end
  end

  def test_build_output_excludes_source_and_nested_destination_artifacts
    site_dir_for_assertions do |site_dir|
      assert_empty Dir[File.join(site_dir, '**', 'public')],
        'Expected generated site not to contain nested public directories'
      assert_empty Dir[File.join(site_dir, '**', 'test', '*')],
        'Expected generated site not to contain test files'
      assert_empty Dir[File.join(site_dir, '**', 'Rakefile')],
        'Expected generated site not to contain Rakefile'
      assert_empty Dir[File.join(site_dir, '**', '.gitlab-ci.yml')],
        'Expected generated site not to contain GitLab CI config'
      assert_empty Dir[File.join(site_dir, '**', 'deploy.log')],
        'Expected generated site not to contain local deploy logs'
    end
  end

  def test_llms_txt_lists_english_documentation_index
    site_dir_for_assertions do |site_dir|
      llms_path = File.join(site_dir, 'llms.txt')
      assert File.exist?(llms_path), 'Expected llms.txt to be generated'

      content = File.read(llms_path)
      urls = content.scan(%r{https://developers\.hive\.io/[^\)\s]+})

      assert_includes content, '# Hive Developers'
      assert_includes content, 'Hive Developer Documentation.'
      assert_includes content, '[Introduction](https://developers.hive.io/)'
      assert_includes content, '](https://developers.hive.io/quickstart/)'
      assert_includes content, '[JSON-RPC API](https://developers.hive.io/apidefinitions/)'
      assert_includes content, '[Accounts](https://developers.hive.io/quickstart/accounts.html)'
      assert_includes content, '[Account By Key API](https://developers.hive.io/apidefinitions/#apidefinitions-account-by-key-api)'

      urls.each do |url|
        assert_match %r{\Ahttps://developers\.hive\.io/}, url
        refute_match %r{/es/}, url
        refute_match %r{/search/?\z}, url
        refute_match %r{/sitemap\.txt\z}, url
        refute_match %r{/llms\.txt\z}, url
        refute_match %r{\.(css|js|png|svg|ico|gif|jpg|jpeg|xml)\z}, url
      end

      assert_urls_resolve_to_built_files(urls, site_dir, 'llms.txt')

      assert_equal urls, urls.uniq, 'Expected llms.txt URLs to be unique'

      Dir[File.join(site_dir, '*', 'llms.txt')].each do |localized_llms|
        flunk "Expected llms.txt to be generated only at the site root, but found #{localized_llms}"
      end
    end
  end

  def test_production_build_without_analytics_key_omits_gtag
    build_site(env: 'production') do |site_dir|
      index = File.join(site_dir, 'index.html')
      assert_file_excludes index, 'googletagmanager.com/gtag/js?id='
      assert_file_excludes index, "gtag('config'"
    end
  end
end
