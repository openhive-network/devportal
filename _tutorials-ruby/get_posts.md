---
title: 'RB: Get Posts'
position: 4
description: "This example will output posts depending on which category is provided as the arguments."
layout: full
canonical_url: get_posts.html
---
Full, runnable src of [Get Posts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/04_get_posts) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-04_get_posts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/04_get_posts)).

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})

### Script

[`get_posts_by_category.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/04_get_posts/get_posts_by_category.rb)

This script will pick a method to call based on the arguments passed.  The expected categories are:

* trending
* hot
* active
* created
* votes
* promoted
* children

We will base the name of the API method to execute on the provided argument.  Once we know which method to execute, we can build the query options.  The defaults for this script is `limit: 10` and `tag: ''`.

For each post we retrieve, we are going to build up a summary to display the interesting fields.  In this case, we're interested in:

* Creation Timestamp
* Title
* Author
* Net Votes
* Number of replies
* If it's promoted
* Number of words in the body
* Canonical URL


Final code:

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

CATEGORIES = %i(trending hot active created votes promoted children)

if ARGV.size < 1
  puts "Usage:"
  puts "ruby #{__FILE__} <#{CATEGORIES.join('|')}> [limit] [tag]"
  exit
end

category = ARGV[0].downcase.to_sym

unless CATEGORIES.include? category
  puts "Unknown category: #{category}"
  puts "Expecting one of: #{CATEGORIES.join(', ')}"
  exit
end

limit = (ARGV[1] || '10').to_i
tag = ARGV[2] || ''
api = Radiator::Api.new

options = {
  tag: tag,
  limit: limit
}

api.send("get_discussions_by_#{category}", options) do |posts, error|
  if !!error
    puts error.message
    exit
  end
  
  posts.each do |post|
    words = post.body.split(/\s/)
    author = post.author
    promoted = post.promoted
    uri = []

    uri << post.parent_permlink
    uri << "@#{author}"
    uri << post.permlink

    puts created = Time.parse(post.created + 'Z')
    puts "  Post: #{post.title}"
    puts "  By: #{author}"
    puts "  Votes: #{post.net_votes}"
    puts "  Replies: #{post.children}"
    puts "  Promoted: #{promoted}"
    puts "  Words: #{words.size}"
    puts "  https://hive.blog/#{uri.join('/')}"
  end
end

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/04_get_posts
bundle install
ruby get_posts_by_category.rb trending 1 hive
```

### Example Output

```
2021-03-17 15:47:36 UTC
  Post: Introducing DEC Farming on Cub Finance | Changes to Dens/Farms, 24 Hours Left for Wrapping CUB
  By: leofinance
  Votes:
  Replies: 81
  Promoted: 0.000 HBD
  Words: 1331
  https://hive.blog/hive-167922/@leofinance/introducing-dec-farming-on-cub-finance-or-changes-to-dens-farms-24-hours-left-for-wrapping-cub
```

#### Error Handling

We're checking the result for `error` in case the remote node has an issue to raise.  Normally, it will be `nil`, but if it's populated, output `error.message` and exit.
