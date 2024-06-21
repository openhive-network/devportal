---
title: titles.claim_rewards
position: 23
description: "_Learn how to claim rewards from unclaimed reward balance using Hive Signer as well as client signing method._"
layout: full
canonical_url: claim_rewards.html
---
Full, runnable src of [Claim Rewards](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/23_claim_rewards) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-23_claim_rewards.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/23_claim_rewards)).

This tutorial runs on the main Hive blockchain. And accounts queried are real users with unclaimed balances.

## Intro

This tutorial will show few functions such as querying account by name and getting unclaimed rewards. We are using the `call` function provided by the `dhive` library to pull accounts from the Hive blockchain. A simple HTML interface is used to capture the account and its unclaimed balance as well as allowing interactively claim rewards.

Also see:
* [claim_reward_balance_operation]({{ '/apidefinitions/#broadcast_ops_claim_reward_balance' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) Setup `dhive` to use the proper connection and network.
2.  [**Search account**](#search-account) Get account details after input has account name
3.  [**Fill form**](#fill-form) Fill form with account reward balances
4.  [**Claim reward**](#claim-reward) Claim reward with Hive Signer or Client signing options

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

After account name field is filled with some name, we do automatic search for account by name when input is focused out. HTML input forms can be found in the `index.html` file. The values are pulled from that screen with the below:

```javascript
    const accSearch = document.getElementById('username').value;
    const _accounts = await client.database.call('get_accounts', [[accSearch]]);
    console.log(`_accounts:`, _accounts);
```

#### 3. Fill form <a name="fill-form"></a>

After we fetched account data, we will fill form with reward balance and show current reward balance details.

```javascript
const name = _accounts[0].name;
const reward_hive = _accounts[0].reward_hive_balance.split(' ')[0];
const reward_hbd = _accounts[0].reward_hbd_balance.split(' ')[0];
const reward_sp = _accounts[0].reward_vesting_hive.split(' ')[0];
const reward_vests = _accounts[0].reward_vesting_balance.split(' ')[0];
const unclaimed_balance = `Unclaimed balance for ${name}: ${reward_hive} HIVE, ${reward_hbd} HBD, ${reward_sp} HP = ${reward_vests} VESTS<br/>`;
document.getElementById('accList').innerHTML = unclaimed_balance;
document.getElementById('hive').value = reward_hive;
document.getElementById('hbd').value = reward_hbd;
document.getElementById('hp').value = reward_vests;
```

#### 4. Claim reward <a name="claim-reward"></a>

We have 2 options on how to claim rewards. Hive Signer and Client signing options. We generate Hive Signer link to claim rewards, but you can also choose client signing option to claim rewards right inside tutorial.

In order to enable client signing, we will generate operation and also show Posting Private key (wif) field to sign transaction right there client side.
Below you can see example of operation and signing transaction, after successful operation broadcast result will be shown in user interface. It will be block number that transaction was included.

```javascript
window.submitTx = async () => {
    const privateKey = dhive.PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'claim_reward_balance',
        {
            account: document.getElementById('username').value,
            reward_hive: document.getElementById('hive').value + ' HIVE',
            reward_hbd: document.getElementById('hbd').value + ' HBD',
            reward_vests: document.getElementById('hp').value + ' VESTS',
        },
    ];
    client.broadcast.sendOperations([op], privateKey).then(
        function(result) {
            document.getElementById('result').style.display = 'block';
            document.getElementById(
                'result'
            ).innerHTML = `<br/><p>Included in block: ${
                result.block_num
            }</p><br/><br/>`;
        },
        function(error) {
            console.error(error);
        }
    );
};
```

That's it!

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

//submitAcc function from html input
const max = 5;
window.submitAcc = async () => {
    const accSearch = document.getElementById('username').value;

    const _accounts = await client.database.call('get_accounts', [[accSearch]]);
    console.log(`_accounts:`, _accounts);
    const name = _accounts[0].name;
    const reward_hive = _accounts[0].reward_hive_balance.split(' ')[0];
    const reward_hbd = _accounts[0].reward_hbd_balance.split(' ')[0];
    const reward_hp = _accounts[0].reward_vesting_hive.split(' ')[0];
    const reward_vests = _accounts[0].reward_vesting_balance.split(' ')[0];
    const unclaimed_balance = `Unclaimed balance for ${name}: ${reward_hive} HIVE, ${reward_hbd} HBD, ${reward_hp} HP = ${reward_vests} VESTS<br/>`;
    document.getElementById('accList').innerHTML = unclaimed_balance;
    document.getElementById('hive').value = reward_hive;
    document.getElementById('hbd').value = reward_hbd;
    document.getElementById('hp').value = reward_vests;

    document.getElementById('hc').style.display = 'block';
    const link = `https://hivesigner.com/sign/claim-reward-balance?account=${name}&reward_hive=${reward_hive}&reward_hbd=${reward_hbd}&reward_vests=${reward_vests}`;
    document.getElementById('hc').innerHTML = `<br/><a href=${link} target="_blank">Hive Signer signing</a>`;
};

window.submitTx = async () => {
    const privateKey = dhive.PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'claim_reward_balance',
        {
            account: document.getElementById('username').value,
            reward_hive: document.getElementById('hive').value + ' HIVE',
            reward_hbd: document.getElementById('hbd').value + ' HBD',
            reward_vests: document.getElementById('hp').value + ' VESTS',
        },
    ];
    client.broadcast.sendOperations([op], privateKey).then(
        function(result) {
            document.getElementById('result').style.display = 'block';
            document.getElementById(
                'result'
            ).innerHTML = `<br/><p>Included in block: ${
                result.block_num
            }</p><br/><br/>`;
        },
        function(error) {
            console.error(error);
        }
    );
};

```

### To run this tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/23_claim_rewards`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
