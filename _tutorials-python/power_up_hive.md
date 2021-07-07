---
title: 'PY: Power Up Hive'
position: 24
description: "How to power up your HIVE to HIVE Power using Python."
layout: full
canonical_url: power_up_hive.html
---
Full, runnable src of [Power Up Hive](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/24_power_up_hive) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-24_power_up_hive.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/24_power_up_hive)).

In this tutorial we show you how to check the HIVE balance of an account on the **Hive** blockchain and how to power up your HIVE into [HIVE Power <i class="fas fa-search fa-xs" />]({{ '/search?q=HIVE+Power' | relative_url }}) using the `commit` class found within the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`transfer_to_vesting`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.transfer_to_vesting) method found within the account instance.  When you power up you convert your HIVE into HIVE Power to increase your influence on Hive.  Before we do the conversion, we use the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) function to check the current HIVE balance of the account to see what is available to power up. This is not strictly necessary but adds to the usability of the process. The `transfer_to_vesting` method has 2 parameters:

1. _amount_ - The amount of HIVE to power up. This must be of the `float` data type
1. _to_ - The account to where the HIVE will be powered up

Also see:
* [transfer_to_vesting_operation]({{ '/apidefinitions/#broadcast_ops_transfer_to_vesting' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information and Hive node**](#userinfo) - Input user information and connection to Hive node
1. [**Check balance**](#balance) - Check current vesting balance of user account
1. [**Conversion amount**](#convert) - Input power up amount and check valid transfer
1. [**Commit to blockchain**](#commit) - Commit transaction to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use 2 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the `testnet`.

```python
import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
```

Because this tutorial alters the blockchain we connect to a testnet so we don't create spam on the production server.

#### 2. User information and Hive node <a name="userinfo"></a>

We require the `private active key` of the user in order for the conversion to be committed to the blockchain.  This is why we are using a testnet.  The values are supplied via the terminal/console before we initialize the beem class.

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

In order to give the user enough information to make the conversion we check the current balance of the account using the `Account` instance.

```python
# check valid user and get account balance
account = Account(account, blockchain_instance=client)
balance = account['balance']
symbol = balance.symbol

print('Available balance: ' + str(balance) + '\n')

input('Press any key to continue')
```

The results of the query are displayed in the console/terminal.

#### 4. Conversion amount <a name="convert"></a>

Both the `amount` and the `to` parameters are assigned via input from the terminal/console.  The user is given the option to power up the HIVE to their own account or to another user's account.  The amount has to be greater than zero and no more than the total available HIVE of the user.

```python
# choice of account
title = 'Please choose an option for an account to power up: '
options = ['SELF', 'OTHER']
# get index and selected transfer type
option, index = pick(options, title)

if (option == 'OTHER') :
  # account to power up to
  to_account = input('Please enter the ACCOUNT to where the ' + symbol + ' will be powered up: ')
  to_account = Account(to_account, blockchain_instance=client)
else :
  print('\n' + 'Power up ' + symbol + ' to own account' + '\n')
  to_account = account

# amount to power up
amount = float(input('Please enter the amount of ' + symbol + ' to power up: ') or '0')
```

#### 5. Commit to blockchain <a name="commit"></a>

Now that all the parameters have been assigned we can continue with the actual transmission to the blockchain.  The output and commit is based on the validity of the amount that has been input.

```python
# parameters: amount, to, account
if (amount == 0) :
  print('\n' + 'No ' + symbol + ' entered for powering up')
  exit()

if (amount > balance) :
  print('\n' + 'Insufficient funds available')
  exit()

account.transfer_to_vesting(amount, to_account.name)
print('\n' + str(amount) + ' ' + symbol + ' has been powered up successfully to ' + to_account.name)
```

The result of the power up transfer is displayed on the console/terminal.

As an added check we also display the new HIVE balance of the user on the terminal/console.

```python
# get new account balance
account.refresh()
balance = account['balance']
print('New balance: ' + str(balance))
```

---

#### Try it

Click the play button below:

<iframe height="400px" width="100%" src="https://replit.com/@inertia186/py24poweruphive?embed=1&output=1" scrolling="no" frameborder="no" allowtransparency="true" allowfullscreen="true" sandbox="allow-forms allow-pointer-lock allow-popups allow-same-origin allow-scripts allow-modals"></iframe>

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/24_power_up_hive`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
