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

  def test_api_metadata_layout_does_not_need_content_spacer_hacks
    assert_file_includes project_path('_includes', 'api-template.html'), 'class="api-method-metadata"'
    assert_file_excludes project_path('_includes', 'api-template.html'), 'style="float: right; list-style: none;"'

    Dir[project_path('_data', 'apidefinitions', '*.yml')].each do |file_name|
      assert_file_excludes file_name, '<p>&nbsp;</p>'
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
