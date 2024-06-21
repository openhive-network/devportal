---
title: 'JS: Get Posts'
position: 4
description: Query for the most recent posts having a specific tag, using a Hive filter
layout: full
canonical_url: get_posts.html
---
Full, runnable src of [Get Posts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/04_get_posts) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-04_get_posts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/04_get_posts)).

This tutorial pulls a list of the posts from different tags or filters and displays them.
Tags and filters are different. It's important to understand them.

## Intro

Tags & Filters are two different.

A `tag` in Hive is much like a tag in Gmail, or Twitter. It's a way to describe a
post as being relevant to a particular topic. Posts may have up to five tags on them, but there are limits when
querying (more on this later).

A `filter` in Hive is a kind of built-in 'view' or ordering of posts. You can use the following filters:
`trending`, `hot`, `new`, `active`, and `promoted`. You'll get a feel for the subtleties of each as you create your
application.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [get ranked posts]({{ '/search/?q=get ranked posts' | relative_url }})

## Steps

1. [**UI**](#UI) - A brief description of the UI and inputting our query values
1. [**Construct query**](#Construct-query) - Assemble the information from the UI into our `filter` & `query`
1. [**API call**](#API-call) - Make the call to Hive
1. [**Handle response**](#Handle-response) - Accept the response in a promise callback, then render the results
1. [**Example post object**](#Example-post-object) - An example post object from the response list

#### 1. UI <a name="UI"></a>

The source HTML for our UI can be found in [public/index.html](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/04_get_posts/public/index.html)

There are three input components to the UI.

* Filters: where we select one of the five built in filter types.

    ```html
    <select id="filters" class="form-control" >...
    ```

* Tag: where we type in a _single_, arbitrary tag. (The Hive blockchain does not support searching on multiple tags)

    ```html
    <input id="tag" class="form-control"/>
    ```

* Get Posts: It's a button. You click it, and we move on to assembling our post.
    
    ```html
    <button class="btn btn-primary" onclick="getPosts()">Get Posts</button>
    ```

<center>
  <img src="https://gitlab.syncad.com/hive/devportal/-/raw/master/tutorials/javascript/04_get_posts/images/Step-01-UI.png" />
</center>

#### 2. Construct query <a name="Construct-query"></a>

The filter and query are constructed within the async, globally available function `getPosts`

The `limit` property you see below limits the total number of posts we'll get back to something
managable. In this case, five.

```javascript
const filter = document.getElementById('filters').value;
const query = {
    tag: document.getElementById('tag').value,
    limit: 5,
};
```

#### 3. API call <a name="API-call"></a>

The api call itself is fairly simple. We use `getDiscussions`.
The first argument, filter, is a simple string.
The second argument is our query object.
Like most of dhive's api functions, `getDiscussions` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise).

```javascript
client.database
    .getDiscussions(filter, query)
    .th..
```

#### 4. Handle response <a name="Handle-response"></a>

When the promise returned by `getDiscussions` completes successfully, the function we pass to `.then()`
iterates over the entries response, and constructs html from it.

```javascript
...ery)
.then(result => {
            console.log("Response received:", result);
            if (result) {
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
            } else {
                document.getElementById('postList').innerHTML = "No result.";
            }
        })
```

#### 5. Example post object <a name="Example-post-object"></a>

The result returned from the service is a `JSON` list. This is an example list with one entry.

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

**And that's all there is to getting top-level posts.** _See [Get post comments](get_post_comments.html) for getting comments_

Final code:

```javascript
const dhive = require('@hiveio/dhive');

let opts = {};

//connect to production server
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';

//connect to server which is connected to the network/production
const client = new dhive.Client('https://api.hive.blog');

//filter change selection function
window.getPosts = async () => {
    const filter = document.getElementById('filters').value;
    const query = {
        tag: document.getElementById('tag').value,
        limit: 5,
    };

    console.log('Post assembled.\nFilter:', filter, '\nQuery:', query);

  client.call('bridge', 'get_ranked_posts', [
    username,
    startFollow,
    'blog',
    limit,
  ])
    
    client.database
        .getDiscussions(filter, query)
        .then(result => {
            console.log('Response received:', result);
            if (result) {
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
            } else {
                document.getElementById('postList').innerHTML = 'No result.';
            }
        })
        .catch(err => {
            console.log(err);
            alert(`Error:${err}, try again`);
        });
};

```


---

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/04_get_posts`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
