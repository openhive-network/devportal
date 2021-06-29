---
title: 'RB: Submit Post'
position: 10
description: "This example will broadcast a new post to the blockchain using the values provided.  To create a post in `ruby`, we will use a `Radiator::Transaction` containing a `comment` operation, which is how all content is stored internally."
layout: full
canonical_url: submit_post.html
---
Full, runnable src of [Submit Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/10_submit_post) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-10_submit_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/10_submit_post)).

A post is differentiated from a comment by whether or not a `parent_author` exists. When there is no `parent_author`, then it's a post, otherwise it's a comment.

Also see:
* [comment_operation]({{ '/apidefinitions/#broadcast_ops_comment' | relative_url }})

### Script

[`submit_a_new_post.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/10_submit_post/submit_a_new_post.rb)

You should change `wif` to the posting key that matches your `author`.  This script will pass along the values as a [`comment` operation]({{ '/apidefinitions/broadcast-ops.html#broadcast_ops_comment' | relative_url }}):

* `author` - Account name of the author currently posting.
* `permlink` - Value unique to the author 
* `parent_author` - An empty string, in the case of a root post like this example.
* `parent_permlink` - The first tag, in the case of a root post like this example.
* `title` - Human readable title.
* `body` - The actual content of the post.
* `json_metadata` - JSON containing all of the tags.

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

{% include local-testnet.html %}

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/10_submit_post
bundle install
ruby submit_a_new_post.rb
```

### Example Output

```json
{
  "jsonrpc": "2.0",
  "result": {
    "id": "768f7f64cee94413da0017ef79f592bb4da86baf",
    "block_num": 22867626,
    "trx_num": 43,
    "expired": false
  },
  "id": 1
}
```

The response we get after broadcasting the transaction gives us the transaction id ([`768f7f6...`](https://hiveblocks.com/tx/768f7f64cee94413da0017ef79f592bb4da86baf)), block number ([`22867626`](https://hiveblocks.com/b/22867626)), and the transaction number of that block (`43`).

#### Error Handling

We're checking the result for `error` in case the remote node has an issue to raise.  Normally, it will be `nil`, but if it's populated, output `error.message` and exit.
