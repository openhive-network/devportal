---
title: 'RB: Blog Feed'
position: 1
description: "This example will output blog details to the terminal for the author specified, limited to five results."
layout: full
canonical_url: blog_feed.html
---
Full, runnable src of [Blog Feed](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/01_blog_feed) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-01_blog_feed.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/01_blog_feed)).

### Script

[`blog_feed.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/01_blog_feed/blog_feed.rb)

The script parses the creation date, assuming Zulu timezone (AKA UTC).

The output will be the latest five posts/reblogs for the account specified.  If the author is the same as the account specified, it is assumed to be a post by this account.  Otherwise, it is assumed to be a reblog.

It also counts the words in the content body by splitting the text into an array of strings, delimited by whitespace.

Finally, it creates the canonical URL by combining `parent_permlink`, `author`, and `permlink`.

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/01_blog_feed
bundle install
ruby blog_feed.rb hiveio
```

### Example Output

```
2021-02-14 08:16:03 UTC
  Post: Around the Hive: Reflections
  By: hiveio
  Words: 423
  https://hive.blog/hiveecosystem/@hiveio/around-the-hive-reflections
2021-01-07 04:00:48 UTC
  Post: Hive and Kyros Ventures AMA
  By: hiveio
  Words: 2374
  https://hive.blog/hiveblockchain/@hiveio/hive-and-kyros-ventures-ama
2020-12-16 19:13:36 UTC
  Post: GetBlock x Hive : Providing Hive Node Services, Presenting at HiveFest, and a HIVE Giveaway
  By: hiveio
  Words: 602
  https://hive.blog/hiveblockchain/@hiveio/getblock-x-hive-providing-hive-node-services-presenting-at-hivefest-and-a-hive-giveaway
2020-11-12 01:20:36 UTC
  Post: Hive x Beaxy Livestream AMA - Answering Community Questions and HIVE Up for Grabs!
  By: hiveio
  Words: 258
  https://hive.blog/hiveblockchain/@hiveio/hive-x-beaxy-livestream-ama-answering-community-questions-and-hive-up-for-grabs
2020-10-22 18:59:54 UTC
  Post: Beaxy HIVE Listing Announcement
  By: hiveio
  Words: 419
  https://hive.blog/hiveblockchain/@hiveio/beaxy-hive-listing-announcement
```
