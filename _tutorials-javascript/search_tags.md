---
title: 'JS: Search Tags'
position: 16
description: "_By the end of this tutorial you should know how to run a search for trending tags_"
layout: full
canonical_url: search_tags.html
---              
<span class="fa-pull-left top-of-tutorial-repo-link"><span class="first-word">Full</span>, runnable src of [Search Tags](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/tutorials/16_search_tags) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript).</span>
<br>



This tutorial runs on the main Hive blockchain.

## Intro

This tutorial will show the method of capturing a queried tag name and matching it to the steem database. We are using the `call` function provided by the `dsteem` library to pull tags from the steem blockchain. A simple HTML interface is used to both capture the string query as well as display the completed search.

## steps

1.  [**Configure connection**](#configure-conn) Configuration of `dsteem` to use the proper connection and network.
2.  [**Search input**](#search-input) Collecting the relevant search criteria
3.  [**Run Search**](#run-search) Running the search on the blockchain
4.  [**Output**](#output) Displaying the results of the search query

#### 1. Configure connection <a name="configure-conn"></a>

Below we have `dsteem` pointing to the production network with the proper chainId, addressPrefix, and endpoint. There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define the configured library and packages:

```javascript
const dsteem = require('dsteem');
let opts = {};
//connect to production server
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to server which is connected to the network/production
const client = new dsteem.Client('https://api.hive.blog');
```

#### 2. Search input <a name="search-input"></a>

Collecting of the search criteria happens via an HTML input. The form can be found in the `index.html` file. The values are pulled from that screen with the below:

```javascript
const max = 10;
window.submitTag = async () => {
    const tagSearch = document.getElementById("tagName").value;
```

#### 3. Run Search <a name="run-search"></a>

In order to access the blockchain to run the search a `call` function is used with the `search field` and `maximum` list items as parameters.

```javascript
const _tags = await client.database.call('get_trending_tags',[tagSearch, max]);
```

The result of the search is an array of tags along with their respective vital data like `comments`, `payouts`, etc.

#### 4. Output <a name="output"></a>

Due to the output from the `call` function being an array, we can't use a simple `post` function to display the tags. The specific fields within the array needs to be selected and then displayed.

```javascript
console.log('tags: ', _tags);
var posts = [];
_tags.forEach(post => {
    posts.push(
        `<div class="list-group-item"><h5 class="list-group-item-heading">${
            post.name
        }</h5></div>`
    );
});
//disply list of tags with line breaks
document.getElementById('tagList').innerHTML = posts.join('<br>');
```

### To run this tutorial

1.  `git clone https://gitlab.syncad.com/hive/devportal.git`
1.  `cd devportal/tutorials/javascript/16_search_tags`
1.  `npm i`
1.  `npm run dev-server` or `npm run start`
1.  After a few moments, the server should be running at http://localhost:3000/


---
