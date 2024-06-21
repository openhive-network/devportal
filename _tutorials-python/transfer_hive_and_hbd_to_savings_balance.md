---
title: 'PY: Transfer HIVE And HBD To Savings Balance'
position: 33
description: "How to transfer HIVE and HBD to savings using Python."
layout: full
canonical_url: transfer_hive_and_hbd_to_savings_balance.html
---
Full, runnable src of [Transfer HIVE And HBD To Savings Balance](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/33_transfer_hive_and_hbd_to_savings_balance) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-33_transfer_hive_and_hbd_to_savings_balance.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/33_transfer_hive_and_hbd_to_savings_balance)).

In this tutorial we show you how to check the HIVE and HBD balance of an account on the **Hive** blockchain and also how to transfer a portion or all of that to a "savings" account using the [beem](https://github.com/holgern/beem) library.

It should be noted that when funds are being withdrawn from the savings account it takes 3 days for those funds to reflect in the available HIVE/HBD balance.  The withdrawal can be cancelled at any point during this waiting period.  This measure was put in place to reduce the risk of funds being stolen when accounts are hacked as it gives sufficient time to recover your account before your funds are transferred out.  Storing your funds in your savings account is thus more secure than having them as available balances.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`transfer_to_savings`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.transfer_to_savings) and [`transfer_from_savings`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.transfer_from_savings) methods found within the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) instance.  Before we do the transfer, we use the `Account` module to check the current HIVE and HBD balance of the account to see what funds are available to transfer or withdraw.  This is not strictly necessary but adds to the usability of the process.  The `transfer_to_savings` method has the following parameters:

1.  _amount_ - The amount of HIVE or HBD that the user wants to transfer. This parameter has to be of the `float` data type and is rounded up to 3 decimal spaces
1.  _asset_ - A string value specifying whether `HIVE` or `HBD` is being transferred
1.  _memo_ - An optional text field containing comments on the transfer

and `transfer_from_savings` has the following parameters:

1.  _amount_ - The amount of HIVE or HBD that the user wants to withdraw. This parameter has to be of the `float` data type and is rounded up to 3 decimal spaces
1.  _asset_ - A string value specifying whether `HIVE` or `HBD` is being withdrawn
1.  _memo_ - An optional text field containing comments on the withdrawal
1.  _request id_ - Integer identifier for tracking the withdrawal. This needs to be a unique number for a specified user

