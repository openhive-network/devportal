---
title: 'JS: Get Account Comments'
position: 9
description: How to retrieve account comments from the Hive blockchain.
layout: full
canonical_url: get_account_comments.html
---
Full, runnable src of [Get Account Comments](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/09_get_account_comments) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-09_get_account_comments.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/09_get_account_comments)).

This tutorial will show how to fetch comments made by a specific account (in this case `@hiveio`) by demonstrating how to use the `get_state` api function call. We will also demonstrate the most commonly used fields from the response object as well as how to parse the body of each comment.

## Intro

We are using the `get_state` function with `dhive` that returns the current state of the network as well as additional content. Each content body is written in markdown and could be submitted to the blockchain by many different applications built on top of Hive. For that reason we are using the `remarkable` npm package to parse markdown in a readable format.

## Steps

1. [**App setup**](#app-setup) Configuration of `dhive` to use the proper connection and network.
1. [**Query**](#query) Query the path which we want to extract from Hive blockchain state.
1. [**Formatting**](#formatting) Formatting the JSON object to be viewed in a simple user interface.

#### 1. App setup<a name="app-setup"></a>

Below we have `dhive` pointing to the main network with the proper chainId, addressPrefix and connection server.
There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define and configure library and packages.

```javascript
const dhive = require('@hivechain/dhive');
let opts = {};
//connect to production server
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to server which is connected to the network/production
const client = new dhive.Client('https://api.hive.blog');

const Remarkable = require('remarkable');
const md = new Remarkable({ html: true, linkify: true });
```

`remarkable` is assigned to the variable `md` with linkify and html options, allowing us to parse markdown links and html properly.

#### 2. Query<a name="query"></a>

Next, we have the `main` function which runs when the page is loaded.

```javascript
// query string, fetching comments made by @hiveio account
const query = '/@hiveio/comments';

client.database.call('get_state', [query]).then(result => {
    // work with state object
});
```

`query` is the path from where want to extract Hive blockchain state. In our example we are querying `comments` from the `@hiveio` account. The result will be the current state object with various information as well as the `content` property holding the content of the query.

The following is an example of the returned object:

```json
{
    "current_route":"/@hiveio/comments",
    "props":{
        "head_block_number":22307429,
        "head_block_id":"01546265c9dc3e761add4c4b652743e3c640fa19",
        "time":"2018-05-10T12:15:30",
        "current_witness":"smooth.witness",
        "total_pow":514415,
        "num_pow_witnesses":172,
        "virtual_supply":"271970374.699 HIVE",
        "current_supply":"268140818.508 HIVE",
        "confidential_supply":"0.000 HIVE",
        "current_hbd_supply":"13342173.771 HBD",
        "confidential_hbd_supply":"0.000 HBD",
        "total_vesting_fund_hive":"191002132.498 HIVE",
        "total_vesting_shares":"388786707656.308148 VESTS",
        "total_reward_fund_hive":"0.000 HIVE",
        "total_reward_shares2":"0",
        "pending_rewarded_vesting_shares":"366359809.533218 VESTS",
        "pending_rewarded_vesting_hive":"178575.754 HIVE",
        "hbd_interest_rate":0,
        "hbd_print_rate":10000,
        "maximum_block_size":65536,
        "current_aslot":22373110,
        "recent_slots_filled":"340282366920938463463374607431768211455",
        "participation_count":128,
        "last_irreversible_block_num":22307411,
        "vote_power_reserve_rate":10,
        "average_block_size":14881,
        "current_reserve_ratio":200000000,
        "max_virtual_bandwidth":"264241152000000000000"
    },
    "tag_idx":{
        "trending":["","life","photography","hiveio","kr","introduceyourself","bitcoin","art","travel","cryptocurrency","spanish","food","hive","blog","funny","news","nature","colorchallenge","dtube","indonesia","story","cn","money","music","writing","crypto","contest","busy","health","poetry","meme","video","utopian-io","photo","new","love","blockchain","deutsch","dmania","science","technology","aceh","entertainment","gaming","politics","myanmar","esteem","sports","fun","tr"]
    },
    "tags":{},
    "content":{
        "hiveio/afm007-re-hiveio-devportal-update-3-ux-improvements-more-javascript-tutorials-and-more-20180509t050215510z":{
            "id":47669989,
            "author":"hiveio",
            "permlink":"afm007-re-hiveio-devportal-update-3-ux-improvements-more-javascript-tutorials-and-more-20180509t050215510z",
            "category":"hive",
            "parent_author":"afm007",
            "parent_permlink":"devportal-update-3-ux-improvements-more-javascript-tutorials-and-more","title":"","body":"I want to learn the Python language.",
            "json_metadata":"{''}",
            "last_update":"2018-05-09T05:02:15",
            "created":"2018-05-09T05:02:15",
            "active":"2018-05-09T05:02:15",
            "last_payout":"1970-01-01T00:00:00",
            "depth":1,
            "children":0,
            "net_rshares":1057692008,
            "abs_rshares":1057692008,
            "vote_rshares":1057692008,
            "children_abs_rshares":0,
            "cashout_time":"2018-05-16T05:02:15",
            "max_cashout_time":"1969-12-31T23:59:59",
            "total_vote_weight":32523,
            "reward_weight":10000,
            "total_payout_value":"0.000 HBD",
            "curator_payout_value":"0.000 HBD",
            "author_rewards":0,
            "net_votes":1,
            "root_author":"hiveio",
            "root_permlink":"devportal-update-3-ux-improvements-more-javascript-tutorials-and-more",
            "max_accepted_payout":"1000000.000 HBD",
            "percent_hbd":10000,
            "allow_replies":true,
            "allow_votes":true,
            "allow_curation_rewards":true,
            "beneficiaries":[],
            "url":"/hive/@hiveio/devportal-update-3-ux-improvements-more-javascript-tutorials-and-more#@afm007/afm007-re-hiveio-devportal-update-3-ux-improvements-more-javascript-tutorials-and-more-20180509t050215510z",
            "root_title":"DevPortal Update #3: UX Improvements, More Javascript Tutorials and More!",
            "pending_payout_value":"0.005 HBD",
            "total_pending_payout_value":"0.000 HIVE",
            "active_votes":[{"voter":"afm007","weight":17182,"rshares":1057692008,"percent":10000,"reputation":"855556264424","time":"2018-05-09T05:18:06"}],
            "replies":[],
            "author_reputation":"855556264424",
            "promoted":"0.000 HBD",
            "body_length":0,
            "reblogged_by":[]
        },
        "hiveio/re-hiveio-devportal-update-3-ux-improvements-more-javascript-tutorials-and-more-20180509t045305223z":{
            "id":47669080,
            "author":"hiveio",
            "permlink":"re-hiveio-devportal-update-3-ux-improvements-more-javascript-tutorials-and-more-20180509t045305223z",
            "category":"hive",
            "parent_author":"andreina89",
            "parent_permlink":"devportal-update-3-ux-improvements-more-javascript-tutorials-and-more",
            "title":"",
            "body":"Excellent post very interesting friend, thanks",
            "json_metadata":"{\"tags\":[\"hive\"],\"app\":\"hiveblog/0.1\"}",
            "last_update":"2018-05-09T04:53:21",
            "created":"2018-05-09T04:53:21",
            "active":"2018-05-09T04:53:27",
            "last_payout":"1970-01-01T00:00:00",
            "depth":1,
            "children":1,
            "net_rshares":0,
            "abs_rshares":0,
            "vote_rshares":0,
            "children_abs_rshares":0,
            "cashout_time":"2018-05-16T04:53:21",
            "max_cashout_time":"1969-12-31T23:59:59",
            "total_vote_weight":0,
            "reward_weight":10000,
            "total_payout_value":"0.000 HBD",
            "curator_payout_value":"0.000 HBD",
            "author_rewards":0,
            "net_votes":0,
            "root_author":"hiveio",
            "root_permlink":"devportal-update-3-ux-improvements-more-javascript-tutorials-and-more",
            "max_accepted_payout":"1000000.000 HBD",
            "percent_hbd":10000,
            "allow_replies":true,
            "allow_votes":true,
            "allow_curation_rewards":true,
            "beneficiaries":[],
            "url":"/hive/@hiveio/devportal-update-3-ux-improvements-more-javascript-tutorials-and-more#@andreina89/re-hiveio-devportal-update-3-ux-improvements-more-javascript-tutorials-and-more-20180509t045305223z",
            "root_title":"DevPortal Update #3: UX Improvements, More Javascript Tutorials and More!",
            "pending_payout_value":"0.000 HBD",
            "total_pending_payout_value":"0.000 HIVE",
            "active_votes":[],
            "replies":[],
            "author_reputation":"174938588721",
            "promoted":"0.000 HBD",
            "body_length":0,"reblogged_by":[]
        }
    },
    "accounts":{
        "hiveio":{},
    },
    "witnesses":{},
    "discussion_idx":{},
    "witness_schedule":{
        "id":0,
        "current_virtual_time":"326078326927286190874576091",
        "next_shuffle_block_num":22307439,
        "current_shuffled_witnesses":["furion","someguy123","good-karma","blocktrades","smooth.witness"],
        "num_scheduled_witnesses":21,
        "top19_weight":1,
        "timeshare_weight":5,
        "miner_weight":1,
        "witness_pay_normalization_factor":25,
        "median_props":{
            "account_creation_fee":"0.100 HIVE",
            "maximum_block_size":65536,
            "hbd_interest_rate":0
        },
        "majority_version":"0.19.3",
        "max_voted_witnesses":20,
        "max_miner_witnesses":0,
        "max_runner_witnesses":1,
        "hardfork_required_witnesses":17
    },
    "feed_price":{
        "base":"3.484 HBD",
        "quote":"1.000 HIVE"
    }
}
```

#### 3. Formatting<a name="formatting"></a>

Next we will format the above object properly to view in a simple user interface. From the above object, we are only interested in the `content` object which holds the data we require.

```javascript
if (
    !(
        Object.keys(result.content).length === 0 &&
        result.content.constructor === Object
    )
) {
    var comments = [];
    Object.keys(result.content).forEach(key => {
        const comment = result.content[key];
        const parent_author = comment.parent_author;
        const parent_permlink = comment.parent_permlink;
        const created = new Date(comment.created).toDateString();
        const body = md.render(comment.body);
        const netvotes = comment.net_votes;
        comments.push(
            `<div class="list-group-item list-group-item-action flex-column align-items-start">\
            <div class="d-flex w-100 justify-content-between">\
              <h6 class="mb-1">@${comment.author}</h6>\
              <small class="text-muted">${created}</small>\
            </div>\
            <p class="mb-1">${body}</p>\
            <small class="text-muted">&#9650; ${netvotes}, Replied to: @${parent_author}/${parent_permlink}</small>\
          </div>`
        );
    });
    document.getElementById('comments').style.display = 'block';
    document.getElementById('comments').innerHTML = comments.join('');
}
```

We first check if `content` is not an empty object. We then iterate through each object in `content` and extract:

* `parent_author`
* `parent_permlink`
* and the post or comment the `@hiveio` account is replying to

We format `created` date and time, parse `body` markdown and get `net_votes` on that comment.
Each line is then pushed and displayed separately.

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/09_get_account_comments`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
