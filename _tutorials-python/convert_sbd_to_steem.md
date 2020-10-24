---
title: 'PY: Convert Hbd To Hive'
position: 32
description: "How to convert your HBD to HIVE using Python."
layout: full
canonical_url: convert_hbd_to_hive.html
---              
<span class="fa-pull-left top-of-tutorial-repo-link"><span class="first-word">Full</span>, runnable src of [Convert Hbd To Hive](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/tutorials/32_convert_hbd_to_hive) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python).</span>
<br>



In this tutorial we will explain and show you how to convert some or all of your available HBD balance into HIVE on the **Hive** blockchain using the `commit` class found within the [steem-python](https://github.com/steemit/steem-python) library.

It should be noted that the converted HIVE will not be available instantly as it takes 3.5 days for the transaction to be processed. It is also not possible to stop a conversion once initialised. During the 3.5 days for it to be converted and as the conversion price fluctuates you could actually be receiving less HIVE than what you should. Because of this, the method in this tutorial is NOT the preferred or most efficient way of converting HBD to HIVE. This tutorial just illustrates that it can be done in this manner.

There is a marketplace on Hive that allows you to "sell" your HBD instantly. With this process you can get your HIVE immediately and at the exact price that you expect. The market place is the better way to convert your HBD. [This article](https://hive.blog/steem/@epico/convert-hbd-to-steem-and-steem-power-guide-2017625t103821622z) provides more information on using the market to exchange your HBD to HIVE

Hiveconnect offers an alternative to converting HBD with a "simple link" solution. Instead of running through a list of operations on your account, you can simply use a link similar to the one below substituting the three parameters for your own details. You will be prompted to enter your username and password before the transaction will be executed.
https://steemconnect.com/sign/convert?owner=username&requestid=1234567&amount=0.000%20HBD
This is similar to the steemconnect links that have been covered in previous tutorials. For a list of signing operations that work in this manner you can go to https://v2.steemconnect.com/sign
[This article](https://hive.blog/hbd/@timcliff/how-to-convert-hbd-into-steem-using-steemconnect) has more information on using steemconnect

## Intro

The Hive python library has a built-in function to transmit transactions to the blockchain. We are using the `convert` method found within the `commit` class in the library. Before we do the conversion, we check the current balance of the account to check how much HBD is available. This is not strictly necessary as the process will automatically abort with the corresponding error, but it does give some insight into the process as a whole. We use the `get_account` function to check for this. The `convert` method has 3 parameters:

1.  _amount_ - The amount of HBD that will be converted
1.  _account_ - The specified user account for the conversion
1.  _request-id_ - An identifier for tracking the conversion. This parameter is optional

## Steps

1.  [**App setup**](#setup) - Library install and import. Connection to testnet
1.  [**User information and steem node**](#userinfo) - Input user information and connection to Hive node
1.  [**Check balance**](#balance) - Check current HIVE and HBD balance of user account
1.  [**Conversion amount and commit**](#convert) - Input of HBD amount to convert and commit to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we only use 1 package:

- `steem` - steem-python library and interaction with Blockchain

We import the libraries and connect to the `testnet`.

```python
import steembase
import steem

steembase.chains.known_chains['HIVE'] = {
    'chain_id': '79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673',
    'prefix': 'STX', 'hive_symbol': 'HIVE', 'hbd_symbol': 'HBD', 'vests_symbol': 'VESTS'
}
```

Because this tutorial alters the blockchain we connect to the testnet so we don't create spam on the production server.

#### 2. User information and steem node <a name="userinfo"></a>

We require the `private active key` of the user in order for the conversion to be committed to the blockchain. This is why we have to specify this alongside the `testnet` node. The values are supplied via the terminal/console before we initialise the steem class. There is a demo account available to use with this tutorial but any account that is set up on the testnet can be used.

```python
#capture user information
username = input('Enter username: ') #demo account: demo01
wif = input('Enter private ACTIVE key: ') #demo account: 5HxTntgeoLm4trnTz94YBsY6MpAap1qRVXEKsU5n1v2du1gAgVH

#connect node and private active key
client = steem.Hive(nodes=['https://testnet.steem.vc'], keys=[wif])
```

#### 3. Check balance <a name="balance"></a>

In order to give the user enough information to make the conversion we check the current balance of the account using the `get_account` function.

```python
#get account balance for HIVE and HBD
userinfo = client.get_account(username)
total_hive = userinfo['balance']
total_hbd = userinfo['hbd_balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + total_hive + '\n' + total_hbd + '\n')
```

The result of the query is displayed in the console/terminal.

#### 4. Conversion amount and commit <a name="convert"></a>

The final step before we can commit the transaction to the blockchain is to assign the `amount` parameter. We do this via a simple input from the terminal/console.

```python
#get recipient name
convert_amount = input('Enter the amount of HBD to convert to HIVE: ')
```

This value must be greater than zero in order for the transaction to execute without any errors. Now that we have all the parameters we can do the actual transmission of the transaction to the blockchain.

```python
#parameters: amount, account, request_id
client.convert(float(convert_amount), username)

print('\n' + convert_amount + ' HBD has been converted to HIVE')
```

If no errors are encountered a simple confirmation is printed on the UI.

As an added confirmation we check the balance of the user again and display it on the UI. This is not required at all but it serves as a more definitive confirmation that the conversion has been completed correctly.

```python
#get remaining account balance for HIVE and HBD
userinfo = client.get_account(username)
total_hive = userinfo['balance']
total_hbd = userinfo['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + total_hive + '\n' + total_hbd)
```

The HIVE balance will not yet have been updated as it takes 3.5 days to settle. The HBD will however show the new balance.

We encourage users to play around with different values and data types to fully understand how this process works. You can also check the balances and transaction history on the [testnet portal](http://condenser.steem.vc/).

### To Run the tutorial

1.  [review dev requirements](getting_started.html)
1.  `git clone https://gitlab.syncad.com/hive/devportal.git`
1.  `cd devportal/tutorials/python/32_convert_hbd_to_hive`
1.  `pip install -r requirements.txt`
1.  `python index.py`
1.  After a few moments, you should see a prompt for input in terminal screen.


---
