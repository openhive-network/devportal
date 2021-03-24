---
title: 'RB: Search Accounts'
position: 15
description: "Performing a search on account by names starting with a given input."
layout: full
canonical_url: search_accounts.html
---
Full, runnable src of [Search Accounts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/15_search_accounts) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-15_search_accounts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/15_search_accounts)).

This tutorial will return account names matching the input given, up to a specified limit.

### Sections

1. [Making the api call](#making-the-api-call) - performing the lookup
    1. [Example api call](#example-api-call) - make the call in code
    1. [Example api call using script](#example-api-call-using-script) - using our tutorial script
    1. [Example Output](#example-output) - output from a successful call
1. [To Run](#to-run) - Running the example.

### Making the api call

[`search_accounts.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/15_search_accounts/search_accounts.rb)

To request the a list of accounts starting with a particular lookup pattern, we can use the `lookup_accounts` method:

```ruby
api = Radiator::Api.new

api.lookup_accounts(lower_bound_name, limit) do |accounts|
  puts accounts.join(' ')
end
```

Notice, the above example can request up to 1000 accounts as an array.

#### Example api call

If we want to get the accounts starting with "alice" ...

```ruby
api.lookup_accounts("alice", 10) do |content| ...
```

#### Example api call using script

And to do the same with our tutorial script, which has its own default limit of 10:

```bash
ruby search_accounts.rb alice
```

#### Example Output

From the example we get the following output from our script:

```
alice alice-22 alice-is alice-labardo alice-mikhaylova alice-n-chains alice-radster alice-sandra alice-thuigh alice-way
```

#### Example api call using script, with limit

And to do the same with our tutorial script, which has its own default limit of 10:

```bash
ruby search_accounts.rb bob 1
```

#### Example Output, with limit

From the example we get the following output from our script:

```
bob
```

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/15_search_accounts
bundle install
ruby search_accounts.rb <lower-bound-name> [limit]
```
