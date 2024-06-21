---
title: 'JS: Account Reputation'
position: 20
description: "_Learn how to interpret account reputation._"
layout: full
canonical_url: account_reputation.html
---
Full, runnable src of [Account Reputation](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/20_account_reputation) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-20_account_reputation.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/20_account_reputation)).

This tutorial runs on the main Hive blockchain. And accounts queried are real users with reputation.

## Intro

This tutorial will show the method of capturing a queried tag name and matching it to the Hive. We are using the `call` function provided by the `dhive` library to pull accounts from the Hive blockchain. A simple HTML interface is used to both capture the string query as well as display the completed search.

Also see:
* [get_account_reputations]({{ '/apidefinitions/#reputation_api.get_account_reputations' | relative_url }})

## steps

1.  [**App setup**](#app-setup) Configuration of `dhive` to use the proper connection and network.
2.  [**Search account**](#search-account) Collecting the relevant search criteria
3.  [**Interpret account reputation**](#run-reputation) Running the search and interpreting reputation.
4.  [**Output**](#output) Displaying the results

#### 1. App setup <a name="app-setup"></a>

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

#### 2. Search account <a name="search-account"></a>

Collecting of the search criteria happens via an HTML input. The form can be found in the `index.html` file. The values are pulled from that screen with the below:

```javascript
const max = 5;
window.submitAcc = async () => {
    const accSearch = document.getElementById('username').value;
```

#### 3. Interpret account reputation <a name="run-reputation"></a>

In order to get accounts, we run the search with the `search field` and `maximum` list items as parameters.

```javascript
const _accounts = await client.database.call('lookup_accounts',[accSearch, max]);
```

The result of the search is an array of accounts. After that we use `get_accounts` to pull account data from Hive.

```javascript
const acc = await client.database.call('get_accounts',[_accounts]);
```

And we loop through each account to convert their `reputation` to human readable format with following function:

```javascript
function log10(str) {
    const leadingDigits = parseInt(str.substring(0, 4));
    const log = Math.log(leadingDigits) / Math.LN10 + 0.00000001;
    const n = str.length - 1;
    return n + (log - parseInt(log));
}

export const repLog10 = rep2 => {
    if (rep2 == null) return rep2;
    let rep = String(rep2);
    const neg = rep.charAt(0) === '-';
    rep = neg ? rep.substring(1) : rep;

    let out = log10(rep);
    if (isNaN(out)) out = 0;
    out = Math.max(out - 9, 0); // @ -9, $0.50 earned is approx magnitude 1
    out = (neg ? -1 : 1) * out;
    out = out * 9 + 25; // 9 points per magnitude. center at 25
    // base-line 0 to darken and < 0 to auto hide (grep rephide)
    out = parseInt(out);
    return out;
};
```

#### 4. Output <a name="output"></a>

After each account's reputation is interpreted we can then display them on screen with readable reputation.

```javascript
//disply list of account names and reputation with line breaks
for (var i = 0; i < _accounts.length; i++) {
    _accounts[i] = `${_accounts[i]} - ${repLog10(acc[i].reputation)}`;
}
document.getElementById('accList').innerHTML = _accounts.join('<br/>');
```

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

/**
    This is a rough approximation of log10 that works with huge digit-strings.
    Warning: Math.log10(0) === NaN
    The 0.00000001 offset fixes cases of Math.log(1000)/Math.LN10 = 2.99999999~
*/
function log10(str) {
    const leadingDigits = parseInt(str.substring(0, 4));
    const log = Math.log(leadingDigits) / Math.LN10 + 0.00000001;
    const n = str.length - 1;
    return n + (log - parseInt(log));
}

export const repLog10 = rep2 => {
    if (rep2 == null) return rep2;
    let rep = String(rep2);
    const neg = rep.charAt(0) === '-';
    rep = neg ? rep.substring(1) : rep;

    let out = log10(rep);
    if (isNaN(out)) out = 0;
    out = Math.max(out - 9, 0); // @ -9, $0.50 earned is approx magnitude 1
    out = (neg ? -1 : 1) * out;
    out = out * 9 + 25; // 9 points per magnitude. center at 25
    // base-line 0 to darken and < 0 to auto hide (grep rephide)
    out = parseInt(out);
    return out;
};

//submitAcc function from html input
const max = 5;
window.submitAcc = async () => {
    const accSearch = document.getElementById('username').value;

    const _accounts = await client.database.call('lookup_accounts', [
        accSearch,
        max,
    ]);
    console.log(`_accounts:`, _accounts);

    const acc = await client.database.call('get_accounts', [_accounts]);

    //disply list of account names and reputation with line breaks
    for (var i = 0; i < _accounts.length; i++) {
        _accounts[i] = `${_accounts[i]} - ${repLog10(acc[i].reputation)}`;
    }
    document.getElementById('accList').innerHTML = _accounts.join('<br/>');
};

```

---

### To run this tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/20_account_reputation`
1. `npm i`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
