---
title: 'JS: Get Voters List On Post'
position: 6
description: "_By the end of this tutorial you would know how to get voters list on any content._"
layout: full
canonical_url: get_voters_list_on_post.html
---
Full, runnable src of [Get Voters List On Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/06_get_voters_list_on_post) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-06_get_voters_list_on_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/06_get_voters_list_on_post)).

The purpose of this tutorial is to **a)** demonstrate how to get a list of articles from the trending list on the blockchain, and **b)** fetch the voters of the selected post to display the account and date at which they voted.

We will also explain the most commonly used fields from the response object.

## Intro

Each post has voters that support content and play big role in reward distribution. Getting details of each voter and their vote value, time, etc. is another crucial information for authors and app developers. We will be using `get_active_votes` API call to retrieve that information right from Hive blockchain.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_active_votes]({{ '/apidefinitions/#tags_api.get_active_votes' | relative_url }})
* [condenser_api.get_active_votes]({{ '/apidefinitions/#condenser_api.get_active_votes' | relative_url }})

## Steps

1. [**Fetching posts**](#fetching-posts) Get trending post list
1. [**Voter information**](#voter-info) Voters information on selected post
1. [**Query result**](#query-result) Example of result from query

#### 1. Fetching posts<a name="fetching-posts"></a>

As mentioned in our previous tutorial we can fetch various lists of posts with different filters. Here, we are reusing some parts of that tutorial to list the top 5 trending posts.

```javascript
var query = {
    tag: '', // This tag is used to filter the results by a specific post tag.
    limit: 5, // This allows us to limit the total to 5 items.
    truncate_body: 1, // This will truncate the body of each post to 1 character, which is useful if you want to work with lighter array.
};
```

#### 2. Voter information<a name="voter-info"></a>

On selection of a particular post from the list, `openPost` function is fired. This function will call the `get_active_votes` function to fetch the voters of the post. `get_active_votes` requires author and permlink of the post to fetch its data.

```javascript
client.database.call('get_active_votes', [author, permlink]).then(result => {
    console.log('votes', result, JSON.stringify(result));

    var voters = [];
    voters.push(
        `<div class='pull-right'><button onclick=goback()>Close</button></div><br>`
    );
    result.forEach(voter => {
        const name = voter.voter;
        const time = new Date(voter.time).toDateString();
        voters.push(`${name} (${time})`);
    });

    document.getElementById('postList').style.display = 'none';
    document.getElementById('postBody').style.display = 'block';
    document.getElementById('postBody').innerHTML = voters.join('<li>');
});
```

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
        "voter": "gekko",
        "weight": 157,
        "rshares": 2626899959,
        "percent": 10000,
        "reputation": "1185517433922",
        "time": "2018-05-08T07:16:09"
    },
    {
        "voter": "embat",
        "weight": 154,
        "rshares": 2578364521,
        "percent": 10000,
        "reputation": "161340267374",
        "time": "2018-05-08T07:38:24"
    }
]
```

From this result, you have access to everything associated with the selected post, including additional metadata which is a `JSON` string that must be decoded to use.

* `voter` - The author account name of the vote.
* `weight` - Weight of the voting power.
* `rshares` - Reward shares.
* `percent` - Percent of vote.
* `reputation` - The [reputation]({{ '/glossary/#reputation' | relative_url }}) of the account that voted.
* `time` - Time the vote was submitted.

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
                console.log('post', post);
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
    client.database
        .call('get_active_votes', [author, permlink])
        .then(result => {
            console.log('votes', result, JSON.stringify(result));

            var voters = [];
            voters.push(
                `<div class='pull-right'><button onclick=goback()>Close</button></div><br>`
            );
            result.forEach(voter => {
                const name = voter.voter;
                const time = new Date(voter.time).toDateString();
                voters.push(`${name} (${time})`);
            });

            document.getElementById('postList').style.display = 'none';
            document.getElementById('postBody').style.display = 'block';
            document.getElementById('postBody').innerHTML = voters.join('<li>');
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
1. `cd devportal/tutorials/javascript/06_get_voters_list_on_post`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
