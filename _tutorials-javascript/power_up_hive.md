---
title: titles.power_up
position: 24
description: "_Power up an account's Hive using either Hive Signer or a client-side signing._"
layout: full
canonical_url: power_up_hive.html
---
Full, runnable src of [Power Up Hive](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/24_power_up_hive) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-24_power_up_hive.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/24_power_up_hive)).

This tutorial runs on the main Hive blockchain. And accounts queried are real users with liquid HIVE balances.

## Intro

This tutorial will show few functions such as querying account by name and getting account balance. We are using the `call` function provided by the `dhive` library to pull account from the Hive blockchain. A simple HTML interface is used to capture the account and its HIVE balance as well as allowing interactively power up part or all of HIVE to choose account.

Also see:
* [transfer_to_vesting_operation]({{ '/apidefinitions/#broadcast_ops_transfer_to_vesting' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) Setup `dhive` to use the proper connection and network.
2.  [**Search account**](#search-account) Get account details after input has account name
3.  [**Fill form**](#fill-form) Fill form with account reward balances
4.  [**Power up**](#power-up) Power up HIVE with Hive Signer or Client-side signing.

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

#### 3. Fill form <a name="fill-form"></a>

After we fetched account data, we will fill form with HIVE balance and show current balance details.

```javascript
const name = _account[0].name;
const hive_balance = _account[0].balance;
const balance = `Available Hive balance for ${name}: ${hive_balance}<br/>`;
document.getElementById('accBalance').innerHTML = balance;
document.getElementById('hive').value = hive_balance;
const receiver = document.getElementById('receiver').value;
```

#### 4. Power up <a name="power-up"></a>

We have 2 options on how to Power up. Hive Signer and Client-side signing options. By default we generate Hive Signer link to Power up (transfer to vesting), but you can use client signing option to Power up right inside tutorial, note client-side signing will require Active private key to perform operation.

In order to enable client signing, we will generate operation and also show Active Private key (wif) field to sign transaction right there client side.
Below you can see example of operation and signing transaction, after successful operation broadcast result will be shown in user interface. It will be block number that transaction was included.

```javascript
window.submitTx = async () => {
    const privateKey = dhive.PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'transfer_to_vesting',
        {
            from: document.getElementById('username').value,
            to: document.getElementById('receiver').value,
            amount: document.getElementById('hive').value,
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
    const hive_balance = _account[0].balance;
    const balance = `Available Hive balance for ${name}: ${hive_balance}<br/>`;
    document.getElementById('accBalance').innerHTML = balance;
    document.getElementById('hive').value = hive_balance;
    const receiver = document.getElementById('receiver').value;

    document.getElementById('sc').style.display = 'block';
    const link = `https://hivesigner.com/sign/transfer-to-vesting?from=${name}&to=${receiver}&amount=${hive_balance}`;
    document.getElementById('sc').innerHTML = `<br/><a href=${encodeURI(
        link
    )} target="_blank">Hive Signer signing</a>`;
};

window.submitTx = async () => {
    const privateKey = PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'transfer_to_vesting',
        {
            from: document.getElementById('username').value,
            to: document.getElementById('receiver').value,
            amount: document.getElementById('hive').value,
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
1. `cd devportal/tutorials/javascript/24_power_up_hive`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
