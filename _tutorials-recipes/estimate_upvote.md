---
title: Estimate the value of an upvote
position: 1
description: Calculate the approximate value of an upvote on Hive
exclude: true
layout: full
canonical_url: estimate_upvote.html
---

This recipe will take you through the process of fetching necessary data and formulating estimation.

## Intro 

Calculating value of each vote depends on multiple factors. Reward fund, recent claims, account's total vests, rate of the hbd, voting power and weight of the vote. It is quite useful information for users to see and estimate. All of the data is possible to get via available APIs.

## Steps

1. **Get Reward Fund** Current reward fund information is crucial part of estimation
1. **Get Account** Hive power and voting power is another important info
1. **Feed history** To get price rate reported by witnesses
1. **Final calculation** Formulate all information we have


#### 1. Get Reward Fund

Getting Reward Fund information is simply calling `get_reward_fund('post')` api call, it will give us `reward_balance` and `recent_claims`.

The response we're working with will look like:

```json
{
	"id":0,
	"name":"post",
	"reward_balance":"741222.051 HIVE",
	"recent_claims":"457419472820935017",
	"last_update":"2018-05-23T12:08:36",
	"content_constant":"2000000000000",
	"percent_curation_rewards":2500,
	"percent_content_rewards":10000,
	"author_reward_curve":"linear",
	"curation_reward_curve":"square_root"
}
```

#### 2. Get Account

Next we will need total vests held by account, `get_accounts` api call returns account data, which will hold `vesting_shares`, `received_vesting_shares`, `delegated_vesting_shares`. It also returns current `voting_power` information.

The response example will look like:

```json
[
    {
      "id": 1370484,
      "name": "hiveio",
      "owner": {
        "weight_threshold": 1,
        "account_auths": [],
        "key_auths": [
          [
            "STM65PUAPA4yC4RgPtGgsPupxT6yJtMhmT5JHFdsT3uoCbR8WJ25s",
            1
          ]
        ]
      },
      "active": {
        "weight_threshold": 1,
        "account_auths": [],
        "key_auths": [
          [
            "STM69zfrFGnZtU3gWFWpQJ6GhND1nz7TJsKBTjcWfebS1JzBEweQy",
            1
          ]
        ]
      },
      "posting": {
        "weight_threshold": 1,
        "account_auths": [
          [
            "threespeak",
            1
          ],
          [
            "vimm.app",
            1
          ]
        ],
        "key_auths": [
          [
            "STM6vJmrwaX5TjgTS9dPH8KsArso5m91fVodJvv91j7G765wqcNM9",
            1
          ]
        ]
      },
      "memo_key": "STM7wrsg1BZogeK7X3eG4ivxmLaH69FomR8rLkBbepb3z3hm5SbXu",
      "json_metadata": "",
      "posting_json_metadata": "{\"profile\":{\"pinned\":\"none\",\"version\":2,\"website\":\"hive.io\",\"profile_image\":\"https://files.peakd.com/file/peakd-hive/hiveio/Jp2YHc6Q-hive-logo.png\",\"cover_image\":\"https://files.peakd.com/file/peakd-hive/hiveio/Xe1TcEBi-hive-banner.png\"}}",
      "proxy": "",
      "last_owner_update": "1970-01-01T00:00:00",
      "last_account_update": "2020-11-12T01:20:48",
      "created": "2020-03-06T12:22:48",
      "mined": false,
      "recovery_account": "steempeak",
      "last_account_recovery": "1970-01-01T00:00:00",
      "reset_account": "null",
      "comment_count": 0,
      "lifetime_vote_count": 0,
      "post_count": 31,
      "can_vote": true,
      "voting_manabar": {
        "current_mana": "598442432741",
        "last_update_time": 1591297380
      },
      "downvote_manabar": {
        "current_mana": "149610608184",
        "last_update_time": 1591297380
      },
      "voting_power": 0,
      "balance": "11.682 HIVE",
      "savings_balance": "0.000 HIVE",
      "hbd_balance": "43.575 HBD",
      "hbd_seconds": "0",
      "hbd_seconds_last_update": "2020-10-21T02:45:12",
      "hbd_last_interest_payment": "2020-10-21T02:45:12",
      "savings_hbd_balance": "0.000 HBD",
      "savings_hbd_seconds": "0",
      "savings_hbd_seconds_last_update": "1970-01-01T00:00:00",
      "savings_hbd_last_interest_payment": "1970-01-01T00:00:00",
      "savings_withdraw_requests": 0,
      "reward_hbd_balance": "0.000 HBD",
      "reward_hive_balance": "0.000 HIVE",
      "reward_vesting_balance": "0.000000 VESTS",
      "reward_vesting_hive": "0.000 HIVE",
      "vesting_shares": "598442.432741 VESTS",
      "delegated_vesting_shares": "0.000000 VESTS",
      "received_vesting_shares": "0.000000 VESTS",
      "vesting_withdraw_rate": "0.000000 VESTS",
      "post_voting_power": "598442.432741 VESTS",
      "next_vesting_withdrawal": "1969-12-31T23:59:59",
      "withdrawn": 0,
      "to_withdraw": 0,
      "withdraw_routes": 0,
      "pending_transfers": 0,
      "curation_rewards": 0,
      "posting_rewards": 604589,
      "proxied_vsf_votes": [
        0,
        0,
        0,
        0
      ],
      "witnesses_voted_for": 0,
      "last_post": "2021-03-23T18:05:48",
      "last_root_post": "2021-03-23T18:05:48",
      "last_vote_time": "1970-01-01T00:00:00",
      "post_bandwidth": 0,
      "pending_claimed_accounts": 0,
      "delayed_votes": [],
      "vesting_balance": "0.000 HIVE",
      "reputation": "88826789432105",
      "transfer_history": [],
      "market_history": [],
      "post_history": [],
      "vote_history": [],
      "other_history": [],
      "witness_votes": [],
      "tags_usage": [],
      "guest_bloggers": []
    }
  ]
  ```



#### 3. Feed history

Last thing we will need is rate of the `get_current_median_history_price`, returns median price rate bucket with `base` element.

The response example will look like:

```json
{
  "base": "3.029 HBD",
  "quote": "1.000 HIVE"
}
```

#### 4. Final calculation

After getting all these variables, all we have to do is to calculate estimation

```
total_vests = vesting_shares + received_vesting_shares - delegated_vesting_shares
final_vest = total_vests * 1e6
power = (voting_power * weight / 10000) / 50
rshares = power * final_vest / 10000
estimate = rshares / recent_claims * reward_balance * hbd_median_price
```
