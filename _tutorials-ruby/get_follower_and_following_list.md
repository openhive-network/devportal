---
title: titles.get_follower_and_following
position: 19
description: descriptions.get_follower_and_following
layout: full
canonical_url: get_follower_and_following_list.html
---
Full, runnable src of [Get Follower And Following List](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/19_get_follower_and_following_list) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-19_get_follower_and_following_list.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/19_get_follower_and_following_list)).

This tutorial will take you through the process of requesting either the `follower` or `following` list for an account on the blockchain.

## Intro

In `radiator`, we can request follow results using `condenser_api.get_following` or `condenser_api.get_follows` methods.  These methods take the following arguments:

* `account` - The account for which the follower/following process will be executed.
* `start` - Where in the list to begin getting results.
* `type` - We are going to pass `blog` for all requests to only request follow results (as opposed to mute results, which takes the value: `ignore`).
* `limit` - The number of lines to be returned by the query (`limit`, maximum 1000 per call)

Also see:
* [condenser_api.get_following]({{ '/apidefinitions/#condenser_api.get_following' | relative_url }})
* [condenser_api.get_followers]({{ '/apidefinitions/#condenser_api.get_followers' | relative_url }})
* [condenser_api.get_follow_count]({{ '/apidefinitions/#condenser_api.get_follow_count' | relative_url }})

## Steps

1.  [**Configure connection**](#connection) Configuration of `radiator` to communicate with the Hive blockchain
2.  [**Input variables**](#input) Collecting the required inputs via command line arguments
3.  [**Get followers/following**](#query) Get the followers or accounts being followed
4.  [**Display**](#display) Return the array of results to the console

#### 1. Configure connection<a name="connection"></a>

[`get_follow.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/19_get_follower_and_following_list/get_follow.rb)

In the first few lines we initialize the configured library and packages (libraries are described in `Gemfile`):

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new
```

Above, we have `radiator` pointing to the production network.  To specify a different full node, e.g.:

```ruby
api = Radiator::Api.new(url: 'https://api.hive.blog')
```

#### 2. Input variables<a name="input"></a>

Capture the arguments from the command line.

```ruby
type = 'blog' # use 'ignore' to get mutes
account = ARGV[0]
what = ARGV[1] || 'following'
limit = (ARGV[2] || '-1').to_i
result = []
count = -1
```

#### 3. Get followers/following<a name="query"></a>

Depending on the arguments passed, we call the corresponding method and the element name of what we are requesting:

```ruby
method = "get_#{what}"
elem = what.sub(/s/, '').to_sym
```

The name of the `elem` value stored corresponds with the result elements we're interested in.  For method calls on `get_following`, we want the `following` elements.  For method calls on `get_followers`, we want `follower` elements.

#### 4. Display<a name="display"></a>

Iterate multiple calls to capture all of the results.

```ruby
until count >= result.size
  count = result.size
  response = api.send(method, account, result.last, type, [limit, 1000].max)
  abort response.error.message if !!response.error
  result += response.result.map(&elem)
  result = result.uniq
end
```

Final code:

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new

if ARGV.size < 1
  puts "Usage:"
  puts "ruby #{__FILE__} <account> [following|followers] [limit]"
  exit
end

type = 'blog' # use 'ignore' to get mutes
account = ARGV[0]
what = ARGV[1] || 'following'
limit = (ARGV[2] || '-1').to_i
result = []
count = -1

method = "get_#{what}"
elem = what.sub(/s/, '').to_sym

until count >= result.size
  count = result.size
  response = api.send(method, account, result.last, type, [limit, 1000].max)
  abort response.error.message if !!response.error
  result += response.result.map(&elem)
  result = result.uniq
end

puts result[0..limit]
puts "#{account} #{what}: #{result.size}"

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/19_get_follower_and_following_list
bundle install
ruby get_follow.rb
```
