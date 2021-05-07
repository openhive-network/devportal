---
title: 'RB: Follow Another User'
position: 18
description: "*How to follow/unfollow another user.*"
layout: full
canonical_url: follow_another_user.html
---
Full, runnable src of [Follow Another User](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/18_follow_another_user) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-18_follow_another_user.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/18_follow_another_user)).

This tutorial will take you through the process of following/muting/unfollowing/unmuting an author and checking the follow status of an author.

Also see:
* [custom_json_operation]({{ '/apidefinitions/#broadcast_ops_custom_json' | relative_url }})

### Sections

1. [Follow](#follow)
1. [Check Follow](#check-follow)
1. [To Run](#to-run) - Running the example.

### Follow

[`follow.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/18_follow_another_user/follow.rb)

In the first example script, we can modify the initial configuration then run:

```bash
ruby follow.rb
```

Follows (and mutes) are expressed by `custom_json` with `id=follow` (mutes also use `id=follow`).

Example `custom_json` operation:

```json
{
  "id": "follow",
  "required_auths": [],
  "required_posting_auths": ["social"],
  "json": "[\"follow\",{\"follower\":\"social\",\"following\":\"alice\",\"what\":[\"blog\"]}]"
}
```

To broadcast this operation, use the posting `wif` and matching account name in `required_posting_auths`.  There are three variables required in the `json` field of the above operation:

1. `follower` - The specific account that will select the author to follow/unfollow.
2. `following` - The account/author that the account would like to follow.
3. `what` - The type of follow operation.  This variable can have one of three values: `blog` to follow an author, `ignore` to mute, and an empty string to unfollow/unmute.

#### Check Follow

In the second example script:

```bash
ruby check_follow.rb
```

The API method we're using here is `condenser.get_following`.  We pass the name of the account we're checking.  If the account follows more than 1,000 other accounts, we execute `condenser.get_following` multiple times and pass the last followed account we know about to get the next 1,000 (passing the latest `follows.last` each time).

We also specify `blog` to tell the API method that we're looking for followed, not muted (to locate muted accounts, use `ignore` instead of `blog`).

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/18_follow_another_user
bundle install
ruby follow.rb
```

### Example Output

```json
{
  "jsonrpc": "2.0",
  "result": {
    "id": "025688e27999d3aa514f1f0b77c9f8d8dae31d72",
    "block_num": 26349355,
    "trx_num": 3,
    "expired": false
  },
  "id": 3
}
```

The response we get after broadcasting (if enabled) the transaction gives us the transaction id ([`025688e...`](https://hiveblocks.com/tx/025688e27999d3aa514f1f0b77c9f8d8dae31d72)), block number ([`22867626`](https://hiveblocks.com/b/26349355)), and the transaction number of that block (`3`).
