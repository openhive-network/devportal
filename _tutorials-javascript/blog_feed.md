---
title: 'JS: Blog Feed'
position: 1
description: How to fetch most recent five posts from particular user on Hive.
layout: full
canonical_url: blog_feed.html
---
Full, runnable src of [Blog Feed](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/01_blog_feed) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-01_blog_feed.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/01_blog_feed)).

This tutorial pulls a list of the most recent five user's posts from the blockchain and displays them in simple list. Also some notes about usage of `client.database.getDiscussions` API.

## Intro

Tutorial is demonstrates the typical process of fetching account blog posts. It is quite useful if you want to embedd your blog posts on your website these tutorial will help you achieve that goal as well. This tutorial will explain and show you how to access the **Hive** blockchain using the [@hiveio/dhive](https://gitlab.syncad.com/hive/dhive) library to build a basic blog list of posts filtered by a _tag_

Also see:
* [get_discussions_by_blog]({{ '/apidefinitions/#tags_api.get_discussions_by_blog' | relative_url }})

## Steps

1. [**Configure connection**](#Configure-connection) Configuration of dhive to use proper connection and network
1. [**Query format**](#Query-format) Simple query format to help use fetch data
1. [**Fetch data and format**](#Fetch-data-and-format) Fetch data and display in proper interface

---

#### 1. Configure connection<a name="Configure-connection"></a>

In order to connect to the live Hive network, all we have to do is provide connection url to a server that runs on the network. `dhive` by default set up to use live network but it has flexibility to adjust connection to any other testnet or custom networks, more on that in future tutorials.

In first couple lines we require package and define connection server:

```javascript
const { Client } = require("@hiveio/dhive");

const client = new Client('https://api.hive.blog');
```

#### 2. Query format<a name="Query-format"></a>

* You can add a tag to filter the blog posts that you receive from the server, since we are aiming to fetch blog posts of particular user, we will define username as tag.
* You can also limit the number of results you would like to receive from the query

```javascript
var query = {
    tag: 'hiveio', // This tag is used to filter the results by a specific post tag
    limit: 5, // This limit allows us to limit the overall results returned to 5
};
```

#### 3. Fetch data and format<a name="Fetch-data-and-format"></a>

`client.database.getDiscussions` function is used for fetching discussions or posts. The first argument to this function determines which equivalent of the appbase `condenser_api.get_discussions_by_*` api calls it's going to use.  Below is example of query and keyword **'blog'** indicates `condenser_api.get_discussions_by_blog` and somewhat counter-intuitively _query.tag_ indicates the account from which we want to get posts.

```javascript
client.database
    .getDiscussions('blog', query)
    .then(result => {
        var posts = [];
        result.forEach(post => {
            const json = JSON.parse(post.json_metadata);
            const image = json.image ? json.image[0] : '';
            const title = post.title;
            const author = post.author;
            const created = new Date(post.created).toDateString();
            posts.push(
                `<div class="list-group-item"><h4 class="list-group-item-heading">${title}</h4><p>by ${author}</p><center><img src="${image}" class="img-responsive center-block" style="max-width: 450px"/></center><p class="list-group-item-text text-right text-nowrap">${created}</p></div>`
            );
        });

        document.getElementById('postList').innerHTML = posts.join('');
    })
    .catch(err => {
        alert('Error occured' + err);
    });
```

The result returned form the service is a `JSON` object with the following properties:

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
    "percent_hbd": 10000,
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

From this result we have access to everything associated to the post including additional metadata which is a `JSON` string that must be decoded to use. This `JSON` object has additional information and properties for the post including a reference to the image uploaded. And we are displaying this data in meaningful user interface. _Note: it is truncated to one element, but you would get five posts in array_

---

#### Try it

Click the play button below:

<iframe height="400px" width="100%" src="https://replit.com/@inertia186/js01blogfeed?embed=1&output=1" scrolling="no" frameborder="no" allowtransparency="true" allowfullscreen="true" sandbox="allow-forms allow-pointer-lock allow-popups allow-same-origin allow-scripts allow-modals"></iframe>

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/01_blog_feed`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
