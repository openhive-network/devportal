lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrape/api_definitions_job'

require 'rake/testtask'
require 'net/https'
require 'json'
require 'yaml'
require 'html-proofer'

namespace :scrape do
  desc "Scrape API Definitions"
  task :api_defs do
    url = ENV.fetch('TEST_NODE', 'https://api.hive.blog')
    job = Scrape::ApiDefinitionsJob.new(url: url)
    count = job.perform
    
    puts "Methods added or changed: #{count}"
  end
end

namespace :production do
  task :prevent_dirty_builds do
    if `git status --porcelain`.chomp.length > 0
      puts '*** WARNING: You currently have uncommitted changes. ***'
      fail 'Build aborted, because project directory is not clean.' unless ENV['ALLOW_DIRTY']
    end
  end
  
  task :build do
    baseurl = ENV.fetch('BASEURL', '/')
    cmd = 'bundle exec jekyll build --destination docs'
    
    if !!baseurl && baseurl != '/'
      cmd += " --baseurl #{baseurl}"
    end
    
    sh cmd
  end
  
  task :drop_previous_build do
    sh 'git checkout master'
    sh 'git rm -rf docs'
    sh 'git commit -m "jekyll dropped previous site"'
  end
  
  desc "Deploy current master to GH Pages"
  task deploy: [:prevent_dirty_builds, :drop_previous_build, :build] do
    remote = ENV.fetch('REMOTE', 'origin')
    
    sh 'git add -A'
    sh 'git commit -m "jekyll base sources"'
    sh "git push #{remote} master"
    
    exit(0)
  end
  
  desc "Rollback GH Pages"
  task rollback: [:prevent_dirty_builds] do
    sh 'git checkout master'
    sh 'git reset --hard HEAD^'
    sh 'git push origin master'
    
    exit(0)
  end
  
  desc "Make a clean build."
  task :clean do
    sh 'rm -rf _site && rm -rf docs && git checkout -- docs && git checkout -- _site'
  end
end

desc 'Dump all operation types.  Useful for schema comparison.'
task :ops_dump, [:vops, :appbase] do |t, args|
  vops = args[:vops] == 'true'
  appbase = args[:appbase] == 'true'
  file_name = '_data/apidefinitions/broadcast_ops.yml'
  op_names = []
  yaml = YAML.load_file(file_name)
  op_names += yaml[0]['ops'].map do |op|
    next if op['virtual'] && !vops
    
    if !!appbase
      op['name'] + '_operation'
    else
      op['name']
    end
  end
  
  puts op_names.compact.sort
end

desc 'Dump all dgpo keys.'
task :dgpo_dump do
  file_name = '_data/objects/dgpo.yml'
  yaml = YAML.load_file(file_name)
  api = Hive::DatabaseApi.new
  all_keys = api.get_dynamic_global_properties.result.keys - ['id']
  known_keys = []
  removed_keys = []
  unknown_keys = []
  known_undocumented_keys = []
  
  yaml[0]['fields'].map do |field|
    field_name = field['name']
    
    known_keys << field_name if all_keys.include? field_name
    removed_keys << field_name if !!field['removed']
    known_undocumented_keys << field_name if all_keys.include?(field_name) && field['purpose'].nil?
  end
  
  unknown_keys = all_keys - known_keys
  
  puts "Known keys:"
  puts known_keys.map{|k| "\t#{k}"}
  puts "Removed keys:"
  puts removed_keys.map{|k| "\t#{k}"}
  puts "Unknown keys:"
  puts unknown_keys.map{|k| "\t#{k}"}
  puts "Known, undocumented keys:"
  puts known_undocumented_keys.map{|k| "\t#{k}"}
end

desc 'Dump all config keys.'
task :config_dump do
  file_name = '_data/objects/config.yml'
  yaml = YAML.load_file(file_name)
  api = Hive::DatabaseApi.new
  all_keys = api.get_config.result.keys
  known_keys = []
  removed_keys = []
  unknown_keys = []
  known_undocumented_keys = []
  
  yaml[0]['fields'].map do |field|
    field_name = field['name']
    
    known_keys << field_name if all_keys.include? field_name
    removed_keys << field_name if !!field['removed']
    known_undocumented_keys << field_name if all_keys.include?(field_name) && field['purpose'].nil?
  end
  
  unknown_keys = all_keys - known_keys
  
  puts "Known keys:"
  puts known_keys.map{|k| "\t#{k}"}
  puts "Removed keys:"
  puts removed_keys.map{|k| "\t#{k}"}
  puts "Unknown keys:"
  puts unknown_keys.map{|k| "\t#{k}"}
  puts "Known, undocumented keys:"
  puts known_undocumented_keys.map{|k| "\t#{k}"}
end

desc 'Dump all archived urls'
task :archived_urls_dump do
  file_name = '_data/archived_urls.yml'
  yaml = YAML.load_file(file_name)
  
  puts yaml['archived_urls'].map{|k, v| "#{k} => #{v}"}
end

