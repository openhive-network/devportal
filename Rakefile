lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrape/api_definitions_job'

require 'rake/testtask'
require 'net/https'
require 'json'
require 'yaml'
require 'html-proofer'
require 'cgi'
require 'pathname'
require 'set'

def api_method_obsolete?(method)
  !!method['removed'] || method['status'].to_s == 'obsolete'
end

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

namespace :api do
  def api_definition_methods
    methods = []
    
    Dir['_data/apidefinitions/*.yml'].sort.each do |file_name|
      YAML.load_file(file_name).each do |section|
        Array(section['methods']).each do |method|
          api_method = method['api_method']
          next unless api_method
          
          methods << {
            name: api_method,
            file: file_name,
            obsolete: api_method_obsolete?(method)
          }
        end
      end
    end
    
    methods
  end
  
  def openapi_methods
    file_name = ENV.fetch(
      'HIVE_OPENAPI',
      '../hive/libraries/plugins/apis/documentation/openapi.json'
    )
    return Set.new unless File.exist?(file_name)
    
    openapi = JSON.parse(File.read(file_name))
    paths = openapi.fetch('paths', {})
    
    paths.keys.filter_map do |path|
      path.to_s.split('/').last
    end.to_set
  end
  
  def cpp_api_methods
    root = ENV.fetch('HIVE_APIS_ROOT', '../hive/libraries/plugins/apis')
    return Set.new unless Dir.exist?(root)
    
    ignored_dirs = %w(api_generation documentation test_api)
    methods = Set.new
    
    Dir[File.join(root, '*')].sort.each do |api_dir|
      next unless File.directory?(api_dir)
      
      api_name = File.basename(api_dir)
      next if ignored_dirs.include?(api_name)
      
      Dir[File.join(api_dir, '**', '*.{hpp,cpp}')].sort.each do |file_name|
        text = File.read(file_name)
        
        text.scan(/(?:DECLARE_API|DECLARE_API_IMPL)\s*\((.*?)\)\s*(?:;|\{|private:|public:|FC_REFLECT|\z)/m) do |match|
          match.first.scan(/\(([a-zA-Z_][a-zA-Z0-9_]*)\)/) do |method_match|
            methods << "#{api_name}.#{method_match.first}"
          end
        end
        
        text.scan(/DEFINE_API_IMPL\s*\([^,]+,\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)/) do |match|
          methods << "#{api_name}.#{match.first}"
        end
      end
    end
    
    methods
  end
  
  def print_method_report(title, methods, limit = nil)
    puts
    puts "#{title} (#{methods.length}):"
    
    shown = limit ? methods.first(limit) : methods
    if shown.empty?
      puts '  none'
    else
      shown.each { |method| puts "  #{method}" }
    end
    
    return unless limit && methods.length > limit
    
    puts "  ... #{methods.length - limit} more"
  end
  
  desc 'Report API method drift against adjacent Hive OpenAPI and C++ declarations.'
  task :drift do
    docs = api_definition_methods
    all_docs = docs.map { |method| method[:name] }.to_set
    active_docs = docs.reject { |method| method[:obsolete] }.map { |method| method[:name] }.to_set
    obsolete_docs = docs.select { |method| method[:obsolete] }.map { |method| method[:name] }.to_set
    openapi = openapi_methods
    cpp = cpp_api_methods
    source = openapi | cpp
    
    puts 'API method drift'
    puts "Docs: active #{active_docs.length}, obsolete #{obsolete_docs.length}, all #{all_docs.length}"
    puts "Source: OpenAPI #{openapi.length}, C++ #{cpp.length}, combined #{source.length}"
    
    if openapi.empty?
      puts 'OpenAPI source not found. Set HIVE_OPENAPI to compare against a different file.'
    end
    
    if cpp.empty?
      puts 'C++ API source not found. Set HIVE_APIS_ROOT to compare against a different directory.'
    end
    
    print_method_report('Active docs missing from source', (active_docs - source).to_a.sort)
    print_method_report('Source methods missing from active docs', (source - active_docs).to_a.sort)
    print_method_report('Obsolete docs still present in source', (obsolete_docs & source).to_a.sort)
    print_method_report('Source methods absent from all docs', (source - all_docs).to_a.sort)
  end
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
    chain_id = version['chain_id']
    mainnet = chain_id == 'beeab0de00000000000000000000000000000000000000000000000000000000'
    
    puts "node: #{url}; blockchain_version: #{blockchain_version}; hive_rev: #{hive_rev}; fc_rev: #{fc_rev}; mainnet: #{mainnet}"
    
    apis.each do |api|
      file_name = "_data/apidefinitions/#{api}.yml"
      unless File.exist?(file_name)
        puts "Does not exist: #{file_name}"
        next
      end
      
      yml = YAML.load_file(file_name)
      
      yml[0]['methods'].each do |method|
        next if api_method_obsolete?(method)
        
        print "Testing #{method['api_method']} ... "
        
        if method['curl_examples'].nil?
          puts "no curl examples."
          next
        end
        
        method['curl_examples'].each_with_index do |curl_example, index|
          unless mainnet
            # Replace key prefix, e.g.:
            # STM6vJmrwaX5TjgTS9dPH8KsArso5m91fVodJvv91j7G765wqcNM9
            # becomes:
            # TST6vJmrwaX5TjgTS9dPH8KsArso5m91fVodJvv91j7G765wqcNM9
            curl_example = curl_example.gsub(/"STM([^"]{50})"/) do |_|
              match = Regexp.last_match
              
              "\"TST#{match[1]}\""
            end
          end
          
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
  
  PROOF_IGNORE_URLS = ['http://localhost:3000/', 'http://0.0.0.0:8080'].freeze
  PROOF_SITE_DIR = './_site'.freeze
  
  def run_html_proofer(options = {})
    sh 'bundle exec jekyll build'
    
    default_options = {
      # Automatically add extension (e.g. .html) to file paths, to allow
      # extensionless URLs (as supported by Jekyll 3 and GitHub Pages)
      assume_extension: '.html',
      
      # Only reports errors for links that fall within the 4xx status code
      # range.
      only_4xx: true,
      
      # If true, ignores the href="#" (typically JQuery).
      allow_hash_href: true,
      
      # If true, ignores images with empty alt tags.
      ignore_empty_alt: true,
      
      # Check that <link> and <script> external resources use SRI	
      check_sri: true,
      
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
      ignore_urls: PROOF_IGNORE_URLS
    }
    
    HTMLProofer.check_directory(PROOF_SITE_DIR, default_options.merge(options)).run
  end
  
  def internal_url?(href)
    href !~ %r{\A(?:[a-z][a-z0-9+\-.]*:)?//}i &&
      href !~ %r{\A(?:mailto|tel|javascript|data):}i
  end
  
  def html_path_for_link(current_file, href)
    link_path = href.split('#', 2).first.to_s.split('?', 2).first.to_s
    
    if link_path.empty?
      path = Pathname.new(current_file)
    elsif link_path.start_with?('/')
      path = Pathname.new(link_path.delete_prefix('/'))
    else
      path = Pathname.new(current_file).dirname.join(link_path).cleanpath
    end
    
    path = path.join('index.html') if path.to_s.end_with?('/')
    path = Pathname.new("#{path}.html") if path.extname.empty?
    path.to_s
  end
  
  def check_internal_hashes(site_dir = PROOF_SITE_DIR)
    site_root = Pathname.new(site_dir)
    html_files = Dir[site_root.join('**/*.html')]
    anchors_by_file = {}
    failures = []
    
    html_files.each do |file|
      relative_file = Pathname.new(file).relative_path_from(site_root).to_s
      document = Nokogiri::HTML(File.read(file))
      anchors_by_file[relative_file] = document.css('[id], a[name]').filter_map do |node|
        node['id'] || node['name']
      end.to_set
    end
    
    html_files.each do |file|
      relative_file = Pathname.new(file).relative_path_from(site_root).to_s
      document = Nokogiri::HTML(File.read(file))
      
      document.css('a[href*="#"]').each do |link|
        href = link['href'].to_s
        next if href.empty? || href == '#'
        next unless internal_url?(href)
        
        href_parts = href.split('#', 2)
        next unless href_parts.length == 2
        
        fragment = href_parts.last.to_s
        next if fragment.empty?
        
        target_file = html_path_for_link(relative_file, href)
        anchors = anchors_by_file[target_file]
        next unless anchors
        
        anchor = CGI.unescape(fragment)
        next if anchors.include?(anchor)
        
        failures << "#{relative_file}: missing ##{anchor} in #{target_file}"
      end
    end
    
    return if failures.empty?
    
    puts "\nInternal hash failures:"
    failures.first(100).each { |failure| puts "* #{failure}" }
    puts "... #{failures.length - 100} more" if failures.length > 100
    fail "Found #{failures.length} internal hash failures"
  end
  
  desc 'Fast proof: scripts and internal file links, skipping expensive hash-anchor checks.'
  task proof: 'proof:fast'
  
  namespace :proof do
    desc 'Fast proof: scripts and internal file links, skipping expensive hash-anchor checks.'
    task :fast do
      run_html_proofer(
        checks: ['Scripts', 'Links'],
        check_internal_hash: false
      )
    end
    
    desc 'Full proof: scripts, links, images, and internal hash anchors.'
    task :full do
      run_html_proofer(
        checks: ['Scripts', 'Links', 'Images'],
        check_internal_hash: false
      )
      check_internal_hashes
    end
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
