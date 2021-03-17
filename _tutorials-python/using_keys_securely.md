---
title: 'PY: Using Keys Securely'
position: 1
description: "Learn how the Beem python library handles transaction signing with Hive user's key and how to securely manage your private keys."
layout: full
canonical_url: using_keys_securely.html
---
Full, runnable src of [Using Keys Securely](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/01_using_keys_securely) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-01_using_keys_securely.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/01_using_keys_securely)).

## Intro

The Beem library has two ways to handle your keys.  One is from source code, another one is through command line interface called `beem`.  `beempy` cli is installed by default when you install beem library on your machine.

*Note, the `hive-python` library is out of date, but can be used in a pinch.  For these tutorials, `beem` is recommended.*

## Steps

1. [**App setup**](#app-setup) - Library install and import
1. [**Key usage example**](#example-list) - Example showing how to import keys

#### 1. App setup <a name="app-setup"></a>

In this tutorial we are only using `beem` package - beem library.

```python
  # initialize Hive class
  from beem import Hive

  # defining private keys inside source code is not secure way but possible
  h = Hive(keys=['<private_posting_key>', '<private_active_key>'])
  a = Account('demo', blockchain_instance=h)
```

Last line from above snippet shows how to define private keys for account that's going to transact using script.

#### 2. Key usage example <a name='example-list'></a>

After defining private keys inside Hive class, we can quickly sign any transaction and broadcast it to the network.

```python
  # above will allow accessing Commit methods such as
  # demo account sending 0.001 HIVE to demo1 account

  a.transfer('demo1', '0.001', 'HIVE', memo='memo text')
```

Above method works but it is not secure way of handling your keys because you have entered your keys within source code that you might leak accidentally. To avoid that, we can use CLI - command line interface `beempy`.

You can type following to learn more about `beempy` commands: 

```python
  beempy -h
```

`beempy` lets you leverage your [BIP38](https://bitcoinpaperwallet.com/bip38-password-encrypted-wallets/) encrypted wallet to perform various actions on your accounts.

The first time you use beem, you will be prompted to enter a password. This password will be used to encrypt the beem wallet, which contains your private keys.

You can import your Hive username with following command:

`beempy importaccount username`

Next you can import individual private keys:

`beempy addkey`

That's it, now that your keys are securely stored on your local machine, you can easily sign transaction from any of your Python scripts by using defined keys.

```python
  # if private keys are not defined
  # accessing Wallet methods are also possible and secure way
  h.wallet.getActiveKeyForAccount('demo')
```

Above line fetches private key for user `demo` from local machine and signs transaction.

`beempy` also allows you to sign and broadcast transactions from terminal. For example:

`beempy transfer --account <account_name> <recipient_name> 1 HIVE memo`

would sign and broadcast transfer operation,

`beempy upvote --account <account_name> link`

would sing and broadcast vote operation, etc.

That's it!

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/01_using_keys_securely`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
