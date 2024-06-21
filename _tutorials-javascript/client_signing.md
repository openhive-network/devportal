---
title: titles.client_signing
position: 3
description: How to sign, verify broadcast transactions locally on Hive.
layout: full
canonical_url: client_signing.html
---
Full, runnable src of [Client Signing](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/03_client_signing) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-03_client_signing.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/03_client_signing)).

This tutorial gives you overview of how client side transaction signing works under the hood.

Purpose is to guide you through the steps required so that you could adapt this in your own applications.

We have predefined accounts to select for you to quickly use and few transaction types to test the process.

## Intro

Client side signing of transaction is yet another way of interacting with Hive blockchain. Compare to [Hivesigner](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/02_hivesigner) method, client signing doesn't rely on other servers to generate and verify transaction, except when transaction is broadcasted to the network, it should be routed through one of the servers connected to that network or blockchain. It can be your own local machine running Hive blockchain or it could be any other publicly accessible servers.

## Steps

1.  [**App setup**](#app-setup) Import `dhive` into `app.js` and prepare it to communicate with a Testnet instance of Hive blockchain
1.  [**Get globals**](#get-globals) Network globals
1.  [**Account selection**](#account-selection) Select predefined account
1.  [**Operation selection**](#operation-selection) Select common operations
1.  [**Generate transaction**](#generate-trx) Generate transaction with selected account and operation
1.  [**Sign and verify transaction**](#sav-trx) Sign and verify signature of the transaction
1.  [**Broadcast transaction**](#broadcast-trx) Broadcast signed transaction to the network

#### 1. App setup<a name="app-setup"></a>

{% include local-testnet.html %}

Testnet and Production networks only differ with few settings which helps developers to switch their application from testnet to production. One of these settings is `addressPrefix` - string that is defined and will be in front of every public address on that chain/network. Another one is `chainId` - id of that network. By defining those parameters we are selecting Testnet and connecting to publicly available server with help of `@hiveio/dhive` library. First few lines of code in `public/app.js` gives you example of connection to different networks, testnet and production.

```javascript
opts.addressPrefix = 'TST';
opts.chainId =
    '18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e';
//connect to server which is connected to the network/testnet
const client = new dhive.Client('http://127.0.0.1:8090', opts);
```

* _Disclaimer: In this tutorial we are using a testnet and predefined accounts reside on this network only._

#### 2. Get globals<a name="get-globals"></a>

To test connection as well as to get parameters of the connected network, we can use `getDynamicGlobalProperties` function from **dhive** library. Only 2 fields are in our interesting for this tutorial, `head_block_number` - returns head or latest block number of the network, `head_block_id` - returns id of head block.

![Overview](https://gitlab.syncad.com/hive/devportal/-/raw/master/tutorials/javascript/03_client_signing/images/overview.png)

#### 3. Account selection<a name="account-selection"></a>

We have predefined list of accounts to help you with generate, sign, verify and broadcast transaction on testnet. Select list has posting private key for each account and `onchange` selection event we keep account name and credentials in memory. `accountChange` function shows example of turning plain posting private key into private key buffer format that is understandable by **dhive**.

```javascript
privateKey = dhive.PrivateKey.fromString(
    document.getElementById('account').value
);
```

Account and its credentials should belong to specified testnet/mainnet network to sign/verify/broadcast transactions properly.

#### 4. Operation selection<a name="operation-selection"></a>

Number of operations are also predefined to show you example of operation format. `opChange` also keeps selected operation name in memory.

#### 5. Generate transaction<a name="generate-trx"></a>

Next we have button which helps us to generate operation object. Depending on selected operation type we have different structure for operation object. Typically, each transaction object has following fields:

* `ref_block_num` - references block number in past, in this example we have chosen head block number, but it is possible to use a block number from up to 65,536 blocks ago. This is required in TaPoS (Transaction as Proof of Stake) to avoid network forks.
* `ref_block_prefix` - reference buffer of block id of `ref_block_num` as prefix
* `expiration` - transaction expiration date in future, in our example we have set it +1 minute into future
* `operations` - array of operations, this field holds main information about transaction type and its structure which is recognized by the network
* `extensions` - any extensions to the transaction to change its parameters or options

Vote operation example

```javascript
op = {
    ref_block_num: head_block_number,
    ref_block_prefix: Buffer.from(head_block_id, 'hex').readUInt32LE(4),
    expiration: new Date(Date.now() + expireTime).toISOString().slice(0, -5),
    operations: [['vote', {
        voter: account,
        author: 'test',
        permlink: 'test',
        weight: 10000
    }]],
    extensions: [],
}
```

First item, operation type, `vote` and second item object with `voter` - account that is casting vote, `author` - author of post vote is being casted to, `permlink` - permanent link of the post, `weight` - vote weight 10000 being 100%, 1 being 0.01% smallest voting unit.

And output of operation object/json is set to `OpInput` element.

#### 6. Sign and verify transaction<a name="sav-trx"></a>

Each operation needs to be signed before they can be sent to the network, transactions without signature will not be accepted by network. Because someone has to identify operation and sign it with their private keys. Sign transaction button calls for `signTx` function which is job is to sign selected operation and its obkect with selected account. And output result into `TxOutput` element.

```javascript
stx = client.broadcast.sign(op, privateKey)
```

Verifying transaction process is mostly done automatically but to show every step, we have included this process to check validity of the transaction signature. Verify transaction button calls `verifyTx` function. Function then verify authority of the signature in signed transaction, if it was signed with correct private key and authority. If verification is successful user interfaces adds checkmark next to button otherwise adds crossmark to indicate state of the signature.

```javascript
const rv = await client.database.verifyAuthority(stx)
```

#### 7. Broadcast transaction<a name="broadcast-trx"></a>

Final step is to broadcast our signed transction to the selected server. Server chosen in Connect section will handle propagating transction to the network. After network accepts transaction it will return result with transaction `id`, `block_num` that this transaction is included to, `trx_num` transaction number, and if it is `expired` or not.

```javascript
const res = await client.broadcast.send(stx)
```

That's it!

Final code:

```javascript
import { Client, PrivateKey } from '@hiveio/dhive'; //import the api client library
import { Testnet as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

let opts = { ...NetConfig.net };
const client = new Client(NetConfig.url, opts);

let elMessage;
let privateKey = '';
let accountAddress = '';
let opType = '';
let op = {};
let stx;
let expireTime = 60 * 1000; //1 min
let head_block_number = 0;
let head_block_id = '';

async function main() {
    //get current state of network
    const props = await client.database.getDynamicGlobalProperties();
    //extract last/head block number
    head_block_number = props.head_block_number;
    //extract block id
    head_block_id = props.head_block_id;

    elMessage.innerText = 'Ready';
}

window.onload = () => {
    //prep for user interactions
    elMessage = document.getElementById('ui-message');
    //populate our account chooser
    document.getElementById('account').innerHTML += NetConfig.accounts
        .map((account, i) => `<option value="${i}">${account.address}</option>`)
        .join('');

    elMessage.innerText =
        'Give it a moment. We do not yet have the head block....';
    main().catch(error => {
        console.error('ERROR', error);
        elMessage.innerText =
            'Unable to get head block. Tutorial may not function properly';
    });
};

//account change selection function
window.accountChange = async () => {
    const account =
        NetConfig.accounts[document.getElementById('account').value];
    //get private key for selected account
    privateKey = PrivateKey.fromString(account.privActive);

    //get selected account address/name
    accountAddress = account.address;
};

//operation type change selection function
window.opChange = async () => {
    //get operation type
    opType = document.getElementById('optype').value;
};

//generate transaction function
window.generateTx = () => {
    //check operation type
    if (opType == 'vote') {
        //vote operation/transaction
        op = {
            ref_block_num: head_block_number, //reference head block number required by tapos (transaction as proof of stake)
            ref_block_prefix: Buffer.from(head_block_id, 'hex').readUInt32LE(4), //reference buffer of block id as prefix
            expiration: new Date(Date.now() + expireTime)
                .toISOString()
                .slice(0, -5), //set expiration time for transaction (+1 min)
            operations: [
                [
                    'vote',
                    {
                        voter: accountAddress,
                        author: 'test',
                        permlink: 'test',
                        weight: 10000,
                    },
                ],
            ], //example of operation object for vote
            extensions: [], //extensions for this transaction
        };
        //set operation output
        document.getElementById('OpInput').innerHTML = JSON.stringify(
            op,
            undefined,
            2
        );
    }
    if (opType == 'follow') {
        //follow operation
        op = {
            ref_block_num: head_block_number,
            ref_block_prefix: Buffer.from(head_block_id, 'hex').readUInt32LE(4),
            expiration: new Date(Date.now() + expireTime)
                .toISOString()
                .slice(0, -5),
            operations: [
                [
                    'custom_json',
                    {
                        required_auths: [],
                        required_posting_auths: [accountAddress],
                        id: 'follow',
                        json:
                            '["follow",{"follower":"' +
                            accountAddress +
                            '","following":"test","what":["blog"]}]',
                    },
                ],
            ], //example of custom_json for follow operation
            extensions: [],
        };
        document.getElementById('OpInput').innerHTML = JSON.stringify(
            op,
            undefined,
            2
        );
    }
    if (opType == 'reblog') {
        //reblog operation
        op = {
            ref_block_num: head_block_number,
            ref_block_prefix: Buffer.from(head_block_id, 'hex').readUInt32LE(4),
            expiration: new Date(Date.now() + expireTime)
                .toISOString()
                .slice(0, -5),
            operations: [
                [
                    'custom_json',
                    {
                        required_auths: [],
                        required_posting_auths: [accountAddress],
                        id: 'follow',
                        json:
                            '["reblog",{"account":"' +
                            accountAddress +
                            '","author":"test","permlink":"test"}]',
                    },
                ],
            ], //example of custom_json for reblog operation
            extensions: [],
        };
        document.getElementById('OpInput').innerHTML = JSON.stringify(
            op,
            undefined,
            2
        );
    }
};

window.signTx = () => {
    //sign transaction/operations with user's privatekey
    stx = client.broadcast.sign(op, privateKey);
    //set output
    document.getElementById('TxOutput').innerHTML = JSON.stringify(
        stx,
        undefined,
        2
    );
    console.log(stx);
};

window.verifyTx = async () => {
    //verify signed transaction authority
    const rv = await client.database.verifyAuthority(stx);
    //set checkmark or crossmark depending on outcome
    let node = document.getElementById('verifyBtn');
    rv
        ? node.insertAdjacentHTML('afterend', '&nbsp;&#x2714;&nbsp;')
        : node.insertAdjacentHTML('afterend', '&nbsp;&#x2717;&nbsp;');
};

window.broadcastTx = async () => {
    //broadcast/send transaction to the network
    const res = await client.broadcast.send(stx);
    //set output
    document.getElementById('ResOutput').innerHTML = JSON.stringify(
        res,
        undefined,
        2
    );
};

```

### To Run the tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/javascript/03_client_signing`
1. `npm i`
1. `npm run dev-server` or `npm run start`
1. After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)
