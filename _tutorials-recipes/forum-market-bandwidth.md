---
title: Forum/Market Bandwidth
position: 1
description: How to interpret raw bandwidth data.
exclude: true
layout: full
canonical_url: forum-market-bandwidth.html
---

### Intro

<h4 class="danger well">
  Please note, Bandwidth has been replaced by <a href="{{ '/search/?q=resource+credits' | relative_url }}">Resource Credits</a>.  This document is outdated and will remain in place to give historical context prior to HF20.  Also see: <a href="{{ '/tutorials-recipes/rc-bandwidth-system.html' | relative_url }}">RC Bandwidth System</a>, <a href="{{ 'https://github.com/steemit/steem/releases/tag/v0.20.2' | archived_url }}">0.20.2 Release Notes</a>, <a href="https://hive.blog/steem/@steemitdev/developer-guide-resource-credit-system">Developer Guide: Resource Credit System</a>
</h4>

We're going over the various API calls needed to determine the remaining bandwidth available to a particular account.  As mentioned in the [HIVE Whitepaper](https://hive.io/steem-whitepaper.pdf):

> Bandwidth used by an individual user should be measured over a suitably long period of time to allow that
user to time-shift their usage. Users tend to login, do many things at once, then logout. This means that
their bandwidth over a short period of time may appear much higher than if viewed over a longer period of
time. If the time window is stretched too far, then the reserve ratio will not adjust fast enough to respond
to short-term surges; conversely, if the window is too short then clustering usage will have too big of an
impact on normal users.

Bandwidth is specific to each account and depends on account activity.

### Sections

