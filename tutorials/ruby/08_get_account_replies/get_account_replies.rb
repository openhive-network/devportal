require 'rubygems'
require 'bundler/setup'

Bundler.require

account_name = ARGV[0]
api = Radiator::Api.new

api.get_account_history(account_name, -1, 10000) do |history|
  history.each do |index, item|
    type, op = item.op
    
    next unless type == 'comment'
    next if op.parent_author.empty? # skip posts
    next unless op.parent_author == account_name # skip comments by account
    
    url = "https://hive.blog/@#{op.author}/#{op.permlink}"
    api.get_content(op.author, op.permlink) do |reply|
      puts "Reply by @#{op.author} in discussion: \"#{reply.root_title}\""
      
      puts "\tbody_length: #{reply.body.size} (#{reply.body.split(/\W+/).size} words)"
      
      # The date and time this reply was created.
      print "\treplied at: #{reply.created}"
      
      if reply.last_update != reply.created
        # The date and time of the last update to this reply.
        print ", updated at: #{reply.last_update}"
      end
      
      if reply.last_update != reply.created
        # The last time this reply was "touched" by voting or reply.
        print ", active at: #{reply.active}"
      end
      
      print "\n"
      
      # Net positive votes
      puts "\tnet_votes: #{reply.net_votes}"
      
      # Link directly to reply.
      puts "\t#{url}"
    end
  end
end
