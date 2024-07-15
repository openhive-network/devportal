---
title: titles.get_account_comments
position: 9
description: descriptions.get_account_comments
layout: full
canonical_url: get_account_comments.html
---
Full, runnable src of [Get Account Comments](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/09_get_account_comments) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-09_get_account_comments.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/09_get_account_comments)).

This tutorial will show how to fetch comments made by a specific account (in this case `@hiveio`) by demonstrating how to use the `bridge.get_account_posts` api function call. We will also demonstrate the most commonly used fields from the response object as well as how to parse the body of each comment.

## Intro

We are using the `bridge.get_account_posts` function with `dhive` that returns the current state of the network as well as additional content. Each content body is written in markdown and could be submitted to the blockchain by many different applications built on top of Hive. For that reason we are using the `remarkable` npm package to parse markdown in a readable format.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [bridge.get_account_posts]({{ '/apidefinitions/#bridge.get_account_posts' | relative_url }})

## Steps

1. [**App setup**](#app-setup) Configuration of `dhive` to use the proper connection and network.
1. [**Query**](#query) Query the path which we want to extract from Hive blockchain state.
1. [**Formatting**](#formatting) Formatting the JSON object to be viewed in a simple user interface.

#### 1. App setup<a name="app-setup"></a>

Below we have `dhive` pointing to the main network with the proper chainId, addressPrefix and connection server.
There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define and configure library and packages.

```javascript
const dhive = require('@hiveio/dhive');
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
// fetching comments made by author
const author = prompt('Account?', 'hiveio');

client.hivemind.call('get_account_posts', {sort: 'comments', account: author, limit: 100})
    // work with state object
});
```

`query` is the path from where want to extract Hive blockchain state. In our example we are querying `comments` from the `@hiveio` account. The result will be the current state object with various information as well as the `content` property holding the content of the query.

The following is an example of the returned object:

```json
[
   {
      "post_id":103793175,
      "author":"blocktrades",
      "permlink":"qtbpx4",
      "category":"hive-139531",
      "title":"RE: 12th update of 2021 on BlockTrades work on Hive software",
      "body":"Yes, I think the above is quite probable.",
      "json_metadata":{"app":"hiveblog\/0.1"},
      "created":"2021-05-18T22:17:30",
      "updated":"2021-05-18T22:17:30",
      "depth":4,
      "children":0,
      "net_rshares":45572072190,
      "is_paidout":false,
      "payout_at":"2021-05-25T22:17:30",
      "payout":0.021,
      "pending_payout_value":"0.021 HBD",
      "author_payout_value":"0.000 HBD",
      "curator_payout_value":"0.000 HBD",
      "promoted":"0.000 HBD",
      "replies":[],
      "author_reputation":77.33,
      "stats":{
         "hide":false,
         "gray":false,
         "total_votes":1,
         "flag_weight":0.0
      },
      "url":"\/hive-139531\/@blocktrades\/12th-update-of-2021-on-blocktrades-work-on-hive-software#@blocktrades\/qtbpx4",
      "beneficiaries":[],
      "max_accepted_payout":"1000000.000 HBD",
      "percent_hbd":10000,
      "parent_author":"urun",
      "parent_permlink":"re-blocktrades-qtblai",
      "active_votes":[
         {
            "rshares":45572072190,
            "voter":"urun"
         }
      ],
      "blacklists":[],
      "community":"hive-139531",
      "community_title":"HiveDevs",
      "author_role":"mod",
      "author_title":""
   }
]
```

#### 3. Formatting<a name="formatting"></a>

Next we will format the above object properly to view in a simple user interface. From the above object, we are only interested in the `content` object which holds the data we require.

```javascript
if (
    !(
        Object.keys(result).length === 0 &&
        result.constructor === Object
    )
) {
    var comments = [];
    Object.keys(result.content).forEach(key => {
        const comment = result[key];
        const parent_author = comment.parent_author;
        const parent_permlink = comment.parent_permlink;
        const created = new Date(comment.created).toDateString();
        const body = md.render(comment.body);
        const totalVotes = comment.stats.total_votes;
        comments.push(
            `<div class="list-group-item list-group-item-action flex-column align-items-start">\
            <div class="d-flex w-100 justify-content-between">\
              <h6 class="mb-1">@${comment.author}</h6>\
              <small class="text-muted">${created}</small>\
            </div>\
            <p class="mb-1">${body}</p>\
            <small class="text-muted">&#9650; ${totalVotes}, Replied to: @${parent_author}/${parent_permlink}</small>\
          </div>`
        );
    });
    document.getElementById('author').innerHTML = author;
    document.getElementById('comments').style.display = 'block';
    document.getElementById('comments').innerHTML = comments.join('');
}
```

We first check if `result` is not an empty object. We then iterate through each object in `result` and extract:

* `parent_author`
* `parent_permlink`
* and the post or comment the author is replying to

We format `created` date and time, parse `body` markdown and get `totalVotes` on that comment.
Each line is then pushed and displayed separately.

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

const Remarkable = require('remarkable');
const md = new Remarkable({ html: true, linkify: true });

//fetch list of comments for certain account
async function main() {
    const author = prompt('Account?', 'hiveio');
    
    client.hivemind
        .call('get_account_posts', {sort: 'comments', account: author, limit: 100})
        .then(result => {
            console.log(result);
            if (
                !(
                    Object.keys(result).length === 0 &&
                    result.constructor === Object
                )
            ) {
                var comments = [];
                Object.keys(result).forEach(key => {
                    const comment = result[key];
                    const parent_author = comment.parent_author;
                    const parent_permlink = comment.parent_permlink;
                    const created = new Date(comment.created).toDateString();
                    const body = md.render(comment.body);
                    const totalVotes = comment.stats.total_votes;
                    comments.push(
                        `<div class="list-group-item list-group-item-action flex-column align-items-start">\
                        <div class="d-flex w-100 justify-content-between">\
                          <h6 class="mb-1">@${comment.author}</h6>\
                          <small class="text-muted">${created}</small>\
                        </div>\
                        <p class="mb-1">${body}</p>\
                        <small class="text-muted">&#9650; ${totalVotes}, Replied to: @${parent_author}/${parent_permlink}</small>\
                      </div>`
                    );
                });
                document.getElementById('author').innerHTML = author;
                document.getElementById('comments').style.display = 'block';
                document.getElementById('comments').innerHTML = comments.join(
                    ''
                );
            }
        })
        .catch(err => {
            console.log(err);
            alert('Error occured, please reload the page');
        });
}
//catch error messages
main().catch(console.error);

```
---

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/09_get_account_comments`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
