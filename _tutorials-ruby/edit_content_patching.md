---
title: 'RB: Edit Content Patching'
position: 12
description: Patching changes to a post on Hive.
layout: full
canonical_url: edit_content_patching.html
---
Full, runnable src of [Edit Content Patching](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/12_edit_content_patching) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-12_edit_content_patching.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/12_edit_content_patching)).

### Intro

This tutorial will show a technique for efficiently editing a post by only broadcasting changes to the post body.

### Script

[`edit_content_patching.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/12_edit_content_patching/edit_content_patching.rb)

This script will take an existing post and append a new line by broadcasting a `comment` operation containing a `diff` instruction.  This instruction will tell the blockchain to append new content to the end of the `body` of the original comment.

Because this is a live example, we set `broadcast` to `false` so that it only runs if you modify the example and set `broadcast` to `true`.

As stated earlier, you will need to change `broadcast` to `true`.  You can also set other values to test this script on other post:

* `wif` - The posting key of the author.
* `author` - Name of the account that wrote the post we're modifying.
* `title` - Title of the post.
* `permlink` - Leave this if the `permlink` is derived from the title or set it to the original `permlink` if you want to modify the title independently from the `permlink`.

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/12_edit_content_patching
bundle install
ruby edit_content_patching.rb
```

### Example Output

```
Changes:
@@ -26,8 +26,26 @@
  edited)
+%0AAppended content.
{
  "jsonrpc": "2.0",
  "result": {
    "id": "f327acc1c51d907a9ba9bfac70e6fc9e99ab2865",
    "block_num": 23035803,
    "trx_num": 0,
    "expired": false
  },
  "id": 1
}
```

The response we get after broadcasting (if enabled) the transaction gives us the transaction id ([`f327acc...`](https://hiveblocks.com/tx/f327acc1c51d907a9ba9bfac70e6fc9e99ab2865)), block number ([`22867626`](https://hiveblocks.com/b/23035803)), and the transaction number of that block (`0`).
