---
title: titles.submit_post
position: 10
description: descriptions.submit_post
layout: full
canonical_url: submit_post.html
---
Full, runnable src of [Submit Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/10_submit_post) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-10_submit_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/10_submit_post)).


This tutorial will show the method of properly formatting content followed by broadcasting the information to the hive blockchain using a `demo` account on the `testnet`.

## Intro

We are using the `client.broadcast.comment` function provided by `dhive` which generates, signs, and broadcasts the transaction to the network. On the Hive platform, posts and comments are all internally stored as a `comment` object, differentiated by whether or not a `parent_author` exists. When there is no `parent_author`, then it's a post, otherwise it's a comment.

Also see:
* [comment_operation]({{ '/apidefinitions/#broadcast_ops_comment' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) Configuration of `dhive` to use the proper connection and network.
1.  [**Fetch Hive Post or Comment data**](#fetch-content) Defining information variables with the `submitpost` function.
1.  [**Format and Broadcast**](#format-broadcast) Formatting the comments and submitting to the blockchain.

#### 1. App setup<a name="app-setup"></a>

{% include local-testnet.html %}

Below we have `dhive` pointing to the test network with the proper chainId, addressPrefix, and endpoint. Because this tutorial is interactive, we will not publish test content to the main network. Instead, we're using the testnet and a predefined account to demonstrate post publishing.

There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define the configured library and packages:

```javascript
const dhive = require('@hiveio/dhive');
let opts = {};
//connect to community testnet
opts.addressPrefix = 'TST';
opts.chainId =
    '18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e';
//connect to server which is connected to the network/testnet
const client = new dhive.Client('http://127.0.0.1:8090', opts);
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
//broadcast post to the testnet
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
            }</p><br/><br/><a href="http://127.0.0.1:8080/${
                taglist[0]
            }/@${account}/${permlink}">Check post here</a>`;
        },
        function(error) {
            console.error(error);
        }
    );
```

Note that the `parent_author` and `parent_permlink` fields are used for replies (also known as comments). In this example, since we are publishing a post instead of a comment/reply, we will have to leave `parent_author` as an empty string and assign the first tag to `parent_permlink`.

After the post has been broadcast to the network, we can simply set all the fields to empty strings and show the post link to check it from a condenser instance running on the selected testnet.

The `broadcast` operation has more to offer than just committing a post/comment to the blockchain. It provides a mulititude of options that can accompany this commit. The max payout and percent of hive dollars can be set. When authors don't want all of the benifits from a post, they can set the payout factors to zero or beneficiaries can be set to receive part of the rewards. You can also set whether votes are allowed or not. The broadcast to the blockchain can be modified to meet the exact requirements of the author. More information on how to use the `broadcast` operation can be found on the Hive [Devportal]({{ '/apidefinitions/#broadcast_ops_comment' | relative_url }}) with a list of the available broadcast options under the specific [Appbase API]({{ '/apidefinitions/#broadcast_ops_comment_options' | relative_url }})

Final code:

```javascript
import { Client, PrivateKey } from '@hiveio/dhive';
import { Testnet as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

let opts = { ...NetConfig.net };

//connect to server which is connected to the network/testnet
const client = new Client(NetConfig.url, opts);

//submit post function
window.submitPost = async () => {
    //get private key
    const privateKey = PrivateKey.fromString(
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

    const payload = {
        author: account,
        body: body,
        json_metadata: json_metadata,
        parent_author: '',
        parent_permlink: taglist[0],
        permlink: permlink,
        title: title,
    };
    console.log('client.broadcast.comment:', payload);
    client.broadcast.comment(payload, privateKey).then(
        function(result) {
            console.log('response:', result);
            document.getElementById('title').value = '';
            document.getElementById('body').value = '';
            document.getElementById('tags').value = '';
            document.getElementById('postLink').style.display = 'block';
            document.getElementById(
                'postLink'
            ).innerHTML = `<br/><p>Included in block: ${
                result.block_num
            }</p><br/><br/><a href="http://127.0.0.1:8080/${
                taglist[0]
            }/@${account}/${permlink}">Check post here</a>`;
        },
        function(error) {
            console.error(error);
        }
    );
};

window.onload = () => {
    const account = NetConfig.accounts[0];
    document.getElementById('username').value = account.address;
    document.getElementById('postingKey').value = account.privPosting;
};

```

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/10_submit_post`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
