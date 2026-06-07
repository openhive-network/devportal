require 'fileutils'
require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require 'yaml'

module JekyllBuildTestHelper
  PROJECT_ROOT = File.expand_path('..', __dir__)

  def project_path(*parts)
    File.join(PROJECT_ROOT, *parts)
  end

  def site_dir_for_assertions
    site_dir = ENV['SITE_DIR']
    return build_site { |built_site_dir| yield built_site_dir } unless site_dir && !site_dir.empty?

    site_dir = File.expand_path(site_dir, PROJECT_ROOT)
    assert Dir.exist?(site_dir), "SITE_DIR does not exist: #{site_dir}"

    yield site_dir
  end

  def build_site(env: 'development')
    Dir.mktmpdir('devportal-jekyll-assertions-') do |site_dir|
      stdout, stderr, status = Open3.capture3(
        { 'JEKYLL_ENV' => env },
        'bundle', 'exec', 'jekyll', 'build', '--destination', site_dir,
        chdir: PROJECT_ROOT
      )

      assert status.success?, "Jekyll build failed:\n#{stdout}\n#{stderr}"

      yield site_dir
    end
  end

  def assert_file_includes(path, text)
    assert_includes File.read(path), text, "Expected #{path} to include #{text.inspect}"
  end

  def assert_file_excludes(path, text)
    refute_includes File.read(path), text, "Expected #{path} not to include #{text.inspect}"
  end

  def api_methods(file_name)
    YAML.load_file(project_path('_data', 'apidefinitions', file_name)).first.fetch('methods')
  end

  def api_method(file_name, method_name)
    method = api_methods(file_name).find { |entry| entry['api_method'] == method_name }
    assert method, "Expected #{file_name} to document #{method_name}"
    method
  end
end
