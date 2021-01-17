---
title: 'JS: Search Accounts'
position: 15
description: "_How to call a list of user names from the hive blockchain_"
layout: full
canonical_url: search_accounts.html
---
Full, runnable src of [Search Accounts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/15_search_accounts) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-15_search_accounts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/15_search_accounts)).

This tutorial will show the method of capturing a queried user name, matching that to the hive database and then displaying the matching names. This tutorial will be run on the `production server`.

## Intro

We are using the `call` function provided by the `dhive` library to pull user names from the hive blockchain. The information being pulled is dependent on two variables:

1.  The max number of user names that needs to be displayed by the search
2.  The string representing the first characters of the user name you are searching for

A simple HTML interface is used to both capture the string query as well as display the completed search. The layout can be found in the "index.html" file.

## Steps

1. [**Configure connection**](#configure_connection) Configuration of `dhive` to use the proper connection and network.
2. [**Collecting input variables**](#collecting_input_variables) Assigning and collecting the necessary variables
3. [**Blockchain query**](#blockchain_query) Finding the data on the blockchain based on the inputs
4. [**Output**](#output) Displaying query results


#### 1. **Configure connection**<a name="configure_connection"></a>

Below we have `dhive` pointing to the production network with the proper chainId, addressPrefix, and endpoint. There is a `public/app.js` file which holds the Javascript segment of this tutorial. In the first few lines we define the configured library and packages:

```javascript
const dhive = require('@hiveio/dhive');
let opts = {};
//connect to production server
opts.addressPrefix = 'STM';
opts.chainId =
	'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to server which is connected to the network/production
const client = new dhive.Client('https://api.hive.blog');
```

#### 2.  **Collecting input variables**<a name="collecting_input_variables"></a>

Next we assign the max number of lines that will be returned by the query. We also use `getElementById` to retrieve the requested user name for searching from the HTML interface. The `max` value can very easily also be attained from the HTML side simply by adding another input line in `index.html` and a second `getElementById` line.

```javascript
const max = 10;
window.submitAcc = async () => {
    const accSearch = document.getElementById("username").value;
```

#### 3.  **Blockchain query**<a name="blockchain_query"></a>

The next step is to pull the user names from the blockchain that matches the "username" variable that was retrieved. This is done using the `database.call` function and assigning the result to an array.

```javascript
const _accounts = await client.database.call('lookup_accounts',[accSearch, max]);
    console.log(`_accounts:`, _accounts);
```

#### 4.  **Output**<a name="output"></a>

Finally we create a list from the "_accounts" array generated in step 3.

```javascript
document.getElementById('accList').innerHTML = _accounts.join('<br>');
}
```

## To run this tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
2. `cd devportal/tutorials/javascript/15_search_accounts`
3. `npm i`
4. `npm run dev-server` or `npm run start`
5. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
