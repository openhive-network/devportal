---
title: 'JS: Reblogging Post'
position: 14
description: "_How to reblog a post from hive_"
layout: full
canonical_url: reblogging_post.html
---
Full, runnable src of [Reblogging Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/14_reblogging_post) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-14_reblogging_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/14_reblogging_post)).

This tutorial will show the method of obtaining the relevant inputs for the reblog process followed by broadcasting the info to the hive blockchain using a `demo` account on the `production server`.

## Intro

We are using the `client.broadcast` function provided by `dhive` to reblog the selected blogpost. There are 4 variables that are required to perform this action:

*   The account name that is doing the reblog
*   The private _posting_ key of the account that is doing the reblog (this is not your main key)
*   The author of the post that is being reblogged
*   The title of the post that is being reblogged

A simple HTML interface is used to capture the required information after which the transaction is submitted. There are two prerequisites within the reblog process in Hive that have to be adhered to, namely, the post must not be older than 7 days, and the post can only be reblogged once by a specific account. The fields have been populated with information to give an example of what it would look like but care has to be taken to provide correct details before the function is executed.

This tutorial makes use of the This function is taken from the tutorial [Blog Feed](blog_feed.html) to get a list of trending posts.

## Steps

1.  [**Configure connection**](#configure_connection) Configuration of `dhive` to use the proper connection and network.
2.  [**Collecting information**](#collecting_information) Generating relevant posting information with an HTML interface.
3.  [**Broadcasting the reblog**](#broadcasting_the_reblog) Assigning variables and executing the reblog.

#### 1. Configure connection\*\*<a name="configure_connection"></a>

Below we have `dhive` pointing to the production network with the proper chainId, addressPrefix, and endpoint. Although this tutorial is interactive, we will not post to the testnet due to the prerequisites of reblogging.
There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define the configured library and packages:

```javascript
const dhive = require('@hiveio/dhive');

//define network parameters
let opts = {};
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to a Hive node. This is currently setup on production, but we recommend using a testnet like https://testnet.hive.blog
const client = new dhive.Client('https://api.hive.blog', opts);
```

#### 2. Collecting information<a name="collecting_information"></a>

Next we have the `submitPost` function that collects the required fields for the reblog process via an HTML interface
after wich we assign them to variables for use later.

```javascript
//this function will execute when the HTML form is submitted
window.submitPost = async () => {
    //get private key
    const privateKey = dhive.PrivateKey.fromString(
        document.getElementById('postingKey').value
    );
    //get account name
    const myAccount = document.getElementById('username').value;
    //get blog author
    const theAuthor = document.getElementById('theAuthor').value;
    //get blog permLink
    const thePermLink = document.getElementById('thePermLink').value;
```

#### 3. Broadcasting the reblog<a name="broadcasting_the_reblog"></a>

Finally we create two variables to simply the `client.broadcast` function line and broadcast the reblog instruction.

```javascript
const jsonOp = JSON.stringify([
    'reblog',
    {
        account: myAccount,
        author: theAuthor,
        permlink: thePermLink,
    },
]);

const data = {
    id: 'follow',
    json: jsonOp,
    required_auths: [],
    required_posting_auths: [myAccount],
};

client.broadcast.json(data, privateKey).then(
    function(result) {
        console.log('client broadcast result: ', result);
    },
    function(error) {
        console.error(error);
    }
);
```

There are also two `console` functions an a ui output under **Reblog Results** defined in order to track if the reblog
as successful or not. If the broadcast succeeds the `console.log` will show the following:

client broadcast result:

```
{
    id: "f10d69ac521cf34b0f5d18d938e68c89e77bb31d",
    block_num: 22886453,
    trx_num: 35,
    expired: false
}
```

This indicates the block number at which the broadcast was sent as well as the transaction ID for the reblog.

If the reblog fails the `console.log` will present a long line of error code:

```
{
    name: "RPCError",
    jse_shortmsg: "blog_itr == blog_comment_idx.end(): Account has already reblogged this post",
    jse_info: {
        ode: 10,
        name: "assert_exception",
        message: "Assert Exception",
        stack: Array(6)
    },
    message: "blog_itr == blog_comment_idx.end(): Account has already reblogged this post",
    stack: "RPCError: blog_itr == blog_comment_idx.end(): Acco…lled (http://localhost:3000/bundle.js:440:690874)"
}
```

There is a line in the error log indicating "Account has already reblogged this post" indicating exactly that. This process can be run until a positive result is found.

It should be noted that reblogging a post does not create a new post on the blockchain but merely shares the post to whomever is following the user doing the reblog. Along with `reblogging` the `custom_json` broadcast operation also includes options for following users and editing blog content. More information on how to use the `broadcast` operation and options surrounding the operation can be found on the Hive [Devportal]({{ '/apidefinitions/#apidefinitions-broadcast-ops-comment' | relative_url }})

## To run this tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
2. `cd devportal/tutorials/javascript/14_reblogging_post`
3. `npm i`
4. `npm run dev-server` or `npm run start`
5. After a few moments, the server should be running at http://localhost:3000/