1. [Getting Account Bandwidth](#getting-account-bandwidth)
1. [Dynamic Global Properties](#dynamic-global-properties)
1. [Account HIVE Power](#account-hive-power)
1. [Calculate](#calculate)

### Getting Account Bandwidth

```bash
curl -s --data '{
   "jsonrpc":"2.0",
   "method":"condenser_api.get_account_bandwidth",
   "params":[
      "cheetah",
      "forum"
   ],
   "id":1
}' https://api.hive.blog
```

```json
{
   "jsonrpc":"2.0",
   "result":{
      "id":20846,
      "account":"cheetah",
      "type":"forum",
      "average_bandwidth":"7525646416619",
      "lifetime_bandwidth":"386010589000000",
      "last_bandwidth_update":"2018-07-18T16:37:54"
   },
   "id":1
}
```

In this example, we got forum (blogging) average bandwidth of 7,525,646,416,619 with a lifetime bandwidth of 386,010,589,000,000.

Note, `average_bandwidth` is expressed as an integer with six decimal places represented.  Divide by 1,000,000 in order to get the actual bytes of bandwidth, in this case: 7,525,646 bytes.

### Dynamic Global Properties

To do the calculation, we need `max_virtual_bandwidth` and `total_vesting_shares` from the global properties, e.g.:

```bash
curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_dynamic_global_properties", "params":[], "id":1}' https://api.hive.blog
```

```json
{
   "id":1,
   "jsonrpc":"2.0",
   "result":{
      "head_block_number":24264289,
      "head_block_id":"01723e6156ad44ac7bf3028a53a7ac642084cb39",
      "time":"2018-07-17T20:25:27",
      "current_witness":"followbtcnews",
      "total_pow":514415,
      "num_pow_witnesses":172,
      "virtual_supply":"283443693.176 HIVE",
      "current_supply":"271786073.683 HIVE",
      "confidential_supply":"0.000 HIVE",
      "current_hbd_supply":"15504633.926 HBD",
      "confidential_hbd_supply":"0.000 HBD",
      "total_vesting_fund_hive":"193007548.472 HIVE",
      "total_vesting_shares":"391468555319.000697 VESTS",
      "total_reward_fund_hive":"0.000 HIVE",
      "total_reward_shares2":"0",
      "pending_rewarded_vesting_shares":"382967391.274340 VESTS",
      "pending_rewarded_vesting_hive":"187173.234 HIVE",
      "hbd_interest_rate":0,
      "hbd_print_rate":2966,
      "maximum_block_size":65536,
      "current_aslot":24341309,
      "recent_slots_filled":"340282366920938463463374607431768211455",
      "participation_count":128,
      "last_irreversible_block_num":24264271,
      "vote_power_reserve_rate":10,
      "average_block_size":13436,
      "current_reserve_ratio":200000000,
      "max_virtual_bandwidth":"264241152000000000000"
   }
}
```

### Account HIVE Power

We also need to know how much the account has in HIVE Power from `vesting_shares` and `received_vesting_shares`:

```bash
curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_accounts", "params":[["cheetah"]], "id":1}' https://api.hive.blog
```

```json
{
  "jsonrpc": "2.0",
  "result": [
    {
      "id": 25796,
      "name": "cheetah",
      "owner": {
        "weight_threshold": 1,
        "account_auths": [],
        "key_auths": [["STM7yFmwPSKUP7FCV7Ut9Aev5cwfDzJZixcreS1U3ha36XG47ZpqT", 1]]
      },
      "active": {
        "weight_threshold": 1,
        "account_auths": [],
        "key_auths": [["STM7yFmwPSKUP7FCV7Ut9Aev5cwfDzJZixcreS1U3ha36XG47ZpqT", 1]]
      },
      "posting": {
        "weight_threshold": 1,
        "account_auths": [["anyx", 100]],
        "key_auths": [["STM5bicRFWhpxnwBymo2HHJv6mFLiaP6AwVVsFEnnVjVcqbvqzvFt", 100], ["STM7yFmwPSKUP7FCV7Ut9Aev5cwfDzJZixcreS1U3ha36XG47ZpqT", 100], ["STM8Jn23vNmBzVuDAgQeZzzR17LmruENmmZmv1ra53tbsBgYbJFwk", 100]]
      },
      "memo_key": "STM7yFmwPSKUP7FCV7Ut9Aev5cwfDzJZixcreS1U3ha36XG47ZpqT",
      "json_metadata": "{\"profile\":{\"profile_image\":\"https://c1.staticflickr.com/6/5739/22389343016_25d10c52a3_b.jpg\",\"about\":\"I am a robot that automatically finds similar content. Check the website linked to on my blog to learn more about me!\",\"website\":\"http://steemit.com/steemit/@cheetah/faq-about-cheetah\"}}",
      "posting_json_metadata": "{\"profile\":{\"profile_image\":\"https://c1.staticflickr.com/6/5739/22389343016_25d10c52a3_b.jpg\",\"about\":\"I am a robot that automatically finds similar content. Check the website linked to on my blog to learn more about me!\",\"website\":\"http://steemit.com/steemit/@cheetah/faq-about-cheetah\"}}",
      "proxy": "anyx",
      "last_owner_update": "1970-01-01T00:00:00",
      "last_account_update": "2017-06-13T00:14:00",
      "created": "2016-07-17T08:47:18",
      "mined": true,
      "recovery_account": "steem",
      "last_account_recovery": "1970-01-01T00:00:00",
      "reset_account": "null",
      "comment_count": 0,
      "lifetime_vote_count": 0,
      "post_count": 708152,
      "can_vote": true,
      "voting_manabar": {
        "current_mana": "4023352886501",
        "last_update_time": 1604341680
      },
      "downvote_manabar": {
        "current_mana": "1005838221624",
        "last_update_time": 1604341680
      },
      "voting_power": 0,
      "balance": "0.893 HIVE",
      "savings_balance": "0.000 HIVE",
      "hbd_balance": "0.000 HBD",
      "hbd_seconds": "3928548",
      "hbd_seconds_last_update": "2020-11-02T18:28:39",
      "hbd_last_interest_payment": "2020-11-02T18:28:00",
      "savings_hbd_balance": "0.000 HBD",
      "savings_hbd_seconds": "0",
      "savings_hbd_seconds_last_update": "1970-01-01T00:00:00",
      "savings_hbd_last_interest_payment": "1970-01-01T00:00:00",
      "savings_withdraw_requests": 0,
      "reward_hbd_balance": "0.000 HBD",
      "reward_hive_balance": "0.000 HIVE",
      "reward_vesting_balance": "0.000000 VESTS",
      "reward_vesting_hive": "0.000 HIVE",
      "vesting_shares": "29.977557 VESTS",
      "delegated_vesting_shares": "0.000000 VESTS",
      "received_vesting_shares": "0.000000 VESTS",
      "vesting_withdraw_rate": "0.000000 VESTS",
      "post_voting_power": "29.977557 VESTS",
      "next_vesting_withdrawal": "1969-12-31T23:59:59",
      "withdrawn": "4023322908944",
      "to_withdraw": "4023322908944",
      "withdraw_routes": 1,
      "pending_transfers": 0,
      "curation_rewards": 170300,
      "posting_rewards": 77551038,
      "proxied_vsf_votes": ["57961386919580", "25638086327", 0, 0],
      "witnesses_voted_for": 0,
      "last_post": "2020-10-14T15:10:27",
      "last_root_post": "2020-10-14T00:00:03",
      "last_vote_time": "2020-10-14T15:10:24",
      "post_bandwidth": 10000,
      "pending_claimed_accounts": 0,
      "delayed_votes": [],
      "vesting_balance": "0.000 HIVE",
      "reputation": "942693160055713",
      "transfer_history": [],
      "market_history": [],
      "post_history": [],
      "vote_history": [],
      "other_history": [],
      "witness_votes": [],
      "tags_usage": [],
      "guest_bloggers": []
    }
  ],
  "id": 1
}
```

### Calculate

Now, we can derive `bandwidth_allocated`:

`bandwidth_allocated = max_virtual_bandwidth * (vesting_shares + received_vesting_shares) / total_vesting_shares`

`bandwidth_allocated = bandwidth_allocated / 1000000`

In our example, `bandwidth_allocated = 14034118993`.

Now that we have both `bandwidth_allocated` and `average_bandwidth`, we can determine the percentages.

First, we need `average_bandwidth` on the same scale as `bandwidth_allocated`:

`average_bandwidth = average_bandwidth / 1000000`

Then we can get the percentages:

`bandwidth_used = 100 * average_bandwidth / bandwidth_allocated`

`bandwidth_remaining = 100 - (100 * average_bandwidth / bandwidth_allocated)`

We can see that `cheetah` has used `0.053 %` bandwidth and has `99.946 %` remaining as of `last_bandwidth_update`.
