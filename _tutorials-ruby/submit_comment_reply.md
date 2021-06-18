---
title: 'RB: Submit Comment Reply'
position: 11
description: "How to prepare comments for Hive and then submit using Radiator."
layout: full
canonical_url: submit_comment_reply.html
---
Full, runnable src of [Submit Comment Reply](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/11_submit_comment_reply) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-11_submit_comment_reply.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/11_submit_comment_reply)).

### Intro

This example will broadcast a reply to the blockchain using the values provided.  To create a post in `ruby`, we will use a `Radiator::Transaction` containing a `comment` operation, which is how all content is stored internally.

A reply is differentiated from a post by whether or not a `parent_author` exists. When there is no `parent_author`, then it's a post, otherwise it's a comment (like in this example).

Also see:
* [comment_operation]({{ '/apidefinitions/#broadcast_ops_comment' | relative_url }})

### Script

[`submit_comment_reply.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/11_submit_comment_reply/submit_comment_reply.rb)

You should change `wif` to the posting key that matches your `author`.  This script will pass along the values as a [`comment` operation]({{ '/apidefinitions/broadcast-ops.html#broadcast_ops_comment' | relative_url }}):

* `author` - Account name of the author currently replying.
* `permlink` - Value unique to the author 
* `parent_author` - The name of the author of the being replied to, in the case of a reply like this example.
* `parent_permlink` - The permlink of the content being replied to, in the case of a reply like this example.
* `title` - Typically empty.
* `body` - The actual content of the post.
* `json_metadata` - JSON containing the `parent_permlink` of the root post as a tags array.

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

{% include local-testnet.html %}

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/11_submit_comment_reply
bundle install
ruby submit_comment_reply.rb
```

### Example Output

```json
{
  "jsonrpc": "2.0",
  "result": {
    "id": "3fef14cac921e9baa7b31e43245e5380f3fb4332",
    "block_num": 23355115,
    "trx_num": 13,
    "expired": false
  },
  "id": 3
}
```

The response we get after broadcasting the transaction gives us the transaction id ([`3fef14c...`](https://hiveblocks.com/tx/3fef14cac921e9baa7b31e43245e5380f3fb4332)), block number ([`22867626`](https://hiveblocks.com/b/23355115)), and the transaction number of that block (`13`).

#### Error Handling

We're checking the result for `error` in case the remote node has an issue to raise.  Normally, it will be `nil`, but if it's populated, output `error.message` and exit.