Also see:
* [transfer_to_savings_operation]({{ '/apidefinitions/#broadcast_ops_transfer_to_savings' | relative_url }})
* [transfer_from_savings_operation]({{ '/apidefinitions/#broadcast_ops_transfer_from_savings' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information and Hive node**](#userinfo) - Input user information and connection to Hive node
1. [**Check balance**](#balance) - Check current HIVE and HBD balance of user account
1. [**Transfer type and amount**](#amount) - Input of transfer type and the amount to transfer
1. [**Transfer commit**](#commit) - Commit of transfer to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use 3 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively
- `random` - use to create random numbers

We import the libraries and connect to the `testnet`.

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
import random
```

Because this tutorial alters the blockchain we connect to a testnet so we don't create spam on the production server.

#### 2. User information and Hive node <a name="userinfo"></a>

We require the `private active key` of the user in order for the transfer to be committed to the blockchain.  This is why we are using a testnet.  The values are supplied via the terminal/console before we initialise the beem class.

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

In order to give the user enough information to make the transfer we check the current balance of both the available and savings funds of the account using the `Account` module.

```python
# check for valid account and get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)

total_base = account['balance']
total_debt = account['hbd_balance']
savings_base = account['savings_balance']
savings_debt = account['savings_hbd_balance']

symbol_base = total_base.symbol
symbol_debt = total_debt.symbol

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
print('CURRENT SAVINGS BALANCE:' + '\n' + str(savings_base) + '\n' + str(savings_debt) + '\n')

input('Press enter to continue with the transfer' + '\n')
```

The result of the query is displayed in the console/terminal.

#### 4. Transfer type and amount <a name="amount"></a>

The user is given a choice on the type of transfer (transfer/withdraw) as well as the currency.  The user can also elect to cancel the process entirely.  Once the user makes their choice we proceed to assign the `amount` as well as the `asset` parameter.

```python
# choice of currency
title2 = 'Please choose currency: '
options2 = [symbol_base, symbol_debt]
# get index and selected currency
asset, index = pick(options2, title2)

if asset == symbol_base:
  # get HIVE transfer amount
  amount = float(input('Enter amount of ' + symbol_base + ' to transfer: ') or '0')
else:
  # get HBD transfer amount
  amount = float(input('Enter amount of ' + symbol_debt + ' to transfer: ') or '0')
```

#### 5. Transfer commit <a name="commit"></a>

Once all the parameters have been assigned we can proceed with the actual broadcast to the blockchain.  The relevant function is executed based on the selected choice the user made in the previous step.

```python
if transfer_type == 'Transfer':
  account.transfer_to_savings(amount, asset, '')
  print('\n' + 'Transfer to savings balance successful')
else:
  # create request ID random integer
  request_id = random.randint(1,1000000)
  account.transfer_from_savings(amount, asset, '', request_id=request_id)
  print('\n' + 'Withdrawal from savings successful, transaction ID: ' + str(request_id))
```

With a withdrawal, the method requires a unique identifier for the transaction to be completed.  For this we create a random integer and also display it on the UI along with the result of the transaction.  The `memo` parameter is optional and can be left empty as in the above example.  A simple confirmation of the transfer is printed on the UI.

As an added confirmation we check the balance of the user again and display it on the UI.  This is not required at all but it serves as a more definitive confirmation that the transfer has been completed correctly.

```python
# get remaining account balance for HIVE and HBD
account.refresh()
total_base = account['balance']
total_debt = account['hbd_balance']
savings_base = account['savings_balance']
savings_debt = account['savings_hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
print('CURRENT SAVINGS BALANCE:' + '\n' + str(savings_base) + '\n' + str(savings_debt) + '\n')
```

Final code:

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
import random

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# check for valid account and get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)

total_base = account['balance']
total_debt = account['hbd_balance']
savings_base = account['savings_balance']
savings_debt = account['savings_hbd_balance']

symbol_base = total_base.symbol
symbol_debt = total_debt.symbol

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
print('CURRENT SAVINGS BALANCE:' + '\n' + str(savings_base) + '\n' + str(savings_debt) + '\n')

input('Press enter to continue with the transfer' + '\n')

# choice of transfer/withdrawal
title1 = 'Please choose transfer type: '
options1 = ['Transfer', 'Withdrawal', 'Cancel']
# get index and selected transfer type
transfer_type, index = pick(options1, title1)

if transfer_type == 'Cancel':
  print('Transaction cancelled')
  exit()

# choice of currency
title2 = 'Please choose currency: '
options2 = [symbol_base, symbol_debt]
# get index and selected currency
asset, index = pick(options2, title2)

if asset == symbol_base:
  # get HIVE transfer amount
  amount = float(input('Enter amount of ' + symbol_base + ' to transfer: ') or '0')
else:
  # get HBD transfer amount
  amount = float(input('Enter amount of ' + symbol_debt + ' to transfer: ') or '0')

if transfer_type == 'Transfer':
  account.transfer_to_savings(amount, asset, '')
  print('\n' + 'Transfer to savings balance successful')
else:
  # create request ID random integer
  request_id = random.randint(1,1000000)
  account.transfer_from_savings(amount, asset, '', request_id=request_id)
  print('\n' + 'Withdrawal from savings successful, transaction ID: ' + str(request_id))

# get remaining account balance for HIVE and HBD
account.refresh()
total_base = account['balance']
total_debt = account['hbd_balance']
savings_base = account['savings_balance']
savings_debt = account['savings_hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
print('CURRENT SAVINGS BALANCE:' + '\n' + str(savings_base) + '\n' + str(savings_debt) + '\n')

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/33_transfer_hive_and_hbd_to_savings_balance`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
