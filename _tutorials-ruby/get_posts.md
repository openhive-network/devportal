---
title: 'RB: Get Posts'
position: 4
description: "This example will output posts depending on which category is provided as the arguments."
layout: full
canonical_url: get_posts.html
---
Full, runnable src of [Get Posts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/04_get_posts) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-04_get_posts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/04_get_posts)).

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
