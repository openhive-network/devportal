---
title: 'JS: Grant Posting Permission'
position: 30
description: "_How to grant and revoke posting permission to another user._"
layout: full
canonical_url: grant_posting_permission.html
---
Full, runnable src of [Grant Posting Permission](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript/30_grant_posting_permission) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just this tutorial: [devportal-master-tutorials-javascript-30_grant_posting_permission.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript/30_grant_posting_permission)).

This tutorial will take you through the process of checking a specific users' data, altering the array pertaining to the posting `account_auths`, and then broadcasting the changes to the blockchain. Demo account information has been provided to assist with the tutorial. This tutorial has been set up for the `testnet` but can be easily be changed for `production`.

Providing another user posting permission for your account can be used to allow multiple users to submit posts on a single hive community.  There are also applications that allows you to schedule posts by automatically publishing on your behalf.

## Intro

This tutorial uses the `database API` to gather account information for the user that is granting posting permission to another user. This information is used to check current permissions as well as to build the `broadcast` operation. Granting or revoking posting permission works by changing the array of usernames containing this information and then pushing those changes to the blockchain. The parameters for this `updateAccount` function are:

1.  _account_ - The username of the main account
2.  _active_ - Optional parameter to denote changes to the active authority type
3.  _jsonMetadata_ - This is a string value obtained from the current account info
4.  _memoKey_ - This is the public memoKey of the user
5.  _owner_ - Optional parameter to denote changes to the owner authority type
6.  _posting_ - Optional parameter to denote changes to the posting authority type. This is the parameter that we will be changing in this tutorial
7.  _privateKey_ - The private `active` key of the user

The only other information required is the username of the account that the posting permission is being granted to.

The tutorial is set up with three individual functions for each of the required operations - checking permission status, granting permission and revoking permission.

Also see:
* [account_update_operation]({{ '/apidefinitions/#broadcast_ops_account_update' | relative_url }})

## Steps

