---
title: 'PY: Transfer HIVE And HBD'
position: 21
description: "How to transfer HIVE and HBD to another account using Python."
layout: full
canonical_url: transfer_hive_and_hbd.html
---
Full, runnable src of [Transfer HIVE And HBD](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/21_transfer_hive_and_hbd) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-21_transfer_hive_and_hbd.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/21_transfer_hive_and_hbd)).

In this tutorial we will explain and show you how to to check the HIVE and HBD balance of an account and also how to transfer a portion of that to another user on the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the `transfer` method found within the account instance. Before we do the transfer, we check the current balance of the account to ensure that there are sufficient funds available.  We also check if the intended recipient of the transfer is a valid user account.  This is not strictly necessary as the process will automatically abort with the corresponding error, but it does give some insight into the process as a whole.  We use the account lookup function to check for this.  We are using the following [`transfer`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.transfer) parameters:

1. _to_ - The intended recipient of the funds transfer
1. _amount_ - The amount of HIVE or HBD that the user wants to transfer. This parameter has to be of the `float` data type and is rounded up to 3 decimal spaces
1. _asset_ - A string value specifying whether `HIVE` or `HBD` is being transferred
1. _memo_ - An optional text field containing comments on the transfer. This value may begin with '#' for encrypted messaging

Also see:
* [transfer_operation]({{ '/apidefinitions/#broadcast_ops_transfer' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information and hive node**](#userinfo) - Input user information and connection to Hive node
1. [**Check balance**](#balance) - Check current HIVE and HBD balance of user account
1. [**Recipient input**](#recipient) - Check for valid recipient account name
1. [**Transfer type and amount**](#amount) - Input of transfer type and the amount to transfer
1. [**Transfer**](#transfer) - Broadcast the transfer to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use 2 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the `testnet`.

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
```

Because this tutorial alters the blockchain we connect to the testnet so we don't create spam on the production server.

#### 2. User information and hive node <a name="userinfo"></a>

We require the `private active key` of the user in order for the transfer to be broadcasted to the blockchain.  This is why we have to specify this alongside the `testnet` node.  The values are supplied via the terminal/console before we initialize the beem class.

```python
# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Active Key: ')

# connect node and private active key
client = Hive('http://127.0.0.1:8090', keys=[wif_active_key])
```

#### 3. Check balance <a name="balance"></a>

In order to give the user enough information to make the transfer we check the current balance of the account using [account lookup](https://beem.readthedocs.io/en/latest/beem.account.html#module-beem.account).

```python
# get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)
total_base = account['balance']
total_debt = account['hbd_balance']
base_symbol = total_base.symbol
debt_symbol = total_debt.symbol

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
```

The result of the query is displayed in the console/terminal.

#### 4. Recipient input <a name="recipient"></a>

The recipient account is input via the console/terminal and then a check is done whether that username does in fact exist.

```python
# get recipient name
recipient = input('Enter the user you wish to transfer funds to: ')

# check for valid recipient name
recipient = Account(recipient, blockchain_instance=client)
```

The query will return a null value if the account does not match to anything on the blockchain. This result is then used to determine the next step.

#### 5. Transfer type and amount <a name="amount"></a>

If the query in the previous step returns a valid result the user is then given a choice of transfer types or to cancel the operation completely. If the username is not found the process aborts.

```python
if recipient:
    # choice of transfer
    title = 'Please choose transfer type: '
    options = [base_symbol, debt_symbol, 'Cancel Transfer']
    # get index and selected transfer type
    option, index = pick(options, title)
else:
    print('Invalid recipient for funds transfer')
    exit()
```

Once the user chooses the type of transfer we proceed to assign the amount as well as the `asset` parameter.

```python
if option == 'Cancel Transfer':
    print('Transaction cancelled')
    exit()

if option == base_symbol:
  # get HIVE transfer amount
  amount = input('Enter amount of ' + base_symbol + ' to transfer to ' + recipient.name + ': ')
  amount = float(amount)
  symbol = base_symbol
else:
  # get HBD transfer amount
  amount = input('Enter amount of ' + debt_symbol + ' to transfer to ' + recipient.name + ': ')
  amount = float(amount)
  symbol = debt_symbol
```

#### 6. Transfer <a name="transfer"></a>

Once all the parameters have been assigned we can proceed with the actual broadcast to the blockchain.

```python
account.transfer(recipient.name, amount, symbol)

print('\n' + str(amount) + ' ' + symbol + ' has been transferred to ' + recipient.name)
```

The `memo` parameter can be left empty as in the above example.  A simple confirmation is printed on the UI.

As an added confirmation we check the balance of the user again and display it on the UI.  This is not required at all but it serves as a more definitive confirmation that the transfer has been completed correctly.

```python
# get remaining account balance for HIVE and HBD
account = Account(account.name, blockchain_instance=client)
total_base = account['balance']
total_debt = account['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
```

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/21_transfer_hive_and_hbd`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
