---
title: 'JS: Get Follower And Following List'
position: 19
description: "_Get the followers of a user/author & the authors that user is following._"
layout: full
canonical_url: get_follower_and_following_list.html
---
Full, runnable src of [Get Follower And Following List](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/19_get_follower_and_following_list) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-19_get_follower_and_following_list.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/19_get_follower_and_following_list)).

This tutorial will take you through the process of calling both the `follower` and `following` functions from the HIVE API.

## Intro

We are using the `call` operation provided by the `dhive` library to pull the follow information for a specified user account. There are 4 variables required to execute this operation:

1.  _username_ - The specific user for which the follower(ing) list will be retrieved.
2.  _startFollower(ing)_ - The starting letter(s) or name for the search query.
3.  _followType_ - This value is set to `blog` and includes all users following or being followed by the `user`.
4.  _limit_ - The maximum number of lines to be returned by the query.

A simple HTML interface is used to capture the required information after which the function is executed.

Also see:
* [condenser_api.get_following]({{ '/apidefinitions/#condenser_api.get_following' | relative_url }})
* [condenser_api.get_followers]({{ '/apidefinitions/#condenser_api.get_followers' | relative_url }})
* [condenser_api.get_follow_count]({{ '/apidefinitions/#condenser_api.get_follow_count' | relative_url }})

## Steps

1.  [**Configure connection**](#connection) Configuration of `dhive` to communicate with the Hive blockchain
2.  [**Input variables**](#input) Collecting the required inputs via an HTML UI
3.  [**Get followers/following**](#query) Get the followers or users being followed
4.  [**Display**](#display) Display the array of results on the UI

#### 1. Configure connection<a name="connection"></a>

As usual, we have a `public/app.js` file which holds the Javascript segment of the tutorial. In the first few lines we define the configured library and packages:

```javascript
const dhive = require('@hiveio/dhive');
let opts = {};
//define network parameters
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to a hive node, production in this case
const client = new dhive.Client('https://api.hive.blog');
```

Above, we have `dhive` pointing to the production network with the proper chainId, addressPrefix, and endpoint.

#### 2. Input variables<a name="input"></a>

The required parameters for the follow operation is recorded via an HTML UI that can be found in the `public/index.html` file. The values have been pre-populated for ease of use but are editable.

The parameter values are allocated as seen below once the user clicks on the "Get Followers" or "Get Following" button.
The two queries are very similar and run from two different functions activated from a button on the UI. The first line of both functions is used to clear the display before new information is queried.

```javascript
//Followers function
window.submitFollower = async () => {
    //clear list
    document.getElementById('followList').innerHTML = '';

    //get user name
    const username = document.getElementById('username').value;
    //get starting letters / word
    const startFollow = document.getElementById('startFollow').value;
    //get limit
    var limit = document.getElementById('limit').value;
```

#### 3. Get followers/following<a name="query"></a>

A list of followers or users being followed is called from the database with the `follow_api` available in the `HiveJS` library.

```javascript
//get list of followers
//getFollowers(following, startFollower, followType, limit)
    let followlist = await client.call('follow_api', 'get_followers', [
        username,
        startFollow,
        'blog',
        limit,
    ]);

    document.getElementById('followResultContainer').style.display = 'flex';
    document.getElementById('followResult').className = 'form-control-plaintext alert alert-success';
    document.getElementById('followResult').innerHTML = 'Followers';


//get list of authors you are following
//getFollowing(follower, startFollowing, followType, limit)
    let followlist = await client.call('follow_api', 'get_following', [
        username,
        startFollow,
        'blog',
        limit,
    ]);

    document.getElementById('followResultContainer').style.display = 'flex';
    document.getElementById('followResult').className = 'form-control-plaintext alert alert-success';
    document.getElementById('followResult').innerHTML = 'Following';

```

#### 4. Display<a name="display"></a>

The result returned from the query is an array of objects. The follower(ing) value from that array is displayed on both the UI and the console via a simple `forEach` array method.

```javascript
followlist.forEach(newObj => {
    name = newObj.follower;
    document.getElementById('followList').innerHTML += name + '<br>';
    console.log(name);
});
```

Final code:

```javascript
//Step 1.

// const dhive = require('@hiveio/dhive');
// //define network parameters
// let opts = {};
// opts.addressPrefix = 'TST';
// opts.chainId = '18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e';
// //connect to a hive node, testnet in this case
// const client = new dhive.Client('http://127.0.0.1:8090', opts);

const dhive = require('@hiveio/dhive');
let opts = {};
//define network parameters
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to a hive node, production in this case
const client = new dhive.Client('https://api.hive.blog');


//Step 2. user fills in the values on the UI

//Followers function
window.submitFollower = async () => {
    //clear list
    document.getElementById('followList').innerHTML = '';
    
    //get user name
    const username = document.getElementById('username').value;
    //get starting letters / word
    const startFollow = document.getElementById('startFollow').value;
    //get limit
    var limit = document.getElementById('limit').value;

//Step 3. Call followers list

    //get list of followers
    //getFollowers(following, startFollower, followType, limit)
    let followlist = await client.call('follow_api', 'get_followers', [
        username,
        startFollow,
        'blog',
        limit,
    ]);

    document.getElementById('followResultContainer').style.display = 'flex';
    document.getElementById('followResult').className = 'form-control-plaintext alert alert-success';
    document.getElementById('followResult').innerHTML = 'Followers';

//Step 4. Display results on console for control check and on UI
    
    followlist.forEach((newObj) => {
        name = newObj.follower;
        document.getElementById('followList').innerHTML += name + '<br>';
        console.log(name);
    });

};

//Step 2. user fills in the values on the UI

//Following function
window.submitFollowing = async () => {
    //clear list
    document.getElementById('followList').innerHTML = '';
    
    //get user name
    const username = document.getElementById('username').value;
    //get starting letters / word
    const startFollow = document.getElementById('startFollow').value;
    //get limit
    var limit = document.getElementById('limit').value;

//Step 3. Call following list

    //get list of authors you are following
    //getFollowing(follower, startFollowing, followType, limit)
    let followlist = await client.call('follow_api', 'get_following', [
        username,
        startFollow,
        'blog',
        limit,
    ]);

    document.getElementById('followResultContainer').style.display = 'flex';
    document.getElementById('followResult').className = 'form-control-plaintext alert alert-success';
    document.getElementById('followResult').innerHTML = 'Following';

//Step 4. Display results on console for control check and on UI

    followlist.forEach((newObj) => {
        name = newObj.following;
        document.getElementById('followList').innerHTML += name + '<br>';
        console.log(name);
    });
};

```

---

### To run this tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
2. `cd devportal/tutorials/javascript/19_get_follower_and_following_list`
3. `npm i`
4. `npm run dev-server` or `npm run start`
5. After a few moments, the server should be running at http://localhost:3000/
