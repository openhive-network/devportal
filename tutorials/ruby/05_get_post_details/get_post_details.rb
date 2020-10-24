require 'rubygems'
require 'bundler/setup'

Bundler.require

url = ARGV[0]
slug = url.split('@').last
author, permlink = slug.split('/')
api = Radiator::Api.new

api.get_content(author, permlink) do |content|
  if content.author.empty?
    puts "Could not find content with url: #{url}"
    exit
  end
  
  if content.parent_author.empty?
    puts "Post by #{content.author}"
  else
    print "Reply by #{content.author} to #{content.parent_author}/#{content.parent_permlink}"
    
    if content.parent_author == content.root_author && content.parent_permlink == content.root_permlink
      # This is a reply direcly to the root post, no need to specify.
      print "\n"
    else
      # This is a reply to a reply, so we can specify the root post info.
      puts " in #{content.root_author}/#{content.root_permlink} (#{content.root_title})"
    end
    
    # Used to track max nested depth of replies.
    puts "\tdepth: #{content.depth}"
  end
  
  %w(title permlink category).each do |key|
    puts "\t#{key}: #{content[key]}"
  end
  
  puts "\tbody_length: #{content.body.size} (#{content.body.split(/\W+/).size} words)"
  
  # The date and time this content was created.
  print "\tposted at: #{content.created}"
  
  if content.last_update == content.created
    # The date and time of the last update to this content.
    print ", updated at: #{content.last_update}"
  end
  
  # The last time this content was "touched" by voting or reply.
  puts ", active at: #{content.active}"
  
  # Used to track the total number of children, grandchildren, etc. ...
  puts "\tchildren: #{content.children}"
  
  # Reward is proportional to liniar rshares, this is the sum of all votes
  # (positive and negative reward sum)
  puts "\tnet_rshares: #{content.net_rshares}"
  
  # Total positive rshares from all votes. Used to calculate delta weights.
  # Needed to handle vote changing and removal.
  puts "\tvote_rshares: #{content.vote_rshares}"
  
  puts "\tpayout:"
  
  # Value of the maximum payout this content will receive.
  puts "\t\tmax_accepted_payout: #{content.max_accepted_payout}"
  
  # The percent of Hive Dollars to keep, unkept amounts will be received as
  # HIVE Power.
  puts "\t\tpercent_hbd: #{'%.2f %%' % (content.percent_hbd / 100.0)}"
    
  # 7 days from the created date.
  if (cashout = Time.parse(content.cashout_time + 'Z') - Time.now.utc) > 0
    cashout = cashout / 86400 # convert from seconds to days
    puts "\t\tpays in: #{('%.1f' % (cashout))} days"
    
    # Pending payout amount if 7 days has not yet elapsed.
    puts "\t\tpending_payout_value: #{content.pending_payout_value}"
    
    # Total pending payout amount if 7 days has not yet elapsed.
    puts "\t\ttotal_pending_payout_value: #{content.total_pending_payout_value}"
  else
    # The date and time of the last update to this content.
    print "\t\tpayout at: #{content.last_payout}"
    
    payout_elapsed = Time.now.utc - Time.parse(content.last_payout + 'Z')
    payout_elapsed = payout_elapsed / 86400 # convert from seconds to days
    puts " (#{('%.1f' % payout_elapsed)} days ago)"
  
    # Tracks the author payout this content has received over time, measured in
    # the debt asset.
    puts "\t\tauthor_rewards: #{('%.3f HBD' % (content.author_rewards / 1000.0))}"
    
    # Tracks the curator payout this content has received over time, measured in
    # the debt asset.
    puts "\t\tcurator_payout_value: #{content.curator_payout_value}"
    
    # Tracks the total payout this content has received over time, measured in
    # the debt asset.
    puts "\t\ttotal_payout_value: #{content.total_payout_value}"
  end
  
  # If post is promoted, how much has been spent on promotion.
  puts "\tpromoted: #{content.promoted}"
  
  # The list of up to 8 beneficiary accounts for this content as well as the
  # percentage of the author reward they will receive in HIVE Power.
  if content.beneficiaries.any?
    puts "\tbeneficiaries:"
    
    content.beneficiaries.each do |beneficiary|
      puts "\t\t#{beneficiary.account}: #{'%.2f %%' % (beneficiary.weight / 100.0)}"
    end
  end
  
  # The total weight of voting rewards, used to calculate pro-rata share of
  # curation payouts.
  puts "\ttotal_vote_weight: #{content.total_vote_weight}"
  
  # Weight/percent of reward.
  puts "\treward_weight: #{'%.2f %%' % (content.reward_weight / 100.0)}"
  
  # Net positive votes
  print "\tnet_votes: #{content.net_votes}"
  
  # The entire voting list array, including upvotes, downvotes, and unvotes;
  # used to calculate net_votes.
  votes = content.active_votes
  upvotes = votes.select { |v| v.percent > 0 }.size
  downvotes = votes.select { |v| v.percent < 0 }.size
  unvotes = votes.select { |v| v.percent == 0 }.size
  top_voter = votes.sort_by { |v| v.rshares.to_i }.last.voter
  
  print ", upvotes: #{upvotes}"
  print ", downvotes: #{downvotes}"
  print ", unvotes: #{unvotes}"
  print ", total: #{votes.size}"
  puts ", top voter: #{top_voter}"
  
  #  Allows content to disable replies.
  puts "\tallow_replies: #{content.allow_replies}"
  
  # Allows content to receive votes.
  puts "\tallow_votes: #{content.allow_votes}"
  
  # Allows curators of this content receive rewards.
  puts "\tallow_curation_rewards: #{content.allow_curation_rewards}"
  
  # Author's reputation.
  puts "\tauthor_reputation: #{content.author_reputation}"
  
  # JSON metadata that holds extra information about the content. Note: The
  # format for this field is not guaranteed to be valid JSON, so we use rescue
  # here to deal with this possibility.
  metadata = JSON[content.json_metadata || '{}'] rescue {}
  tags = metadata['tags'] || []
  app = metadata['app']
  puts "\ttags: #{tags.join(', ')}" if tags.any?
  puts "\tapp: #{app}" if !!app
end