1.  [**Configure connection**](#connection) Configuration of `dhive` to communicate with a Hive blockchain
2.  [**Input variables**](#input) Collecting the required inputs via an HTML UI.
3.  [**Database query**](#query) Sending a query to the blockchain for the posting permissions (status)
4.  [**Object creation**](#object) Create the array and subsequent data object for the broadcast operation
5.  [**Broadcast operation**](#broadcast) Broadcasting the changes to the blockchain

#### 1. Configure connection<a name="connection"></a>

{% include local-testnet.html %}

As usual, we have a `public/app.js` file which holds the Javascript segment of the tutorial. In the first few lines we define the configured library and packages:

```javascript
const dhive = require('@hiveio/dhive');
//define network parameters
let opts = {};
opts.addressPrefix = 'TST';
opts.chainId =
    '18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e';
//connect to a hive node, testnet in this case
const client = new dhive.Client('http://127.0.0.1:8090', opts);
```

Above, we have `dhive` pointing to the testnet with the proper chainId, addressPrefix, and endpoint. Due to this tutorial altering the blockchain it is preferable to not work on production.

#### 2. Input variables<a name="input"></a>

The required parameters for the account status query is recorded via an HTML UI that can be found in the `public/index.html` file. The values are pre-populated in this case but any account name can be used.

All of the functions use the same input variables. Once the function is activated via the UI the variables are allocated as seen below.

```javascript
//get username
const username = document.getElementById('username').value;
//get private active key
const privateKey = dhive.PrivateKey.fromString(
    document.getElementById('privateKey').value
);
//get account to provide posting auth
const newAccount = document.getElementById('newAccount').value;
```

#### 3. Database query<a name="query"></a>

The queries are sent through to the hive blockchain with the `database API` using the `getAccounts` function. The results of the query is used to check the status of the current posting authorisations and parameters as per the `intro`.

```javascript
    //query database for posting array
    _data = new Array
    _data = await client.database.getAccounts([username]);
    const postingAuth = _data[0].posting;

     //check for username duplication
    const checkAuth = _data[0].posting.account_auths;
    var arrayindex = -1;
    var checktext = " does not yet have posting permission"
    for (var i = 0,len = checkAuth.length; i<len; i++) {
        if (checkAuth[i][0]==newAccount) {
            arrayindex = i
            var checktext = " already has posting permission"
        }
    }
```

The result of this status query is then displayed on the UI along with the array on the console as a check.

```javascript
document.getElementById('permCheckContainer').style.display = 'flex';
document.getElementById('permCheck').className =
    'form-control-plaintext alert alert-success';
document.getElementById('permCheck').innerHTML = newAccount + checktext;
console.log(checkAuth);
```

#### 4. Object creation<a name="object"></a>

The database query is the same for all the functions and is required to create an updated array to broadcast to the blockchain. This is how we determine whether a user permission will be added or revoked. The actual operation is the same apart from the array variable as can be seen below. The difference is in that when creating a permission, an element is added to the `account_auths` array where revoking removes an element from it.

```javascript
//add account permission
postingAuth.account_auths.push([
    newAccount,
    parseInt(postingAuth.weight_threshold),
]);
postingAuth.account_auths.sort();

//revoke permission
postingAuth.account_auths.splice(arrayindex, 1);
```

When adding to the array (creaing permission) it is required to sort the array before we can broadcast. The hive blockchain does not accept the new fields in the array if it's not alphabetically sorted.
After the posting array has been defined, the broadcast object can be created. This holds all the required information for a successful transaction to be sent to the blockchain. Where there is no change in the authority types, the parameter can be omitted or in the case of required parameters, allocated directly from the database query.

```javascript
//object creation
const accObj = {
    account: username,
    json_metadata: _data[0].json_metadata,
    memo_key: _data[0].memo_key,
    posting: postingAuth,
};
```

#### 5. Broadcast operation<a name="broadcast"></a>

With all the parameters assigned, the transaction can be broadcast to the blockchain. As stated before, the actual `broadcast` operation for both new permissions and to revoke permissions use the same parameters.

```javascript
//account update broadcast
client.broadcast.updateAccount(accObj, privateKey).then(
    function(result) {
        console.log(
            'included in block: ' + result.block_num,
            'expired: ' + result.expired
        );
        document.getElementById('permCheckContainer').style.display = 'flex';
        document.getElementById('permCheck').className =
            'form-control-plaintext alert alert-success';
        document.getElementById('permCheck').innerHTML =
            'posting permission has been granted to ' + newAccount;
    },
    function(error) {
        console.error(error);
        document.getElementById('permCheckContainer').style.display = 'flex';
        document.getElementById('permCheck').className =
            'form-control-plaintext alert alert-danger';
        document.getElementById('permCheck').innerHTML = error.jse_shortmsg;
    }
);
```

The results of the operation is displayed on the UI along with a block number in the console to confirm a successful operation. If you add permission to an account that already has permission will display an error of "Missing Active Authority".

Hivesigner offers an alternative to revoking posting permission with a "simple link" solution. Instead of running through a list of opetions on your account, you can simply use a link similar to the one below. You will be prompted to enter your usename and password and the specified user will have their posting permission removed instantly.
https://hivesigner.com/revoke/@username
This is similar to the Hive Signer links that have been covered in previous tutorials. For a list of signing operations that work in this manner you can go to https://hivesigner.com/signs


Final code:

```javascript
import { Client, PrivateKey } from '@hiveio/dhive';
import { Testnet as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

let opts = { ...NetConfig.net };

//connect to a hive node, testnet in this case
const client = new Client(NetConfig.url, opts);

//check permission status
window.submitCheck = async () => {
    //get username
    const username = document.getElementById('username').value;
    //get account to provide posting auth
    const newAccount = document.getElementById('newAccount').value;

    //query database for posting array
    var _data = new Array();
    _data = await client.database.getAccounts([username]);
    const postingAuth = _data[0].posting;

    //check for username duplication
    const checkAuth = _data[0].posting.account_auths;
    var arrayindex = -1;
    var checktext = ' does not yet have posting permission';
    for (var i = 0, len = checkAuth.length; i < len; i++) {
        if (checkAuth[i][0] == newAccount) {
            arrayindex = i;
            var checktext = ' already has posting permission';
        }
    }
    document.getElementById('permCheckContainer').style.display = 'flex';
    document.getElementById('permCheck').className =
        'form-control-plaintext alert alert-success';
    document.getElementById('permCheck').innerHTML = newAccount + checktext;
    console.log(checkAuth);
};

//grant permission function
window.submitPermission = async () => {
    //get username
    const username = document.getElementById('username').value;
    //get private active key
    const privateKey = PrivateKey.fromString(
        document.getElementById('privateKey').value
    );
    //get account to provide posting auth
    const newAccount = document.getElementById('newAccount').value;

    var _data = new Array();
    _data = await client.database.getAccounts([username]);
    const postingAuth = _data[0].posting;

    //adding of new account to posting array
    postingAuth.account_auths.push([
        newAccount,
        parseInt(postingAuth.weight_threshold),
    ]);
    //sort array required for hive blockchain
    postingAuth.account_auths.sort();

    //object creation
    const accObj = {
        account: username,
        json_metadata: _data[0].json_metadata,
        memo_key: _data[0].memo_key,
        posting: postingAuth,
    };

    //account update broadcast
    client.broadcast.updateAccount(accObj, privateKey).then(
        function(result) {
            console.log(
                'included in block: ' + result.block_num,
                'expired: ' + result.expired
            );
            document.getElementById('permCheckContainer').style.display =
                'flex';
            document.getElementById('permCheck').className =
                'form-control-plaintext alert alert-success';
            document.getElementById('permCheck').innerHTML =
                'posting permission has been granted to ' + newAccount;
        },
        function(error) {
            console.error(error);
            document.getElementById('permCheckContainer').style.display =
                'flex';
            document.getElementById('permCheck').className =
                'form-control-plaintext alert alert-danger';
            document.getElementById('permCheck').innerHTML = error.jse_shortmsg;
        }
    );
};

//revoke permission function
window.submitRevoke = async () => {
    //get username
    const username = document.getElementById('username').value;
    //get private active key
    const privateKey = PrivateKey.fromString(
        document.getElementById('privateKey').value
    );
    //get account to provide posting auth
    const newAccount = document.getElementById('newAccount').value;

    var _data = new Array();
    _data = await client.database.getAccounts([username]);
    const postingAuth = _data[0].posting;

    //check for user index in posting array
    const checkAuth = _data[0].posting.account_auths;
    var arrayindex = -1;
    for (var i = 0, len = checkAuth.length; i < len; i++) {
        if (checkAuth[i][0] == newAccount) {
            arrayindex = i;
        }
    }

    if (arrayindex < 0) {
        document.getElementById('permCheckContainer').style.display = 'flex';
        document.getElementById('permCheck').className =
            'form-control-plaintext alert alert-danger';
        document.getElementById('permCheck').innerHTML =
            newAccount + ' does not yet have posting permission to revoke';
        return;
    }

    //removal of array element in order to revoke posting permission
    postingAuth.account_auths.splice(arrayindex, 1);

    //object creation
    const accObj = {
        account: username,
        json_metadata: _data[0].json_metadata,
        memo_key: _data[0].memo_key,
        posting: postingAuth,
    };

    //account update broadcast
    client.broadcast.updateAccount(accObj, privateKey).then(
        function(result) {
            console.log(
                'included in block: ' + result.block_num,
                'expired: ' + result.expired
            );
            document.getElementById('permCheckContainer').style.display =
                'flex';
            document.getElementById('permCheck').className =
                'form-control-plaintext alert alert-success';
            document.getElementById('permCheck').innerHTML =
                'permission has been revoked for ' + newAccount;
        },
        function(error) {
            console.error(error);
            document.getElementById('permCheckContainer').style.display =
                'flex';
            document.getElementById('permCheck').className =
                'form-control-plaintext alert alert-danger';
            document.getElementById('permCheck').innerHTML = error.jse_shortmsg;
        }
    );
};

window.onload = async () => {
    const account = NetConfig.accounts[0];
    const accountI = NetConfig.accounts[1];
    document.getElementById('username').value = account.address;
    document.getElementById('privateKey').value = account.privActive;
    document.getElementById('newAccount').value = accountI.address;
};

```

### To run this tutorial

1. `git clone https://gitlab.syncad.com/hive/devportal.git`
2. `cd devportal/tutorials/javascript/30_grant_posting_permission`
3. `npm i`
4. `npm run dev-server` or `npm run start`
5. After a few moments, the server should be running at http://localhost:3000/
