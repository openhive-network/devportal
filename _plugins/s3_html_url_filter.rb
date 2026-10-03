module Jekyll
  module S3HtmlUrlFilter
    # Jekyll collection permalinks omit the .html extension that is written to
    # disk (/quickstart/building_agents vs building_agents.html). CloudFront
    # slash-redirects the extensionless path and S3 answers 403. Directory
    # indexes (trailing slash) and fragment URLs on those indexes stay as-is.
    # Same rule as sitemap.xml / llms.txt.
    def s3_html_url(url)
      str = url.to_s
      return str if str.empty? || str.include?('://')

      path = str
      fragment = nil
      if str.include?('#')
        path, fragment = str.split('#', 2)
      end

      return str if path.end_with?('/') || path.match?(/\.[A-Za-z0-9]+\z/)

      fixed = "#{path}.html"
      fragment.nil? ? fixed : "#{fixed}##{fragment}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::S3HtmlUrlFilter)
