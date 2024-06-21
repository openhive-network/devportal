---
title: titles.delegate_power
position: 27
description: "How to delegate or remove delegation of HIVE POWER to another user using Python."
layout: full
canonical_url: delegate_power.html
---
Full, runnable src of [Delegate Power](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/27_delegate_power) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-27_delegate_power.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/27_delegate_power)).

In this tutorial we show you how to delegate a portion of an accounts available [HIVE Power <i class="fas fa-search fa-xs" />]({{ '/search?q=HIVE+Power' | relative_url }}) on the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain. We are using the [`delegate_vesting_shares`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.delegate_vesting_shares) method found within the account instance.  When you delegate power you make a portion of your HIVE Power available to another user.  This can empower an application, author, or curator to make higher votes.  Before we do the delegation, we use the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) module to check the current HIVE Power balance of the account to see what is available.  This is not strictly necessary but adds to the usability of the process.  It should be noted that when a delegation is cancelled the HIVE Power will only be available again after 7 days.

Also see:
* [delegate_vesting_shares_operation]({{ '/apidefinitions/#broadcast_ops_delegate_vesting_shares' | relative_url }})
* [get_vesting_delegations]({{ '/apidefinitions/#condenser_api.get_vesting_delegations' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information and Hive node**](#userinfo) - Input user information and connection to Hive node
1. [**Check balance**](#balance) - Check current VESTS balance of user account
1. [**Delegation amount and commit**](#delegate) - Input delegation amount and commit to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use the following packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the `testnet`.

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.amount import Amount
```

Because this tutorial alters the blockchain we connect to a testnet so we don't create spam on the production server.

#### 2. User information and Hive node <a name="userinfo"></a>

We require the `private active key` of the user in order for the transaction to be committed to the blockchain.  This is why we are using a testnet.  The values are supplied via the terminal/console before we initialize the beem class.  We also check if the user name provided is active on the chain.

```python
# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)
```

#### 3. Check balance <a name="balance"></a>

In order to give the user enough information to make the delegation we check the current HIVE Power balance of the account using the `Account` module. We also display a list of currently active delegations should the user choose to remove a delegation.  You can refer to tutorial [Get Delegations by User]({{ '/tutorials-python/get_delegations_by_user.html' | relative_url }}) to see how this is done.

```python
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
```

The available vesting shares to delegate is not directly available from the user information and needs to be calculated.  In order to find the total VESTS available to delegate we need to know how much is currently in power down, how much has been delegated and then the total amount of vesting shares.  The values are assigned from the query directly as `float` type to make the calculations a little simpler.  

```python
# display active delegations (refer to tutorial #29_get_delegations_by_user)
delegations = account.get_vesting_delegations()
if len(delegations) == 0:
  print('No active delegations')
else:
  print('Current delegations:')
  for delegation in delegations:
    delegated_vests = float(delegation['vesting_shares']['amount']) / denom
    delegated_base = (delegated_vests / denom) * base_per_mvest
    print('\t' + delegation['delegatee'] + ': ' + format(delegated_base, '.3f') + ' ' + symbol)

print('\n' + 'Available ' + symbol + ' Power: ' + format(available_base, '.3f') + ' ' + symbol)

input('Press enter to continue' + '\n')
```

The result of the query is displayed in the console/terminal.

#### 4. Delegation amount and commit <a name="delegate"></a>

Both the `amount` and the `delegatee` parameters are assigned via input from the terminal/console.  The user is given the option to delegate power to or remove a currently active delegation from another user. We also check the `delegatee` to make sure it's a valid account name.

```python
# choice of action
title = ('Please choose action')
options = ['DELEGATE POWER', 'UN-DELEGATE POWER', 'CANCEL']
# get index and selected permission choice
option, index = pick(options, title)

if (option == 'CANCEL'):
  print('operation cancelled')
  exit()

# get account to authorise and check if valid
delegatee = input('Please enter the account name to ADD / REMOVE delegation: ')
delegatee = Account(delegatee, blockchain_instance=client)
```

Any amount of HIVE Power delegated to a user will overwrite the amount of HIVE Power currently delegated to that user.  This means that to cancel a delegation we transmit to the blockchain a value of zero.  The inputs and function execution is based on the users choice.

```python
if (option == 'DELEGATE POWER'):
  amount = float(input('Please enter the amount of ' + symbol + ' you would like to delegate: ') or '0')
  amount_vests = (amount * denom) / base_per_mvest

  print(format(amount, '.3f') + ' ' + symbol + ' (' + format(amount_vests, '.6f') + ' ' + vesting_symbol + ') will be delegated to ' + delegatee.name)
else:
  amount_vests = 0
  print('Removing delegated VESTS from ' + delegatee.name)

account.delegate_vesting_shares(delegatee.name, amount_vests)

print('Success.')
```

Note that if the user decides to delegate a specific amount, we capture the amount they intend to delegate as HIVE Power, then convert that amount to VESTS behind the scenes, in keeping with the principle of only interacting with the end user in terms of HIVE Power, which is the recommended best practice.

A confirmation of the transaction is displayed on the UI.

Final code:

```python
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

# check valid user
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

# display active delegations (refer to tutorial #29_get_delegations_by_user)
delegations = account.get_vesting_delegations()
if len(delegations) == 0:
  print('No active delegations')
else:
  print('Current delegations:')
  for delegation in delegations:
    delegated_vests = float(delegation['vesting_shares']['amount']) / denom
    delegated_base = (delegated_vests / denom) * base_per_mvest
    print('\t' + delegation['delegatee'] + ': ' + format(delegated_base, '.3f') + ' ' + symbol)

print('\n' + 'Available ' + symbol + ' Power: ' + format(available_base, '.3f') + ' ' + symbol)

input('Press enter to continue' + '\n')

# choice of action
title = ('Please choose action')
options = ['DELEGATE POWER', 'UN-DELEGATE POWER', 'CANCEL']
# get index and selected permission choice
option, index = pick(options, title)

if (option == 'CANCEL'):
  print('operation cancelled')
  exit()

# get account to authorise and check if valid
delegatee = input('Please enter the account name to ADD / REMOVE delegation: ')
delegatee = Account(delegatee, blockchain_instance=client)

if (option == 'DELEGATE POWER'):
  amount = float(input('Please enter the amount of ' + symbol + ' you would like to delegate: ') or '0')
  amount_vests = (amount * denom) / base_per_mvest
  
  print(format(amount, '.3f') + ' ' + symbol + ' (' + format(amount_vests, '.6f') + ' ' + vesting_symbol + ') will be delegated to ' + delegatee.name)
else:
  amount_vests = 0
  print('Removing delegated VESTS from ' + delegatee.name)

account.delegate_vesting_shares(delegatee.name, amount_vests)

print('Success.')

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/27_delegate_power`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
