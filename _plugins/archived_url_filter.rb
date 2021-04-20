module Jekyll
  module ArchivedUrlFilter
    ARCHIVED_LINKS_FILE = '_data/archived_urls.yml'
    
    def archived_url(original_url)
      yaml = YAML.load_file(ARCHIVED_LINKS_FILE)
      archived_url = yaml['archived_urls'][original_url]
      @@rate_limited ||= false
      @@count ||= {}
      
      # Count the number of times this URL has been seen in this runtime.
      @@count[original_url] ||= 0
      @@count[original_url] += 1
      
      if !!archived_url
        if verify? && @@count[original_url] == 1
          unless !!@@rate_limited
            headers = `curl -s -I #{archived_url}`
            
            if headers =~ /HTTP\/2 429/
              warn "ArchivedUrl: Got rated limited while verifying: #{original_url}\n#{headers}"
              
              @@rate_limited = true
            elsif !(headers =~ /link: <#{original_url}>/)
              warn "ArchivedUrl: #{original_url} was incorrectly linked to #{archived_url}\n#{headers}"
            end
          end
        end
        
        return archived_url
      end
      
      warn "ArchivedUrl: Could not find url in #{ARCHIVED_LINKS_FILE}: #{original_url} (times seen: #{@@count[original_url]})"
      
      original_url
    end
    
    def verify?
      ENV.fetch('VERIFY_ARCHIVED_URLS', 'false') == 'true'
    end
  end
end

Liquid::Template.register_filter(Jekyll::ArchivedUrlFilter)

# USAGE:
# {{ 'https://github.com/steemit/steem/issues/301' | archived_url }}
