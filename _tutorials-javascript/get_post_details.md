---
title: titles.get_post_details
position: 5
description: descriptions.get_post_details
layout: full
canonical_url: get_post_details.html
---
Full, runnable src of [Get Post Details](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/05_get_post_details) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-05_get_post_details.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/05_get_post_details)).

The purpose of this tutorial is to **a)** demonstrate how to get a list of articles from the trending list on the blockchain, and **b)** fetch the contents of the selected post to display its title and body.

We will also explain the most commonly used fields from the response object as well as parse body of the post.

## Intro

Accounts have unique `permlink` - permanent link for each of their posts. And Hive blockchain provides API to directly fetch current state of the post and its details. We will be using `get_content` to retrieve additional details. We can easily reformat data in a way that fits out application.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [bridge.get_post]({{ '/apidefinitions/#bridge.get_post' | relative_url }})
* [database_api.find_comments]({{ '/apidefinitions/#database_api.find_comments' | relative_url }})
* [condenser_api.get_content]({{ '/apidefinitions/#condenser_api.get_content' | relative_url }})

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

From this result, you have access to everything associated with the selected post, including additional metadata which is a `JSON` string that must be decoded to use.

{% include structures/comment.html %}

Final code:

```javascript
const dhive = require('@hiveio/dhive');
const Remarkable = require('remarkable');

let opts = {};

//connect to production server
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to server which is connected to the network/production
const client = new dhive.Client('https://api.hive.blog');

//fetch list of trending posts
async function main() {
    const query = {
        tag: '',
        limit: 5,
        truncate_body: 1,
    };
    client.database
        .getDiscussions('trending', query)
        .then(result => {
            var posts = [];
            result.forEach(post => {
                console.log(post);
                const json = JSON.parse(post.json_metadata);
                const image = json.image ? json.image[0] : '';
                const title = post.title;
                const author = post.author;
                const permlink = post.permlink;
                const created = new Date(post.created).toDateString();
                posts.push(
                    `<div class="list-group-item" onclick=openPost("${author}","${permlink}")><h4 class="list-group-item-heading">${title}</h4><p>by ${author}</p><center><img src="${image}" class="img-responsive center-block" style="max-width: 450px"/></center><p class="list-group-item-text text-right text-nowrap">${created}</p></div>`
                );
            });
            document.getElementById('postList').style.display = 'block';
            document.getElementById('postList').innerHTML = posts.join('');
        })
        .catch(err => {
            console.log(err);
            alert('Error occured, please reload the page');
        });
}
//catch error messages
main().catch(console.error);

//get_content of the post
window.openPost = async (author, permlink) => {
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
};
//go back from post view to list
window.goback = async () => {
    document.getElementById('postList').style.display = 'block';
    document.getElementById('postBody').style.display = 'none';
};

```

---

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/05_get_post_details`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
