---
title: 'RB: Get Account Replies'
position: 8
description: "Fetching the replies written to a particular account."
layout: full
canonical_url: get_account_replies.html
---
Full, runnable src of [Get Account Replies](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/08_get_account_replies) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-08_get_account_replies.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/08_get_account_replies)).

Historically, applications that wanted to retrieve replies written to a particular account would use `get_state`.  But this method has been scheduled for deprecation.  So we'll use a more supported approach in this tutorial using `get_account_history`.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_content_replies]({{ '/apidefinitions/#tags_api.get_content_replies' | relative_url }})
* [condenser_api.get_content_replies]({{ '/apidefinitions/#condenser_api.get_content_replies' | relative_url }})

### Sections

1. [Making the api call](#making-the-api-call) - Requesting account history
    1. [Example api call](#example-api-call) - make the call in code
    1. [Example api call using script](#example-api-call-using-script) - using our tutorial script
    1. [Example Output](#example-output) - output from a successful call
1. [Comment Fields](#comment-fields) - Getting more detail than provided by account history.
1. [To Run](#to-run) - Running the example.

### Making the api call

[`get_account_replies.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/08_get_account_replies/get_account_replies.rb)

To request the latest replies to a particular author, we can use the `get_account_history` method:

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
    next unless op.parent_author == account_name # skip comments by account

    # .
    # ... your code here
    # .
  end
end
```

Notice, the above example request up to 1,000 operations from history, starting from the oldest.  From these results, we iterate on each item in history to locate **a)** type of `comment`, and **b)** `parent_author` that match the `account_name`.

This example also shows how to mask out all but `comment_operation`.  This is optional, but by providing this mask, the api response will only include posts and replies, reducing the bandwidth required to execute this api call.

#### Example api call

If we want to get the replies to user @lordvader ...

```ruby
api.get_account_history("lordvader") do |content| ...
```

#### Example api call using script

And to do the same with our tutorial script
```bash
ruby get_account_replies.rb lordvader
```

#### Example Output

From the example we get the following output from our script:

```
Reply by @hivebuzz in discussion: "Join the 501st Legion and Rule Drug Wars!"
	body_length: 1103 (172 words)
	replied at: 2020-06-06T22:36:33
	net_votes: 0
	https://hive.blog/@hivebuzz/hivebuzz-notify-lordvader-20200606t223635000z
Reply by @obrisgold1 in discussion: "Join the 501st Legion and Rule Drug Wars!"
	body_length: 51 (10 words)
	replied at: 2020-07-21T14:25:00
	net_votes: 0
	https://hive.blog/@obrisgold1/re-lordvader-qdtpdo
```

### Comment fields

Replies in the results of `get_account_history` will only return the following fields:

* `parent_author`
* `parent_permlink`
* `author`
* `permlink`
* `title`
* `body`
* `json_metadata`

In our example script, we want more detail than this, so for every `comment`, we call `get_content` to retrieve more detail.  For a full explanation of the results provided by `get_content`, please refer to the tutorial: [Get Post Details]({{ '/tutorials-ruby/get_post_details.html' | relative_url }})

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/08_get_account_replies
bundle install
ruby get_account_replies.rb <account-name>
```
