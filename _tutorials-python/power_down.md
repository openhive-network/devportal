---
title: 'PY: Power Down'
position: 25
description: "How to power down (withdraw) your vesting shares using Python."
layout: full
canonical_url: power_down.html
---
Full, runnable src of [Power Down](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/25_power_down) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-25_power_down.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/25_power_down)).

In this tutorial we will explain and show you how to power down some or all of your available [HIVE Power <i class="fas fa-search fa-xs" />]({{ '/search?q=HIVE+Power' | relative_url }}) on the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`withdraw_vesting`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.withdraw_vesting) method found within the account instance.  When you power down, the converted VESTS (HIVE Power) will not be available as HIVE immediately.  It is converted in 13 equal parts and transferred into your HIVE wallet weekly, the first portion only being available a week after the power down was initiated.  Before we do the conversion, we check the current balance of the account to check how much HIVE Power is available.  This is not strictly necessary as the process will automatically abort with the corresponding error, but it does give some insight into the process as a whole. We use the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) module to check for this.

Also see:
* [withdraw_vesting_operation]({{ '/apidefinitions/#broadcast_ops_withdraw_vesting' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information and Hive node**](#userinfo) - Input user information and connection to Hive node
1. [**Check balance**](#balance) - Check current vesting balance of user account
1. [**Conversion amount and commit**](#convert) - Input of VESTS amount to convert and commit to blockchain

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
from beem.amount import Amount
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
# get account balance for vesting shares
account = Account(account, blockchain_instance=client)
balance = account['balance']
symbol = balance.symbol

# we need high precision because VESTS
denom = 1e6
delegated_vests = account['delegated_vesting_shares']
vesting_shares = account['vesting_shares']
vesting_symbol = vesting_shares.symbol
to_withdraw_vests = float(account['to_withdraw']) / denom
withdrawn_vests = float(account['withdrawn']) / denom
```

Here, we are gathering the current account details.

```python
dgpo = client.get_dynamic_global_properties()
total_vesting_fund_hive = Amount(dgpo['total_vesting_fund_hive']).amount
total_vesting_shares_mvest = Amount(dgpo['total_vesting_shares']).amount / denom
base_per_mvest = total_vesting_fund_hive / total_vesting_shares_mvest
```

This block will help us convert VESTS to HIVE Power for display purposes.  Best practice is to always allow the end-user to work with HIVE Power, not raw VESTS.

```python
available_vests = (vesting_shares.amount - delegated_vests.amount - ((to_withdraw_vests - withdrawn_vests)))
available_base = (available_vests / denom) * base_per_mvest
powering_down = ((to_withdraw_vests - withdrawn_vests) / denom) * base_per_mvest
```

The available vesting shares to withdraw is not directly available from the user information and needs to be calculated.  In order to find the total VESTS available to power down we need to know how much is currently in power down, how much has been delegated and then the total amount of vesting shares.  The values are assigned from the query directly as `float` type to make the calculations a little simpler.  

```python
print(symbol + ' Power currently powering down: ' + format(powering_down, '.3f') + ' ' + symbol +
  '\n' + 'Available ' + symbol + ' Power: ' + format(available_base, '.3f') + ' ' + symbol)

input('\n' + 'Press enter to continue' + '\n')
```

The results of the query and calculation are converted to `string` type and displayed in the console/terminal.

#### 4. Conversion amount and commit <a name="convert"></a>

The user is given the option to withdraw all available vesting shares, a portion of the shares or to cancel the transaction completely.

```python
# choice of transfer
title = 'Please choose an option: '
options = ['Power down ALL', 'Power down PORTION', 'Cancel Transaction']
# get index and selected transfer type
option, index = pick(options, title)
```

Based on the input from the user the `amount` variable can be assigned and the transaction is broadcasted to the blockchain.  The amount must be between zero and the total amount of vesting shares (both pending conversion and available VESTS combined).  **The amount you set to be withdrawn will override the current amount of vesting shares pending withdrawal.**  If for example the user enters a new amount of `'0'` shares to be withdrawn, it will cancel the current withdrawal completely.

Note that if the user decides to power down only a portion, we capture the amount they intend to power down as HIVE Power, then convert that amount to VESTS behind the scenes, in keeping with the principle of only interacting with the end user in terms of HIVE Power, which is the recommended best practice.

```python
# parameters: amount, account
if (option == 'Cancel Transaction'):
  print('transaction cancelled')
  exit()

if (option == 'Power down ALL'):
  if (available_vests == 0):
    print('No change to withdraw amount')
    exit()
  amount_vests = to_withdraw_vests + available_vests
  amount = (amount_vests / denom) * base_per_mvest
else:
  amount = float(input('Please enter the amount of ' + symbol + ' you would like to power down: ') or '0')
  amount_vests = (amount * denom) / base_per_mvest

if (amount_vests <= (to_withdraw_vests + available_vests)):
  account.withdraw_vesting(amount_vests)
  print(format(amount, '.3f') + ' ' + symbol + ' (' + format(amount_vests, '.6f') + ' ' + vesting_symbol + ') now powering down')
  exit()

if (amount_vests == to_withdraw_vests):
  print('No change to withdraw amount')
  exit()

print('Insufficient funds available')
```

The result is displayed on the console/terminal.

Final code:

```python
import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.amount import Amount

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# get account balance for vesting shares
account = Account(account, blockchain_instance=client)
balance = account['balance']
symbol = balance.symbol

# we need high precision because VESTS
denom = 1e6
delegated_vests = account['delegated_vesting_shares']
vesting_shares = account['vesting_shares']
vesting_symbol = vesting_shares.symbol
to_withdraw_vests = float(account['to_withdraw']) / denom
withdrawn_vests = float(account['withdrawn']) / denom

dgpo = client.get_dynamic_global_properties()
total_vesting_fund_hive = Amount(dgpo['total_vesting_fund_hive']).amount
total_vesting_shares_mvest = Amount(dgpo['total_vesting_shares']).amount / denom
base_per_mvest = total_vesting_fund_hive / total_vesting_shares_mvest
available_vests = (vesting_shares.amount - delegated_vests.amount - ((to_withdraw_vests - withdrawn_vests)))
available_base = (available_vests / denom) * base_per_mvest
powering_down = ((to_withdraw_vests - withdrawn_vests) / denom) * base_per_mvest

print(symbol + ' Power currently powering down: ' + format(powering_down, '.3f') + ' ' + symbol +
  '\n' + 'Available ' + symbol + ' Power: ' + format(available_base, '.3f') + ' ' + symbol)

input('\n' + 'Press enter to continue' + '\n')

# choice of transfer
title = 'Please choose an option: '
options = ['Power down ALL', 'Power down PORTION', 'Cancel Transaction']
# get index and selected transfer type
option, index = pick(options, title)

# parameters: amount, account
if (option == 'Cancel Transaction'):
  print('transaction cancelled')
  exit()

if (option == 'Power down ALL'):
  if (available_vests == 0):
    print('No change to withdraw amount')
    exit()
  amount_vests = to_withdraw_vests + available_vests
  amount = (amount_vests / denom) * base_per_mvest
else:
  amount = float(input('Please enter the amount of ' + symbol + ' you would like to power down: ') or '0')
  amount_vests = (amount * denom) / base_per_mvest

if (amount_vests <= (to_withdraw_vests + available_vests)):
  account.withdraw_vesting(amount_vests)
  print(format(amount, '.3f') + ' ' + symbol + ' (' + format(amount_vests, '.6f') + ' ' + vesting_symbol + ') now powering down')
  exit()

if (amount_vests == to_withdraw_vests):
  print('No change to withdraw amount')
  exit()

print('Insufficient funds available')

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/25_power_down`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
