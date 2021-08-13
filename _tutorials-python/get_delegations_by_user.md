---
title: 'PY: Get Delegations By User'
position: 29
description: "How to get a list of active or expiring vesting delegations using Python."
layout: full
canonical_url: get_delegations_by_user.html
---
Full, runnable src of [Get Delegations By User](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/29_get_delegations_by_user) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-29_get_delegations_by_user.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/29_get_delegations_by_user)).

In this tutorial we will explain and show you how to pull a list of both active and expiring vesting delegations from the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

The Hive python library has a built-in function to pull information from the blockchain. We are using the [`get_vesting_delegations`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.get_vesting_delegations) and [`get_expiring_vesting_delegations`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.get_expiring_vesting_delegations) methods.  Each of these functions are executed separately.  It should be noted that when a delegation is cancelled the VESTS will only be available again after 7 days.  The value of the delegation can also be changed at any time, either decreased or increased.

The function to query the expiring delegations use the the same parameters except that the `start_account` is replaced by a `start_date`.  If this value is greater than 7 days from present, it will always include all delegations that are pending expiration.

Also see:
* [condenser_api.get_vesting_delegations]({{ '/apidefinitions/#condenser_api.get_vesting_delegations' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to production
1. [**User input**](#input) - Input user and limit parameters
1. [**Delegation lists**](#query) - Selection of the type of list and blockchain query

#### 1. App setup <a name="setup"></a>

In this tutorial we use 2 package:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the mainnet, for this tutorial.

```python
from pick import pick
from beem import Hive
from beem.account import Account
from beem.amount import Amount

client = Hive()
```

#### 2. User input <a name="input"></a>

The `account` and `limit` parameters are assigned via input from the console/terminal. We also check if the username provided does in fact exist on the blockchain using the `Account` module. This will return an null value if the name does not exist.

```python
# capture username
account = input('Username: ')
account = Account(account)

balance = account['balance']
symbol = balance.symbol

# we need high precision because VESTS
denom = 1e6
dgpo = client.get_dynamic_global_properties()
total_vesting_fund_hive = Amount(dgpo['total_vesting_fund_hive']).amount
total_vesting_shares_mvest = Amount(dgpo['total_vesting_shares']).amount / denom
base_per_mvest = total_vesting_fund_hive / total_vesting_shares_mvest
```

This block will help us convert VESTS to HIVE Power for display purposes.  Best practice is to always allow the end-user to work with HIVE Power, not raw VESTS.

```python
# capture list limit
limit = input('Max number of vesting delegations to display: ') or '10'
```

#### 3. Delegation lists <a name="query"></a>

We use two different functions to query active and expiring delegations, so the user is given a choice on which of these lists he wants to view.

```python
# list type
title = 'Please choose the type of list: '
options = ['Active Vesting Delegations', 'Expiring Vesting Delegations']

# get index and selected list name
option, index = pick(options, title)
print('\n' + 'List of ' + option + ': ' + '\n')
```

Based on the result of the choice, the relevant blockchain query is executed and the result of the query displayed on the console/terminal.

```python
if option=='Active Vesting Delegations' :
  delegations = account.get_vesting_delegations(limit=limit)
else:
  delegations = account.get_expiring_vesting_delegations("2018-01-01T00:00:00", limit=limit)

if len(delegations) == 0:
  print('No ' + option)
  exit

for delegation in delegations:
  delegated_vests = float(delegation['vesting_shares']['amount']) / denom
  delegated_base = (delegated_vests / denom) * base_per_mvest
  print('\t' + delegation['delegatee'] + ': ' + format(delegated_base, '.3f') + ' ' + symbol)
```

For both the queries the starting points were defined in such a way as to include all available data but this can be changed depending on the user requirements.

Note that we output the delegated amounts as HIVE Power, in keeping with the principle of only interacting with the end user in terms of HIVE Power, which is the recommended best practice.

---

#### Try it

Click the play button below:

<iframe height="400px" width="100%" src="https://replit.com/@inertia186/py29getdelegationsbyuser?embed=1&output=1" scrolling="no" frameborder="no" allowtransparency="true" allowfullscreen="true" sandbox="allow-forms allow-pointer-lock allow-popups allow-same-origin allow-scripts allow-modals"></iframe>

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/29_get_delegations_by_user`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
