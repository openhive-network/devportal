---
title: titles.stream_blockchain_transactions
position: 13
description: descriptions.stream_blockchain_transactions
layout: full
canonical_url: stream_blockchain_transactions.html
---
Full, runnable src of [Stream Blockchain Transactions](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/13_stream_blockchain_transactions) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-13_stream_blockchain_transactions.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/13_stream_blockchain_transactions)).

To respond to live activity on the blockchain, a common approach is to make a request for the current block number, access all of the information in that block, and repeat.  Many API clients have dedicated tools for simplifying this process.  In Radiator, this tool is part of the `Radiator::Stream` class.  In addition, Radiator will allow you to specify exactly what type of operation you're interested in.

Also see:
* [block_api.get_block]({{ '/apidefinitions/#block_api.get_block' | relative_url }})
* [block_api.get_block_range]({{ '/apidefinitions/#block_api.get_block_range' | relative_url }})
* [account_history_api.enum_virtual_ops]({{ '/apidefinitions/#account_history_api.enum_virtual_ops' | relative_url }})

### Sections

1. [Streaming Transactions](#streaming-transactions)
1. [Streaming Operations](#streaming-operations)
1. [To Run](#to-run) - Running the example.

### Streaming Transactions

[`stream_blockchain_transactions.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/13_stream_blockchain_transactions/stream_blockchain_transactions.rb)

In the example script, we can stream transactions with the following arguments:

```bash
ruby stream_blockchain_transactions.rb head transactions
```

This will instruct the script to follow transactions at head `block_num` instead of irreversible.

See: [`head_block_number`]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html#head_block_number' | relative_url }}) vs. [`last_irreversible_block_num`]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html#last_irreversible_block_num' | relative_url }})

This is done by using the following ruby:

```ruby
stream.transactions(*args) do |trx|
  puts JSON.pretty_generate trx
end
```

The `args` variable contains the `start` (`block_num` to start from) and `mode` (`head` or `irreversible`).

#### Streaming Operations

In the example script, we can also pass the following arguments:

```bash
ruby stream_blockchain_transactions.rb head ops comment
```

This will instruct the script to follow the blockchain at head `block_num` instead of irreversible.  It will stream operations, with the type of `comment`.

The script will allow multiple operation types:

```bash
ruby stream_blockchain_transactions.rb head ops comment vote
```

Virtual operations are also allowed, but make sure to pass `irreversible` instead of `head`:

```bash
ruby stream_blockchain_transactions.rb irreversible ops producer_reward author_reward
```

Or, if you pass no operation types, the script will stream all types:

```bash
ruby stream_blockchain_transactions.rb head ops
```

This is done by using the following ruby:

```ruby
stream.operations(type, *args) do |op|
  puts op.to_json
end
```

The `type` variable can be `nil` or the type of ops we're looking for whereas `args` contains the `start` (`block_num` to start from) and `mode` (`head` or `irreversible`).

Final code:

```ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

mode = (ARGV[0] || 'irreversible').to_sym
what = (ARGV[1] || 'ops').to_sym
type = (ARGV[2..-1] || ['vote']).map(&:to_sym)
stream = Radiator::Stream.new

# Set to a block number you would like to begin streaming from, or leave nil
# to stream from the latest block.
start = nil
args = [start, mode]

case what
when :blocks
  stream.blocks(*args) do |block|
    block_num = block.block_id[0..7].hex
    print "block_num: #{block_num}"
    puts "; block_id: #{block.block_id}"
    print "\ttransactions: #{block.transactions.size}"
    print "; witness: #{block.witness}"
    puts "; timestamp: #{block.timestamp}"
  end
when :transactions
  stream.transactions(*args) do |trx|
    puts JSON.pretty_generate trx
  end
when :ops
  stream.operations(type, *args) do |op|
    puts op.to_json
  end
end

```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/13_stream_blockchain_transactions
bundle install
ruby stream_blockchain_transactions.rb
```

### Example Output

```json
{"voter":"piggypet","author":"tanama","permlink":"daily-2018-9-12","weight":10000}
{"voter":"votes4minnows","author":"askquestion","permlink":"latest-bitcoin-price-and-news-update-13-09-2018","weight":250}
{"voter":"vncedora2018","author":"adncabrera","permlink":"nicomedescuentalacadadelreytanospoema-98jxnjsjzu","weight":10000}
{"voter":"baimatjeh81","author":"albertvhons","permlink":"promoting-steemit-post-via-proof-of-participation-pop","weight":10000}
{"voter":"steemulator","author":"bonanza-kreep","permlink":"communicate-and-travel-with-alfa-enzo-new-social-network","weight":10000}
{"voter":"kernigeetrueset","author":"haejin","permlink":"vitamin-shoppe-vsi-analysis","weight":10000}
{"voter":"borrowedearth","author":"rijalmahyud","permlink":"this-is-my-job","weight":10000}
{"voter":"renatdag","author":"algarion","permlink":"cards-3-1536663927","weight":10000}
{"voter":"elieserurabno","author":"cathyhaack","permlink":"my-introduction-hello-word-of-steemit","weight":10000}
{"voter":"jmotip","author":"glennolua","permlink":"btc-chart-review-sept-12-20-00-pst","weight":10000}
{"voter":"bishalacharya","author":"barber78","permlink":"beautiful-cloudformations","weight":10000}
{"voter":"ivan174","author":"securixio","permlink":"cloud-mining-is-no-longer-profitable","weight":10000}
{"voter":"admiralbot","author":"homsys","permlink":"rare-photo-picture-698-105","weight":-10000}
```
