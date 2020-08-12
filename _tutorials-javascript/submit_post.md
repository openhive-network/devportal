---
title: 'JS: Submit Post'
position: 10
description: "_By the end of this tutorial you should know how to prepare comments for Hive and then submit using the broadcast.comment function._"
layout: full
canonical_url: submit_post.html
---              
<span class="fa-pull-left top-of-tutorial-repo-link"><span class="first-word">Full</span>, runnable src of [Submit Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/tutorials/10_submit_post) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript).</span>
<br>



This tutorial will show the method of properly formatting content followed by broadcasting the information to the hive blockchain.

## Intro

We are using the `client.broadcast.comment` function provided by `dhive` which generates, signs, and broadcasts the transaction to the network. On the Hive platform, posts and comments are all internally stored as a `comment` object, differentiated by whether or not a `parent_author` exists. When there is no `parent_author`, then it's a post, otherwise it's a comment.

## Steps

1.  [**App setup**](#app-setup) Configuration of `dhive` to use the proper connection and network.
1.  [**Fetch Hive Post or Comment data**](#fetch-content) Defining information variables with the `submitpost` function.
1.  [**Format and Broadcast**](#format-broadcast) Formatting the comments and submitting to the blockchain.

#### 1. App setup<a name="app-setup"></a>


There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define the configured library and packages:

```javascript
const dhive = require('@hiveio/dhive');
let opts = {};
const client = new dhive('https://api.hive.blog');
```

#### 2. Fetch Hive Post or Comment data<a name="fetch-content"></a>

Next, we have the `submitPost` function which executes when the Submit post button is clicked.

```javascript
//get private key
const privateKey = dhive.PrivateKey.fromString(
    document.getElementById('postingKey').value
);
//get account name
const account = document.getElementById('username').value;
//get title
const title = document.getElementById('title').value;
//get body
const body = document.getElementById('body').value;
//get tags and convert to array list
const tags = document.getElementById('tags').value;
const taglist = tags.split(' ');
//make simple json metadata including only tags
const json_metadata = JSON.stringify({ tags: taglist });
//generate random permanent link for post
const permlink = Math.random()
    .toString(36)
    .substring(2);
```

The `getElementById` function is used to obtain data from the HTML elements and assign them to constants. Tags are separated by spaces in this example and stored in an array list called `taglist` for later use. However, the structure of how to enter tags depends on your needs. Posts on the blockchain can hold additional information in the `json_metadata` field, such as the `tags` list which we have assigned. Posts must also have a unique permanent link scoped to each account. In this case we are just creating a random character string.

#### 3. Format and Broadcast<a name="format-broadcast"></a>

The next step is to pass all of these elements in **2.** to the `client.broadcast.comment` function.

```javascript
//broadcast post
client.broadcast
    .comment(
        {
            author: account,
            body: body,
            json_metadata: json_metadata,
            parent_author: '',
            parent_permlink: taglist[0],
            permlink: permlink,
            title: title,
        },
        privateKey
    )
    .then(
        function(result) {
            document.getElementById('title').value = '';
            document.getElementById('body').value = '';
            document.getElementById('tags').value = '';
            document.getElementById('postLink').style.display = 'block';
            document.getElementById(
                'postLink'
            ).innerHTML = `<br/><p>Included in block: ${
                result.block_num
            }</p><br/><br/><a href="http://hive.blog/${
                taglist[0]
            }/@${account}/${permlink}">Check post here</a>`;
        },
        function(error) {
            console.error(error);
        }
    );
```

Note that the `parent_author` and `parent_permlink` fields are used for replies (also known as comments). In this example, since we are publishing a post instead of a comment/reply, we will have to leave `parent_author` as an empty string and assign the first tag to `parent_permlink`.

After the post has been broadcast to the network, we can simply set all the fields to empty strings and show the post link to check it from a condenser instance.

The `broadcast` operation has more to offer than just committing a post/comment to the blockchain. It provides a mulititude of options that can accompany this commit. The max payout and percent of steem dollars can be set. When authors don't want all of the benifits from a post, they can set the payout factors to zero or beneficiaries can be set to receive part of the rewards. You can also set whether votes are allowed or not. The broadcast to the blockchain can be modified to meet the exact requirements of the author. More information on how to use the `broadcast` operation can be found on the Hive [Devportal](https://developers.hive.io/apidefinitions/#apidefinitions-broadcast-ops-comment) with a list of the available broadcast options under the specific [Appbase API](https://developers.hive.io/apidefinitions/#broadcast_ops_comment_options)

### To Run the tutorial

1.  `git clone https://gitlab.syncad.com/hive/devportal.git`
1.  `cd devportal/tutorials/javascript/10_submit_post`
1.  `npm i`
1.  `npm run dev-server` or `npm run start`
1.  After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)


---
