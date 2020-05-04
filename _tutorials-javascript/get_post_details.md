---
title: 'JS: Get Post Details'
position: 5
description: How to get post details and use them appropriately.
layout: full
canonical_url: get_post_details.html
---
Full, runnable src of [Get Post Details](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/05_get_post_details) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-05_get_post_details.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/05_get_post_details)).

The purpose of this tutorial is to **a)** demonstrate how to get a list of articles from the trending list on the blockchain, and **b)** fetch the contents of the selected post to display its title and body.

We will also explain the most commonly used fields from the response object as well as parse body of the post.

## Intro

Accounts have unique `permlink` - permanent link for each of their posts. And Hive blockchain provides API to directly fetch current state of the post and its details. We will be using `get_content` to retrieve additional details. We can easily reformat data in a way that fits out application.

## Steps

1. [**Fetching posts**](#fetch-posts) Trending posts list
1. [**Post content**](#post-content) Extract content of the selected post
1. [**Query result**](#query-result) Returned data

#### 1. Fetching posts<a name="fetch-posts"></a>

As mentioned in our previous tutorial we can fetch various lists of posts with different filters. Here, we are reusing some parts of that tutorial to list the top 5 trending posts.

```javascript
var query = {
    tag: '', // This tag is used to filter the results by a specific post tag.
    limit: 5, // This allows us to limit the total to 5 items.
    truncate_body: 1, // This will truncate the body of each post to 1 character, which is useful if you want to work with lighter array.
};
```

#### 2. Post content<a name="post-content"></a>

On selection of a particular post from the list, `openPost` function is fired. This function will call the `get_content` function to fetch content of the post. `get_content` requires author and permlink of the post to fetch its data.

```javascript
client.database.call('get_content', [author, permlink]).then(result => {
    const md = new Remarkable({ html: true, linkify: true });

    const body = md.render(result.body);

    const content = `<div class='pull-right'><button onclick=goback()>Close</button></div><br><h2>${
        result.title
    }</h2><br>${body}<br>`;

    document.getElementById('postList').style.display = 'none';
    document.getElementById('postBody').style.display = 'block';
    document.getElementById('postBody').innerHTML = content;
});
```

Hive allows any text-based format for the body, but apps often follow standard markdown with mix of few html tags. After we have fetched the content, we can use the `remarkable` library to parse the body of the post into a readable format. The title and body of the post are then displayed with a button at the top right corner to switch back to the post list.

```javascript
document.getElementById('postList').style.display = 'block';
document.getElementById('postBody').style.display = 'none';
```

The "go back" function simply hides and shows the post list.

#### 3. Query result<a name="query-result"></a>

The result is returned from the post content as a `JSON` object with the following properties:

```json
[
  {
    "abs_rshares": 0,
    "active": "2020-04-29T06:08:18",
    "active_votes": [],
    "allow_curation_rewards": true,
    "allow_replies": true,
    "allow_votes": true,
    "author": "hiveio",
    "author_reputation": "34879294456530",
    "author_rewards": 0,
    "beneficiaries": [],
    "body": "![#HuobiHive2020 ... an asset shining bright, provided by community member @nateaguila](https://files.peakd.com/file/peakd-hive/hiveio/XsnzlWHl-social_hive_flare.jpg)\n\n## Huobi has listed Hive! ...",
    "body_length": 0,
    "cashout_time": "1969-12-31T23:59:59",
    "category": "hiveblockchain",
    "children": 26,
    "children_abs_rshares": 0,
    "created": "2020-04-24T00:41:06",
    "curator_payout_value": "0.000 HBD",
    "depth": 0,
    "id": 85763874,
    "json_metadata": {
      "app": "peakd/2020.04.4",
      "format": "markdown",
      "description": "Hive is now listed on Huobi Global! This post contains all official links and AMA transcripts.",
      "tags": [
        "hiveblockchain",
        "exchangenews",
        "hiveama"
      ],
      "users": [
        "nateaguila",
        "roelandp"
      ],
      "links": [
        "/trending/huobihive2020",
        "/@nateaguila",
        "https://twitter.com/HuobiGlobal/status/1253210569194090497",
        "https://huobiglobal.zendesk.com/hc/en-us/articles/900000684263",
        "https://huobiglobal.zendesk.com/hc/en-us/articles/900000687166--EXCLUSIVE-Deposit-HIVE-on-Huobi-Global-to-Share-100-000-HIVE-",
        "https://twitter.com/HuobiGlobal/status/1252566140431130624",
        "/@roelandp",
        "/trending/notfinancialadvice",
        "https://developers.hive.io/",
        "https://hiveprojects.io/"
      ],
      "image": [
        "https://files.peakd.com/file/peakd-hive/hiveio/XsnzlWHl-social_hive_flare.jpg",
        "https://files.peakd.com/file/peakd-hive/hiveio/9tEYm2I9-image.png",
        "https://files.peakd.com/file/peakd-hive/hiveio/AXkoBSE3-image.png",
        "https://files.peakd.com/file/peakd-hive/hiveio/djdRACpx-image.png"
      ]
    },
    "last_payout": "2020-05-01T00:41:06",
    "last_update": "2020-04-24T00:41:06",
    "max_accepted_payout": "0.000 HBD",
    "max_cashout_time": "1969-12-31T23:59:59",
    "net_rshares": 0,
    "net_votes": 182,
    "parent_author": "",
    "parent_permlink": "hiveblockchain",
    "pending_payout_value": "0.000 HBD",
    "percent_steem_dollars": 10000,
    "permlink": "huobi-global-official-hive-listing-announcement-giveaways-ama-chat-transcripts",
    "promoted": "0.000 HBD",
    "reblogged_by": [],
    "replies": [],
    "reward_weight": 10000,
    "root_author": "hiveio",
    "root_permlink": "huobi-global-official-hive-listing-announcement-giveaways-ama-chat-transcripts",
    "root_title": "Huobi Global Official Hive Listing Announcement, Giveaways, and AMA Chat Transcripts",
    "title": "Huobi Global Official Hive Listing Announcement, Giveaways, and AMA Chat Transcripts",
    "total_payout_value": "0.000 HBD",
    "total_pending_payout_value": "0.000 HBD",
    "total_vote_weight": 0,
    "url": "/hiveblockchain/@hiveio/huobi-global-official-hive-listing-announcement-giveaways-ama-chat-transcripts",
    "vote_rshares": 0
  }
]
```

From this result, you have access to everything associated with the selected post, including additional metadata which is a `JSON` string that must be decoded to use.

* `id` - Unique identifier that is mostly an implementation detail (best to ignore). To uniquely identify content, it's best to use `author/permlink`.
* `author` - The author account name of the content.
* `permlink` - Permanent link of the content, must be unique in the scope of the `author`.
* `category` - The main category/tag this content belongs to.
* `parent_author` - Parent author, in case this content is a comment (reply).
* `parent_permlink` - Parent permanent link, this will be the same as `category` for posts and will contain the `permlink` of the content being replied to in the case of a comment.
* `title` - Title of the content.
* `body` - Body of the content.
* `json_metadata` - JSON metadata that holds extra information about the content. **Note:** The format for this field is not guaranteed to be valid JSON.
* `last_update` - The date and time of the last update to this content.
* `created` - The date and time this content was created.
* `active` - The last time this content was "touched" by voting or reply.
* `last_payout` - Time of last payout.
* `depth` - Used to track max nested depth.
* `children` - Used to track the total number of children, grandchildren, etc. ...
* `net_rshares` - Reward is proportional to liniar rshares, this is the sum of all votes (positive and negative reward sum)
* `abs_rshares` - This was used to track the total absolute weight of votes for the purpose of calculating `cashout_time`.
* `vote_rshares` - Total positive rshares from all votes. Used to calculate delta weights. Needed to handle vote changing and removal.
* `children_abs_rshares` - This was used to calculate cashout time of a discussion.
* `cashout_time` - 7 days from the `created` date.
* `max_cashout_time` - Unused.
* `total_vote_weight` - The total weight of voting rewards, used to calculate pro-rata share of curation payouts.
* `reward_weight` - Weight/percent of reward.
* `total_payout_value` - Tracks the total payout this content has received over time, measured in the debt asset.
* `curator_payout_value` - Tracks the curator payout this content has received over time, measured in the debt asset.
* `author_rewards` - Tracks the author payout this content has received over time, measured in the debt asset.
* `net_votes` - Net positive votes
* `root_comment` - ID of the original content.
* `max_accepted_payout` - Value of the maximum payout this content will receive.
* `percent_steem_dollars` - The percent of Hive Dollars to key, unkept amounts will be received as HIVE Power.
* `allow_replies` - Allows content to disable replies.
* `allow_votes` - Allows content to receive votes.
* `allow_curation_rewards` - Allows curators of this content receive rewards.
* `beneficiaries` - The list of up to 8 beneficiary accounts for this content as well as the percentage of the author reward they will receive in HIVE Power.
* `url` - The end of the url to this content.
* `root_title` - Title of the original content (useful in replies).
* `pending_payout_value` - Pending payout amount if 7 days has not yet elapsed.
* `total_pending_payout_value` - Total pending payout amount if 7 days has not yet elapsed.
* `active_votes` - The entire voting list array, including upvotes, downvotes, and unvotes; used to calculate `net_votes`.
* `replies` - Unused.
* `author_reputation` - Author's reputation.
* `promoted` - If post is promoted, how much has been spent on promotion.
* `body_length` - Total content length.
* `reblogged_by` - Unused.

That's it!

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/05_get_post_details`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
