---
title: 'JS: Delegate Power'
position: 27
description: "_Delegate power to other users using Hive Signer or Client-side signing._"
layout: full
canonical_url: delegate_power.html
---
Full, runnable src of [Delegate Power](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/27_delegate_power) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-27_delegate_power.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/27_delegate_power)).

This tutorial runs on the main Hive blockchain. And accounts queried/searched are real accounts with their available VESTS balances and estimated HIVE POWER holdings.

## Intro

This tutorial will show few functions such as querying account by name and getting account vesting balance. We then convert VESTS to HIVE POWER for convenience of user. And allow user to choose portion or all holdings of VESTS to delegate other users. A simple HTML interface is provided to capture the account with search and its VESTS balance as well as allowing interactively delegate. It should be noted that when a delegation is cancelled, the VESTS will only be available again after a 5 day cool-down period.

Also see:
* [delegate_vesting_shares_operation]({{ '/apidefinitions/#broadcast_ops_delegate_vesting_shares' | relative_url }})
* [get_vesting_delegations]({{ '/apidefinitions/#condenser_api.get_vesting_delegations' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) Setup `dhive` to use the proper connection and network.
2.  [**Search account**](#search-account) Get account details after input has account name
3.  [**Calculate and Fill form**](#fill-form) Calculate available vesting shares and Fill form with details
4.  [**Delegate power**](#delegate-power) Delegate VESTS with Hive Signer or Client-side signing.

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
    const _account = await client.database.call('get_accounts', [[accSearch]]);
    console.log(`_account:`, _account);
```

#### 3. Calculate and Fill form <a name="fill-form"></a>

After we fetched account data, we will fill form with VESTS balance and show current balance details. Note, that in order to get available VESTS balance we will have to check if account is already powering down and how much is powering down, how much of VESTS were delegated out which locks them from being powered down. Available balance will be in `avail` variable, next for convenience of user, we convert available VESTS to HIVE with `getDynamicGlobalProperties` function and fill form fields accordingly.

```javascript
    const name = _account[0].name;
    const avail = parseFloat(_account[0].vesting_shares) - (parseFloat(_account[0].to_withdraw) - parseFloat(_account[0].withdrawn)) / 1e6 - parseFloat(_account[0].delegated_vesting_shares);

    const props = await client.database.getDynamicGlobalProperties();
    const vestHive = parseFloat(parseFloat(props.total_vesting_fund_hive) *
        (parseFloat(avail) / parseFloat(props.total_vesting_shares)),6);

    const balance = `Available Vests for ${name}: ${avail} VESTS ~ ${vestHive} HIVE POWER<br/><br/>`;
    document.getElementById('accBalance').innerHTML = balance;
    document.getElementById('hive').value = avail+' VESTS';
```

Once form is filled with maximum available VESTS balance, you can choose portion or lesser amount of VESTS to delegate other user.

#### 4. Delegate power <a name="delegate-power"></a>

We have 2 options on how to delegate others. Hive Signer and Client-side signing options. By default we generate Hive Signer link to delegate power (delegate vesting shares), but you can choose client signing option to delegate right inside tutorial, note client-side signing will require Active Private key to perform the operation.

In order to enable client signing, we will generate operation and also show Active Private key (wif) field to sign transaction client side.
Below you can see example of operation and signing transaction, after successful operation broadcast result will be shown in user interface. It will be block number that transaction was included.

```javascript
window.submitTx = async () => {
    const privateKey = dhive.PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'delegate_vesting_shares',
        {
            delegator: document.getElementById('username').value,
            delegatee: document.getElementById('account').value,
            vesting_shares: document.getElementById('hive').value,
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
import { Client, PrivateKey } from '@hiveio/dhive';
import { Mainnet as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

let opts = { ...NetConfig.net };
//connect to a hive node, testnet in this case
const client = new Client(NetConfig.url, opts);

//submitAcc function from html input
const max = 5;
window.submitAcc = async () => {
    const accSearch = document.getElementById('username').value;

    const _account = await client.database.call('get_accounts', [[accSearch]]);
    console.log(`_account:`, _account);

    const name = _account[0].name;
    const avail =
        parseFloat(_account[0].vesting_shares) -
        (parseFloat(_account[0].to_withdraw) -
            parseFloat(_account[0].withdrawn)) /
            1e6 -
        parseFloat(_account[0].delegated_vesting_shares);

    const props = await client.database.getDynamicGlobalProperties();
    const vestHive = parseFloat(
        parseFloat(props.total_vesting_fund_hive) *
            (parseFloat(avail) / parseFloat(props.total_vesting_shares)),
        6
    );

    const balance = `Available Vests for ${name}: ${avail} VESTS ~ ${vestHive} HIVE POWER<br/><br/>`;
    document.getElementById('accBalance').innerHTML = balance;
    document.getElementById('hive').value =
        Number(avail).toFixed(6) + ' VESTS';
};
window.openSC = async () => {
    const link = `https://hivesigner.com/sign/delegate-vesting-shares?delegator=${
        document.getElementById('username').value
    }&vesting_shares=${document.getElementById('hive').value}&delegatee=${
        document.getElementById('account').value
    }`;
    window.open(link);
};
window.submitTx = async () => {
    const privateKey = PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'delegate_vesting_shares',
        {
            delegator: document.getElementById('username').value,
            delegatee: document.getElementById('account').value,
            vesting_shares: document.getElementById('hive').value,
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
1. `cd devportal/tutorials/javascript/27_delegate_power`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
