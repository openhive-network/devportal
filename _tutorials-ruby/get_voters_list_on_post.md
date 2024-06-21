---
title: 'RB: Get Voters List On Post'
position: 6
description: "This example will output the active vote totals for the post/comment passed as an argument to the script."
layout: full
canonical_url: get_voters_list_on_post.html
---
Full, runnable src of [Get Voters List On Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/06_get_voters_list_on_post) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-06_get_voters_list_on_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/06_get_voters_list_on_post)).

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_active_votes]({{ '/apidefinitions/#tags_api.get_active_votes' | relative_url }})
* [condenser_api.get_active_votes]({{ '/apidefinitions/#condenser_api.get_active_votes' | relative_url }})

### Script

[`voter_list.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/06_get_voters_list_on_post/voter_list.rb)

First, we ask the blockchain for the active votes on a post or comment.  Then, we count the `upvotes`, `downvotes`, and `unvotes` (which are votes that have been removed after being cast in a previous transaction).

Then, we sort the votes by `rshares` to find the top voter.

Final code: 

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

url = ARGV[0]
slug = url.split('@').last
author, permlink = slug.split('/')
api = Radiator::Api.new

api.get_active_votes(author, permlink) do |votes|
  upvotes = votes.select { |v| v.percent > 0 }.size
  downvotes = votes.select { |v| v.percent < 0 }.size
  unvotes = votes.select { |v| v.percent == 0 }.size
  top_voter = votes.sort_by { |v| v.rshares.to_i }.last.voter
  
  puts "Upvotes: #{upvotes}"
  puts "Downvotes: #{downvotes}"
  puts "Unvotes: #{unvotes}"
  puts "Total: #{votes.size}"
  puts "Top Voter: #{top_voter}"
end

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/06_get_voters_list_on_post
bundle install
ruby voter_list.rb https://hive.blog/communityfork/@hiveio/announcing-the-launch-of-hive-blockchain
```

### Example Output

```
Upvotes: 997
Downvotes: 3
Unvotes: 0
Total: 1000
Top Voter: blocktrades
```
