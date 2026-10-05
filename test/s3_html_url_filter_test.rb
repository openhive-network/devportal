require_relative 'test_helper'
require 'liquid'
require_relative '../_plugins/s3_html_url_filter'

class S3HtmlUrlFilterTest < Minitest::Test
  include Jekyll::S3HtmlUrlFilter

  def test_appends_html_to_extensionless_collection_urls
    assert_equal '/quickstart/building_agents.html', s3_html_url('/quickstart/building_agents')
    assert_equal '/introduction/welcome.html', s3_html_url('/introduction/welcome')
  end

  def test_appends_html_to_domain_like_collection_names
    # Filenames like ecency.com.md / hive.blog.md produce page.url values that
    # end in .com / .blog. Those are not static-asset extensions; the built
    # files are still *.html and language-selector links must name them.
    assert_equal '/services/ecency.com.html', s3_html_url('/services/ecency.com')
    assert_equal '/services/hive.blog.html', s3_html_url('/services/hive.blog')
    assert_equal '/es/services/ecency.com.html', s3_html_url('/es/services/ecency.com')
    assert_equal '/es/services/hive.blog.html', s3_html_url('/es/services/hive.blog')
  end

  def test_keeps_directory_indexes
    assert_equal '/quickstart/', s3_html_url('/quickstart/')
    assert_equal '/services/', s3_html_url('/services/')
  end

  def test_keeps_fragment_urls_on_directory_indexes
    assert_equal '/apidefinitions/#apidefinitions-database-api',
                 s3_html_url('/apidefinitions/#apidefinitions-database-api')
  end

  def test_keeps_already_html_urls
    assert_equal '/services/ecency.com.html', s3_html_url('/services/ecency.com.html')
    assert_equal '/quickstart/building_agents.html#section',
                 s3_html_url('/quickstart/building_agents.html#section')
  end

  def test_leaves_absolute_and_empty_urls_alone
    assert_equal '', s3_html_url('')
    assert_equal 'https://developers.hive.io/services/ecency.com',
                 s3_html_url('https://developers.hive.io/services/ecency.com')
  end
end
