require 'fileutils'
require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require 'yaml'

module JekyllBuildTestHelper
  PROJECT_ROOT = File.expand_path('..', __dir__)
  DEFAULT_SITE_DIR = File.join(PROJECT_ROOT, '_site').freeze
  @@default_site_built = false

  def project_path(*parts)
    File.join(PROJECT_ROOT, *parts)
  end

  def site_dir_for_assertions
    site_dir = ENV['SITE_DIR']
    unless site_dir && !site_dir.empty?
      build_default_site_once
      return yield DEFAULT_SITE_DIR
    end

    site_dir = File.expand_path(site_dir, PROJECT_ROOT)
    assert Dir.exist?(site_dir), "SITE_DIR does not exist: #{site_dir}"

    yield site_dir
  end

  def build_site(env: 'development', destination: nil)
    if destination
      FileUtils.rm_rf(destination)
      run_jekyll_build(env, destination)
      yield destination
    else
      Dir.mktmpdir('devportal-jekyll-assertions-') do |site_dir|
        run_jekyll_build(env, site_dir)
        yield site_dir
      end
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

  private

  def build_default_site_once
    return if @@default_site_built

    build_site(destination: DEFAULT_SITE_DIR) {}
    @@default_site_built = true
  end

  def run_jekyll_build(env, site_dir)
    stdout, stderr, status = Open3.capture3(
      { 'JEKYLL_ENV' => env },
      'bundle', 'exec', 'jekyll', 'build', '--destination', site_dir,
      chdir: PROJECT_ROOT
    )

    assert status.success?, "Jekyll build failed:\n#{stdout}\n#{stderr}"
  end
end
