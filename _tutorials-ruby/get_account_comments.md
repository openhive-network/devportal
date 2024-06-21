---
title: titles.get_account_comments
position: 9
description: "Fetching the comments written by a particular account."
layout: full
canonical_url: get_account_comments.html
---
Full, runnable src of [Get Account Comments](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/09_get_account_comments) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-09_get_account_comments.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/09_get_account_comments)).

Historically, applications that wanted to retrieve comments written by a particular account would use `get_state`.  But this method has been scheduled for deprecation.  So we'll use a more supported approach in this tutorial using `get_account_history`.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_discussions_by_comments]({{ '/apidefinitions/#tags_api.get_discussions_by_comments' | relative_url }})
* [condenser_api.get_discussions_by_comments]({{ '/apidefinitions/#condenser_api.get_discussions_by_comments' | relative_url }})
* [tags_api.get_discussions_by_created]({{ '/apidefinitions/#tags_api.get_discussions_by_created' | relative_url }})
* [condenser_api.get_discussions_by_created]({{ '/apidefinitions/#condenser_api.get_discussions_by_created' | relative_url }})

### Sections

1. [Making the api call](#making-the-api-call) - Requesting account history
    1. [Example api call](#example-api-call) - make the call in code
    1. [Example api call using script](#example-api-call-using-script) - using our tutorial script
    1. [Example Output](#example-output) - output from a successful call
1. [Comment Fields](#comment-fields) - Getting more detail than provided by account history.
1. [To Run](#to-run) - Running the example.

### Making the api call

[`get_account_comments.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/09_get_account_comments/get_account_comments.rb)

To request the latest comments by a particular author, we can use the `get_account_history` method:

```ruby
api = Radiator::Api.new

options = []
options << account_name
options << -1 # start
options << 1000 # limit

# This is optional, we can mask out all operations other than comment_operation.
operation_mask = 0x02 # comment_operation
options << (operation_mask & 0xFFFFFFFF) # operation_filter_low
options << ((operation_mask & 0xFFFFFFFF00000000) >> 32) # operation_filter_high

api.get_account_history(*options) do |history|
  history.each do |index, item|
    type, op = item.op
    
    next unless type == 'comment'
    next if op.parent_author.empty? # skip posts
    next if op.parent_author == account_name # skip replies to account

    # .
    # ... your code here
    # .
  end
end
```

Notice, the above example request up to 1,000 operations from history, starting from the oldest.  From these results, we iterate on each item in history to locate **a)** type of `comment`, and **b)** `parent_author` that do not match the `account_name`.

This example also shows how to mask out all but `comment_operation`.  This is optional, but by providing this mask, the api response will only include posts and replies, reducing the bandwidth required to execute this api call.

#### Example api call

If we want to get the comments by user @lordvader ...

```ruby
api.get_account_history("lordvader") do |content| ...
```

#### Example api call using script

And to do the same with our tutorial script
```bash
ruby get_account_comments.rb lordvader
```

#### Example Output

From the example we get the following output from our script:

```
.
.
.
Reply to @darkunicorn in discussion: "5 EASY WAYS TO MAKE A BEAUTIFUL WOMAN SMILE TO YOU."
	body_length: 89 (19 words)
	replied at: 2016-07-28T22:07:06
	net_votes: 0
	https://hive.blog/@lordvader/re-darkunicorn-5-easy-ways-to-make-a-beautiful-woman-smile-to-you-20160728t220708749z
Reply to @michaellamden68 in discussion: "Black Knight Satellite-What's Your Opinion?"
	body_length: 88 (16 words)
	replied at: 2016-07-28T22:10:09
	net_votes: 2
	https://hive.blog/@lordvader/re-michaellamden68-black-knight-satellite-what-s-your-opinion-20160728t221010607z
Reply to @teamsteem in discussion: "I’ve invited my 708 Facebook friends to join Steemit (updated I invited 0 friends thanks to Facebook)"
	body_length: 112 (22 words)
	replied at: 2016-07-28T22:03:18, updated at: 2016-07-28T22:12:42, active at: 2016-07-28T22:12:42
	net_votes: 0
	https://hive.blog/@lordvader/re-teamsteem-i-ve-invited-my-708-facebook-friends-to-join-steemit-20160728t220318695z
```

### Comment fields

Comments in the results of `get_account_history` will only return the following fields:

* `parent_author`
* `parent_permlink`
* `author`
* `permlink`
* `title`
* `body`
* `json_metadata`

In our example script, we want more detail than this, so for every `comment`, we call `get_content` to retrieve more detail.  For a full explanation of the results provided by `get_content`, please refer to the tutorial: [Get Post Details]({{ '/tutorials-ruby/get_post_details.html' | relative_url }})

Final code:

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

account_name = ARGV[0]
api = Radiator::Api.new

options = []
options << account_name
options << -1 # start
options << 1000 # limit

# This is optional, we can mask out all operations other than comment_operation.
operation_mask = 0x02 # comment_operation
options << (operation_mask & 0xFFFFFFFF) # operation_filter_low
options << ((operation_mask & 0xFFFFFFFF00000000) >> 32) # operation_filter_high

api.get_account_history(*options) do |history|
  history.each do |index, item|
    type, op = item.op
    
    next unless type == 'comment'
    next if op.parent_author.empty? # skip posts
    next if op.parent_author == account_name # skip replies to account
    
    url = "https://hive.blog/@#{op.author}/#{op.permlink}"
    api.get_content(op.author, op.permlink) do |reply|
      puts "Reply to @#{op.parent_author} in discussion: \"#{reply.root_title}\""
      
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

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/09_get_account_comments
bundle install
ruby get_account_comments.rb <account-name>
```
