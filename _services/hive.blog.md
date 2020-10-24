---
title: hive.blog
position: 1
---

#### Hive.blog endpoints

Hive.blog offers a few endpoints for getting common data. User profile and post JSON data is very convenient and simple by appending .json
to your request. 

Getting a particular user profile JSON:

```
https://hive.blog/@curie.json
```

User object
```json
{
   "user":{
      "id":81544,
      "name":"curie",
      "owner":{
         "weight_threshold":1,
         "account_auths":[],
         "key_auths":[["STM69WGR1yhUdKrnzwQLDPnXrW9kaAERwHze8Uvtw2ecgRqCEjWxT", 1]]
      },
      "active":{
         "weight_threshold":1,
         "account_auths":[],
         "key_auths":[["STM5GAbbS84ViMEouJL3LKcM8VZzPejn68AfPaYaLZZDdmy98kwU5", 1]]
      },
      "posting":{
         "weight_threshold":1,
         "account_auths":[["steemauto", 1]],
         "key_auths":[["STM5cmuKw6EPkZWeVNXcZorKtattZTX5wSopcRb4xNe6VhRKjETgv", 1]]
      },
      "memo_key":"STM7ZBi61xYz1b9STE1PHcAraPXJbvafzge3AcPjcfeq4XkKtM2At",
      "json_metadata":{
         "profile":{
            "profile_image":"https://i.imgur.com/Mjewc66.jpg",
            "name":"Curie",
            "about":"Discovering exceptional content. ",
            "location":"Worldwide",
            "website":"http://curiesteem.com"
         }
      },
      "proxy":"",
      "last_owner_update":"1970-01-01T00:00:00",
      "last_account_update":"2018-02-28T14:21:24",
      "created":"2016-09-02T10:44:24",
      "mined":false,
      "recovery_account":"anonsteem",
      "last_account_recovery":"1970-01-01T00:00:00",
      "reset_account":"null",
      "comment_count":0,
      "lifetime_vote_count":0,
      "post_count":1042,
      "can_vote":true,
      "voting_power":8927,
      "last_vote_time":"2018-06-21T19:42:33",
      "balance":"24.519 HIVE",
      "savings_balance":"0.000 HIVE",
      "hbd_balance":"36.736 HBD",
      "hbd_seconds":"11732264931",
      "hbd_seconds_last_update":"2018-06-21T19:35:00",
      "hbd_last_interest_payment":"2018-06-15T14:05:03",
      "savings_hbd_balance":"0.000 HBD",
      "savings_hbd_seconds":"0",
      "savings_hbd_seconds_last_update":"1970-01-01T00:00:00",
      "savings_hbd_last_interest_payment":"1970-01-01T00:00:00",
      "savings_withdraw_requests":0,
      "reward_hbd_balance":"0.000 HBD",
      "reward_hive_balance":"0.000 HIVE",
      "reward_vesting_balance":"481.354811 VESTS",
      "reward_vesting_hive":"0.237 HIVE",
      "vesting_shares":"128367480.795804 VESTS",
      "delegated_vesting_shares":"0.000000 VESTS",
      "received_vesting_shares":"17069919.621493 VESTS",
      "vesting_withdraw_rate":"9672265.370398 VESTS",
      "next_vesting_withdrawal":"2018-06-24T14:01:51",
      "withdrawn":0,
      "to_withdraw":"125739449815180",
      "withdraw_routes":0,
      "curation_rewards":79730650,
      "posting_rewards":168964559,
      "proxied_vsf_votes":["1753316906111", 0, 0, 0],
      "witnesses_voted_for":1,
      "last_post":"2018-06-21T18:06:57",
      "last_root_post":"2018-06-19T13:16:15",
      "average_bandwidth":"540385456623",
      "lifetime_bandwidth":"33717478000000",
      "last_bandwidth_update":"2018-06-21T19:42:33",
      "average_market_bandwidth":"83841450748",
      "lifetime_market_bandwidth":"8042800000000",
      "last_market_bandwidth_update":"2018-06-19T04:21:42",
      "vesting_balance":"0.000 HIVE",
      "reputation":"418378051905700",
      "transfer_history":[],
      "market_history":[],
      "post_history":[],
      "vote_history":[],
      "other_history":[],
      "witness_votes":["curie"],
      "tags_usage":[],
      "guest_bloggers":[]
   },
   "status":"200"
}
```

Getting a particular post JSON:

```
https://hive.blog/curation/@curie/the-daily-curie-12-13-feb-2017.json
```

Post object
```json
{
  "post": {
    "id": 1965592,
    "author": "curie",
    "permlink": "the-daily-curie-12-13-feb-2017",
    "category": "curation",
    "parent_author": "",
    "parent_permlink": "curation",
    "title": "The Daily Curie (12-13 Feb 2017)",
    "body": "...",
    "json_metadata": {
      "tags": ["curation", "curie"],
      "users": [
        "nextgencrypto",
        "berniesanders",
        "val",
        "silversteem",
        "clayop",
        "hendrikdegrote",
        "proskynneo",
        "kushed",
        "curie"
      ],
      "image": [],
      "links": [],
      "app": "steemit/0.1",
      "format": "markdown"
    },
    "last_update": "2017-02-13T18:00:51",
    "created": "2017-02-13T18:00:51",
    "active": "2017-02-14T16:19:24",
    "last_payout": "2017-03-16T19:08:27",
    "depth": 0,
    "children": 9,
    "net_rshares": 0,
    "abs_rshares": 0,
    "vote_rshares": 0,
    "children_abs_rshares": 0,
    "cashout_time": "1969-12-31T23:59:59",
    "max_cashout_time": "1969-12-31T23:59:59",
    "total_vote_weight": 0,
    "reward_weight": 10000,
    "total_payout_value": "23.678 HBD",
    "curator_payout_value": "1.196 HBD",
    "author_rewards": 167726,
    "net_votes": 465,
    "root_author": "curie",
    "root_permlink": "the-daily-curie-12-13-feb-2017",
    "max_accepted_payout": "1000000.000 HBD",
    "percent_hbd": 0,
    "allow_replies": true,
    "allow_votes": true,
    "allow_curation_rewards": true,
    "beneficiaries": [],
    "url": "/curation/@curie/the-daily-curie-12-13-feb-2017",
    "root_title": "The Daily Curie (12-13 Feb 2017)",
    "pending_payout_value": "0.000 HBD",
    "total_pending_payout_value": "0.000 HBD",
    "active_votes": [],
    "replies": [],
    "author_reputation": "545477526857484",
    "promoted": "0.000 HBD",
    "body_length": 0,
    "reblogged_by": []
  },
  "status": "200"
}
```
