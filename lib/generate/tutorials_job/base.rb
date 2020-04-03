require 'git'

module Generate
  module TutorialsJob
    class Base
      def initialize(options = {})
        @num = (options[:num] || '-1').to_i
        @force = options[:force] == 'true'
        @src_tutorials_path = options[:src_tutorials_path] # e.g.: tutorials/devportal-tutorials-js
        @dest_tutorials_path = options[:dest_tutorials_path] # e.g.: _tutorials-javascript
      end
      
      # Execute the job.
      #
      # @return [Integer] total number of tutorials added or changed in this pass
      def perform
        tutorial_change_count = 0
        tutorial_title_prefix = @src_tutorials_path.split('-').last.upcase
        
        Pathname.new(@src_tutorials_path + '/tutorials').children.sort.each do |path|
          next unless File.directory? path
          
          slug = include_name = path.to_s.split('/').last
          slug = slug.split('_')
          num = slug[0].to_i
          
          next if @num != -1 && @num != num
          
          name = slug[1..-1].join '_'
          title = slug[1..-1].map(&:capitalize).join ' '
          readme = "#{path}/README.md"
          destination = "#{@dest_tutorials_path}/#{name}.md"
          
          if File.exists?(destination) && @force
            puts "##{num}: \"#{title}\" already exists.  Forcing."
          elsif File.exists? destination
            puts "##{num}: \"#{title}\" already exists.  Skipping."
            next
          end
          
          parse_readme(readme) do |description, body|
            template = <<~DONE
              ---
              title: '#{tutorial_title_prefix}: #{title}'
              position: #{num}
              description: #{description}
              layout: full
              ---              
              #{tutorial_repo_links title, include_name, tutorial_title_prefix}
              <br>

              #{rewrite_relative_links(rewrite_images body, include_name)}

              ---
              
              
            DONE
            
            f = File.open(destination, 'w+')
            f.puts template.strip + "\n"
            f.close
          end
          
          tutorial_change_count += 1
        end
        
        tutorial_change_count
      end
    private
      def parse_readme(readme)
        description = nil
        body = ''
        
        File.open(readme, 'r').each_line do |line|
          next if line =~ /^# /
          
          if description.nil? && !line.strip.empty?
            description ||= "\"#{line.strip}\""
            
            next
          end
          
          body << line
        end
        
        yield description, body
      end
      
      def rewrite_images(body, include_name)
        body = body.gsub(/!\[([^\]]+)\]\(([^)]+)\)/) do
          alt, src = Regexp.last_match[1..2]
          src = if src.include? '://'
            src
          else
            src = src.split('/')[1..-1].join('/') if src.start_with? './'
            "https://gitlab.syncad.com/hive/devportal/-/raw/master/#{@src_tutorials_path}/tutorials/#{include_name}/#{src}"
          end
          
          "![#{alt}](#{src})"
        end
        
        body
      end
      
      def rewrite_relative_links(body)
        body = body.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
          text, href = Regexp.last_match[1..2]
          href = if href.include? '://'
            href
          elsif href.include? @src_tutorials_path
            relative_href = href.gsub(/#{@src_tutorials_path}\/tree\/master\/tutorials\/(\d+)_([a-z0-9_]+)/) do
              num, name = Regexp.last_match[1..2]
              
              name
            end
            
            relative_href
          else
            relative_href = href.gsub(/..\/(\d+)_([a-z0-9_]+)/) do
              num, name = Regexp.last_match[1..2]
              
              name
            end
            
            relative_href
          end
          
          "[#{text}](#{href})"
        end
        
        body
      end
      
      def tutorial_repo_links(title, include_name, tutorial_title_prefix)
        "<span class=\"fa-pull-left top-of-tutorial-repo-link\"><span class=\"first-word\">Full</span>, runnable src of [#{title}](https://gitlab.syncad.com/hive/devportal/-/tree/develop/#{@src_tutorials_path}/tutorials/#{include_name}) can be downloaded as part of: [#{@src_tutorials_path}](https://gitlab.syncad.com/hive/devportal/-/tree/develop/#{@src_tutorials_path}).</span>"
      end
    end
  end
end
