---
title: 'RB: Search Tags'
position: 16
description: "Performing a search for tags."
layout: full
canonical_url: search_tags.html
---
Full, runnable src of [Search Tags](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/16_search_tags) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-16_search_tags.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/16_search_tags)).

This tutorial will return tags sorted by trending, up to a specified limit.

Also see:
* [condenser_api.get_trending_tags]({{ '/apidefinitions/#condenser_api.get_trending_tags' | relative_url }})

### Sections

1. [Making the api call](#making-the-api-call) - performing the lookup
    1. [Example api call](#example-api-call) - make the call in code
    1. [Example api call using script](#example-api-call-using-script) - using our tutorial script
    1. [Example Output](#example-output) - output from a successful call
    1. [Tag Fields](#tag-fields) - details of fields returned
1. [To Run](#to-run) - Running the example.

### Making the api call

[`search_tags.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/16_search_tags/search_tags.rb)

To request the a list of tags, we can use the `get_trending_tags` method:

```ruby
api = Radiator::Api.new

api.get_trending_tags(nil, 100) do |tags|
  puts tags
end
```

Notice, the above example can request up to 100 tags as an array.

#### Example api call

If we want to get 10 tags starting from the tag named "music" ...

```ruby
api.get_trending_tags("music", 10) do |content| ...
```

#### Example api call using script

And to do the same with our tutorial script, which has its own default limit of 10.  Internally, the api method only allows at most 100 results, so this tutorial will paginate the results to go beyond 100:

```bash
ruby search_tags.rb
```

#### Example Output

From the example we get the following output from our script:

```
tag: hive-148441, total_payouts: 13831.392 HBD, top_posts: 1716, comments: 3996
tag: hive-167922, total_payouts: 13735.647 HBD, top_posts: 1901, comments: 16164
tag: hive-105017, total_payouts: 4798.170 HBD, top_posts: 301, comments: 825
tag: hive-140217, total_payouts: 4513.385 HBD, top_posts: 385, comments: 692
tag: hive-120586, total_payouts: 4001.515 HBD, top_posts: 413, comments: 1435
tag: hive-194913, total_payouts: 3365.291 HBD, top_posts: 432, comments: 1480
tag: hive-163772, total_payouts: 3149.881 HBD, top_posts: 157, comments: 1155
tag: hive-129496, total_payouts: 2946.808 HBD, top_posts: 262, comments: 644
tag: hive-158489, total_payouts: 2938.784 HBD, top_posts: 135, comments: 1058
tag: hive-175254, total_payouts: 2651.732 HBD, top_posts: 196, comments: 1202
```

### Tag fields

Tags in the results of `get_trending_tags` returns the following fields:

* `name` - Name of the tag or empty.
* `total_payouts` - Rewards paid in this tag.
* `top_posts` - Top votes in this tag.
* `comments` - Number of comments in this tag.

Final code:

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new
limit = (ARGV[0] || '10').to_i
all_tags = []

until all_tags.size >= limit
  last_tag = if all_tags.any?
    all_tags.last.name
  else
    nil
  end
  
  api.get_trending_tags(last_tag, [limit, 51].min) do |tags|
    all_tags += tags
  end
  
  all_tags = all_tags.uniq
end

all_tags.each do |tag|
  print "tag: #{tag.name.empty? ? '<empty>' : tag.name},"
  print " total_payouts: #{tag.total_payouts},"
  print " top_posts: #{tag.top_posts},"
  print " comments: #{tag.comments}\n"
end

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/16_search_tags
bundle install
ruby search_tags.rb [limit]
```