namespace :test do
  KNOWN_APIS = %i(
    account_by_key_api account_history_api block_api condenser_api 
    database_api follow_api jsonrpc market_history_api network_broadcast_api
    tags_api witness_api
  )
  
  desc "Tests the curl examples of api definitions.  Known APIs: #{KNOWN_APIS.join(' ')}"
  task :curl, [:apis] do |t, args|
    smoke = 0
    url = ENV.fetch('TEST_NODE', 'https://api.hive.blog')
    apis = [args[:apis].split(' ').map(&:to_sym)].flatten if !!args[:apis]
    apis ||= KNOWN_APIS
    
    version = `curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_version", "params":[], "id":1}' #{url}`
    version = JSON[version]['result']
    blockchain_version = version['blockchain_version']
    hive_rev = version['hive_revision'][0..5]
    fc_rev = version['fc_revision'][0..5]
    puts "node: #{url}; blockchain_version: #{blockchain_version}; hive_rev: #{hive_rev}; fc_rev: #{fc_rev}"
    
    apis.each do |api|
      file_name = "_data/apidefinitions/#{api}.yml"
      unless File.exist?(file_name)
        puts "Does not exist: #{file_name}"
        next
      end
      
      yml = YAML.load_file(file_name)
      
      yml[0]['methods'].each do |method|
        print "Testing #{method['api_method']} ... "
        
        if method['curl_examples'].nil?
          puts "no curl examples."
          next
        end
        
        method['curl_examples'].each_with_index do |curl_example, index|
          response = `curl -s -w \"HTTP_CODE:%{http_code}\" --data '#{curl_example}' #{url}`
          response = response.split('HTTP_CODE:')
          json = response[0]
          code = response[1]
          
          case code
          when '200'
            data = JSON[json]
            
            if !!data['error']
              expected_curl_response = if !!method['expected_curl_responses']
                method['expected_curl_responses'][index]
              end
              
              if !!expected_curl_response && data['error']['message'].include?(expected_curl_response)
                print '√'
              else
                smoke += 1
                print "\n\t#{data['error']['message']}\n"
              end
            else
              print '√'
            end
          else
            smoke += 1
            'X'
          end
        end
        
        print "\n"
      end
    end
    
    exit smoke
  end
  
  desc 'Want some work to do?  Run this report and get busy.'
  task :proof do
    # See: https://github.com/gjtorikian/html-proofer#configuration
    sh 'bundle exec jekyll build'
    options = {
      # Automatically add extension (e.g. .html) to file paths, to allow
      # extensionless URLs (as supported by Jekyll 3 and GitHub Pages)
      assume_extension: true,
      
      # Only reports errors for links that fall within the 4xx status code
      # range.
      only_4xx: true,
      
      # Enables the favicon checker.
      check_favicon: true,
      
      # Enables HTML validation errors from Nokogumbo.  See: https://github.com/gjtorikian/html-proofer#configuring-html-validation-rules
      check_html: true,
      validation: {
        report_mismatched_tags: true
      },
      
      # If true, ignores the href="#" (typically JQuery).
      allow_hash_href: true,
      
      # If true, ignores images with empty alt tags.
      empty_alt_ignore: true,
      
      # Check that <link> and <script> external resources use SRI	
      check_sri: true,
      
      # Enables the Open Graph checker.
      check_opengraph: true,
      
      # If true, does not run the external link checker, which can take a lot of
      # time.  Also, external links may rate-limit or even fail due to excess
      # requests.
      disable_external: true,
      
      # If disable_external is false, consider ignoring http status 429.
      # http_status_ignore: [429],
      
      # If disable_external is false, consider caching.  See: https://github.com/gjtorikian/html-proofer#configuring-caching
      # cache: { timeframe: '2w' }
      
      # Fails a link if it's not marked as https.	
      enforce_https: true,
      url_ignore: ['http://localhost:3000/', 'http://0.0.0.0:8080']
    }
    
    HTMLProofer.check_directory("./_site", options).run
  end
end

desc 'Sample a page.'
task :sample do
  sitemap = Nokogiri::XML(File.open('_site/sitemap.xml'))
  links = []
  
  if 10 > rand() * 100
    file_name = '_data/objects/config.yml'
    yaml = YAML.load_file(file_name)
    key = yaml[0]['fields'].sample['name']
    
    puts "https://developers.hive.io/tutorials-recipes/understanding-configuration-values.html##{key}"
    exit
  elsif 10 > rand() * 100
    file_name = '_data/objects/dgpo.yml'
    yaml = YAML.load_file(file_name)
    key = yaml[0]['fields'].sample['name']
    
    puts "https://developers.hive.io/tutorials-recipes/understanding-dynamic-global-properties.html##{key}"
    exit
  end
  
  while links.empty?
    links += sitemap.root.children.to_a.sample(10).map(&:children).compact.reject(&:empty?)
  end
  
  puts links.sample.children.first.to_s.gsub('http://localhost:4000', 'https://developers.hive.io')
end
