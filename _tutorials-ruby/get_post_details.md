---
title: titles.get_post_details
position: 5
description: "Understand and use the most common fields of the requested content."
layout: full
canonical_url: get_post_details.html
---
Full, runnable src of [Get Post Details](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/05_get_post_details) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-05_get_post_details.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/05_get_post_details)).

### Intro

This tutorial fetches the contents of a single post and explains all data related to that post.

We will also describe the most commonly used fields from the response object.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [database_api.find_comments]({{ '/apidefinitions/#database_api.find_comments' | relative_url }})
* [condenser_api.get_content]({{ '/apidefinitions/#condenser_api.get_content' | relative_url }})

### Sections

1. [Making the api call](#making-the-api-call) - Use `get_content` to a specific post
    1. [Example api call](#example-api-call) - make the call in code
    1. [Example api call using script](#example-api-call-using-script) - using our tutorial script
    1. [Example Output](#example-output) - output from a successful call
1. [Post Fields](#post-fields) - General use of the method to determine ...
    1. [`parent_author`](#parent_author) - if the content is a root post or reply
    1. [`last_update` and `created`](#last_update-and-created) - if the content has been modified
    1. [`cashout_time`](#cashout_time) - if the content has reached payout
    1. [`beneficiaries`](#beneficiaries) - reward routes other accounts
    1. [`active_votes`](#active_votes) - all votes applied
    1. [`json_metadata`](#json_metadata) - things like `tags` and `app`
1. [To Run](#to-run) - Running the example.

### Making the api call

[`get_post_details.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/05_get_post_details/get_post_details.rb)

To request a specific post we use the `get_content` method:

```ruby
api = Radiator::Api.new

api.get_content(author, permlink) do |content|
  # .
  # ... your code here
  # .
end
```

#### Example api call

If we want to get the post "announcing-the-launch-of-hive-blockchain" by user @hiveio

```ruby
api.get_content("hiveio", "announcing-the-launch-of-hive-blockchain") do |content| ...
```

#### Example api call using script

And to do the same with our tutorial script

```bash
ruby get_post_details.rb https://hive.blog/communityfork/@hiveio/announcing-the-launch-of-hive-blockchain
```

#### Example Output

From the example we get the following output from our script

```
Post by hiveio
	title: Announcing the Launch of Hive Blockchain
	permlink: announcing-the-launch-of-hive-blockchain
	category: communityfork
	body_length: 10337 (1738 words)
	posted at: 2020-03-17T23:30:54, active at: 2020-10-12T05:25:03
	children: 978
	net_rshares: 0
	vote_rshares: 0
	payout:
		max_accepted_payout: 0.000 HBD
		percent_hbd: 100.00 %
		payout at: 2020-03-24T23:30:54 (358.0 days ago)
		author_rewards: 0.000 HBD
		curator_payout_value: 0.000 HBD
		total_payout_value: 0.000 HBD
	promoted: 0.000 HBD
	total_vote_weight: 0
	reward_weight: 100.00 %
	net_votes: 1337, upvotes: 997, downvotes: 3, unvotes: 0, total: 1000, top voter: blocktrades
	allow_replies: true
	allow_votes: true
	allow_curation_rewards: true
	author_reputation: 83492228581467
	tags: communityfork, hive, steemcommunity, steem
	app: steempeak/2020.03.6
```

### Post fields

Most console applications that use the `get_content` method are probably looking for the `body` field.  But there are many other fields to look at.  Let's break them down by use:

#### `parent_author`

In our script ([`get_post_details.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/05_get_post_details/get_post_details.rb)), we use the ruby statement:

```ruby
content.parent_author.empty?
```

With the above idiom, your application can determine if the content is a root post or reply.  If it's empty, then you're working with a root post, otherwise, it's a reply.

Once you know you're dealing with a reply, other fields can be useful for additional details.  For instance, `root_author`, `root_permlink`, and `root_title` can be used to figure out what the original post details are, even if the reply is deeply nested.

#### `last_update` and `created`

In our script, we use the ruby statement:

```ruby
content.last_update == content.created
```

With the above idiom, your application can determine if the content has been modified since it was originally posted.  If they are the same, then there has been no modification.

#### `cashout_time`

In our script, we use the ruby statement:

```ruby
(cashout = Time.parse(content.cashout_time + 'Z') - Time.now.utc) > 0
```

With the above idiom, you can use `cashout_time` to determine if the content has reached payout.  If `cashout_time` is in the future, the content has not been paid yet.  You can determine the possible future payout by inspecting `pending_payout_value`.

You will note that we must parse the string found in `content.cashout_time` by appending `Z` (Zulu Time, aka UTC) in order for `Time.parse` to get the right timezone.

Even before payout, you can determine what the `max_accepted_payout` is.  Most often, this is set to one of two values by the author:

* `1000000.000 HBD` - Accepted Payout
* `0.000 HBD` - Declined Payout

In addition to `max_accepted_payout`, the author may specify how much of the author reward should be in HIVE Power or liquid rewards.  The most common settings are:

* `10000` - Maximum Liquid Reward
* `0` - HIVE Power Only

Once the payout time has arrived, it's possible to determine the split between author and curation by inspecting at `author_rewards` and `curator_payout_value`.

#### `beneficiaries`

In our script, we use the ruby statement:

```ruby
content.beneficiaries.any?
```

Some content will have a `beneficiaries` array.  This is used to determine reward routes any account, up to eight.  Payouts are in HIVE Power and are expressed as a reward percentage of the author reward.

To display a list of who the beneficiaries are, use the following ruby code, as seen in the example:

```ruby
content.beneficiaries.each do |beneficiary|
  puts "\t\t#{beneficiary.account}: #{'%.2f %' % (beneficiary.weight / 100.0)}"
end
```

Note, if you just want an array of beneficiary account names, this will work in a pinch:

```ruby
accounts = content.beneficiaries.map do |beneficiary|
  beneficiary.account
end
```

#### `active_votes`

In our script, we use the ruby statements:

```ruby
votes = content.active_votes
upvotes = votes.select { |v| v.percent > 0 }.size
downvotes = votes.select { |v| v.percent < 0 }.size
unvotes = votes.select { |v| v.percent == 0 }.size
top_voter = votes.sort_by { |v| v.rshares.to_i }.last.voter
```

The above idiom splits all vote types and identifies the top voter.  This is because the `active_votes` field is an array that shows all votes applied to the content, including upvotes, downvotes, and unvotes (where a vote previously cast is revoked).

#### `json_metadata`

In our script, we use the ruby statements:

```ruby
metadata = JSON[content.json_metadata || '{}'] rescue {}
tags = metadata['tags'] || []
app = metadata['app']
```

As you can see from the above example, `json_metadata` starts out as a string of JSON that can be parsed to determine things like `tags` and `app`.  Other data may be present, depending on the application that created the content.

Note, we're using `rescue` in case the `json_metadata` string contains invalid JSON because there is no validation performed on this field by the blockchain when content is broadcasted.

{% include structures/comment.html %}

Final code:

```ruby
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

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

*`<content-url>` 

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/05_get_post_details
bundle install
ruby get_post_details.rb <content-url>
```
