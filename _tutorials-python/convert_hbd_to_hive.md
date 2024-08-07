---
title: titles.convert_hbd_to_hive
position: 32
description: descriptions.convert_hbd_to_hive
layout: full
canonical_url: convert_hbd_to_hive.html
---
Full, runnable src of [Convert HBD To HIVE](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/32_convert_hbd_to_hive) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-32_convert_hbd_to_hive.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/32_convert_hbd_to_hive)).

In this tutorial we will explain and show you how to convert some or all of your available HBD balance into HIVE on the **Hive** blockchain using the `commit` class found within the [beem](https://github.com/holgern/beem) library.

It should be noted that, using this process, the converted HIVE will not be available instantly as it takes 3.5 days for the transaction to be processed.  It is also not possible to stop a conversion once initialized.  During the 3.5 days for it to be converted, if the conversion price fluctuates above the target, you will likely receive much less HIVE than expected.  Because of this, the method in this tutorial is **NOT** the preferred and **often NOT** the most efficient way of converting HBD to HIVE.  This tutorial just illustrates that it can be done in this manner.

Note: **This is not a market process and will often result in unfavorable outcomes, if used bindly.**

<blockquote class="warning">
  There is an internal market on Hive that allows you to sell your HBD.  You should use the internal market for routine trades between HBD and HIVE.  With the market process you can get your HIVE (sometimes immediately) and at the exact price that you expect.  The market place is almost always the better way to exchange your HBD.  <a href="https://hive.blog/hive-148441/@rehan12/quick-guide-to-use-hive-internal-market">This article</a> provides more information on using the market to exchange your HBD for HIVE.
</blockquote>

The purpose of this process is for experts to help maintain the target price of HBD, **not** to provide convenience to the end-user.

## Intro

The Hive python library has built-in functionality to transmit transactions to the blockchain.  We are using the [`convert`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.convert) method found within the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) instance.  Before we do the conversion, we check the current balance of the account to check how much HBD is available.  This is not strictly necessary as the process will automatically abort with the corresponding error, but it does give some insight into the process as a whole.  We use the `Account` module to check for this.  The `convert` method has 2 parameters:

1. _amount_ - The amount of HBD that will be converted
1. _request-id_ - An identifier for tracking the conversion. This parameter is optional

Also see:
* [convert_operation]({{ '/apidefinitions/#broadcast_ops_convert' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information and Hive node**](#userinfo) - Input user information and connection to Hive node
1. [**Check balance**](#balance) - Check current HIVE and HBD balance of user account
1. [**Conversion amount and commit**](#convert) - Input of HBD amount to convert and commit to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we only use 1 package:

- `beem` - hive library and interaction with Blockchain

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
```

Because this tutorial alters the blockchain we connect to the testnet so we don't create spam on the production server.

#### 2. User information and Hive node <a name="userinfo"></a>

We require the `private active key` of the user in order for the conversion to be committed to the blockchain.  This is why we have to specify this alongside the `testnet` node.  The values are supplied via the terminal/console before we initialize the beem class.

```python
# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])
```

#### 3. Check balance <a name="balance"></a>

In order to give the user enough information to make the conversion we check the current balance of the account using the `Account` module.

```python
# get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)
total_hive = account['balance']
total_hbd = account['hbd_balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_hive) + '\n' + str(total_hbd) + '\n')
```

The result of the query is displayed in the console/terminal.

#### 4. Conversion amount and commit <a name="convert"></a>

The final step before we can commit the transaction to the blockchain is to assign the `amount` parameter.  We do this via a simple input from the terminal/console.

```python
# get recipient name
convert_amount = float(input('Enter the amount of HBD to convert to HIVE: ') or '0')

if (convert_amount <= 0):
  print("Must be greater than zero.")
  exit()
```

This value must be greater than zero in order for the transaction to execute without any errors.  Now that we have all the parameters we can do the actual transmission of the transaction to the blockchain.

```python
# parameters: amount, request_id
account.convert(convert_amount)

print('\n' + format(convert_amount, '.3f') + ' HBD has been converted to HIVE')
```

If no errors are encountered a simple confirmation is printed on the UI.

As an added confirmation we check the balance of the user again and display it on the UI.  This is not required at all but it serves as a more definitive confirmation that the conversion has been started correctly.

```python
# get remaining account balance for HIVE and HBD
account.refresh()
total_hive = account['balance']
total_hbd = account['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_hive) + '\n' + str(total_hbd))
```

The HIVE balance will not yet have been updated as it takes 3.5 days to settle.  The HBD will however show the new balance.

Final code:

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)
total_hive = account['balance']
total_hbd = account['hbd_balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_hive) + '\n' + str(total_hbd) + '\n')

# get recipient name
convert_amount = float(input('Enter the amount of HBD to convert to HIVE: ') or '0')

if (convert_amount <= 0):
  print("Must be greater than zero.")
  exit()

# parameters: amount, request_id
account.convert(convert_amount)

print('\n' + format(convert_amount, '.3f') + ' HBD has been converted to HIVE')

# get remaining account balance for HIVE and HBD
account.refresh()
total_hive = account['balance']
total_hbd = account['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_hive) + '\n' + str(total_hbd))

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/32_convert_hbd_to_hive`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
