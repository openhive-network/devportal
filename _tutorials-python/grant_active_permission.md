---
title: 'PY: Grant Active Permission'
position: 31
description: "How to give another user active permission on your account using Python."
layout: full
canonical_url: grant_active_permission.html
---
Full, runnable src of [Grant Active Permission](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/31_grant_active_permission) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-31_grant_active_permission.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/31_grant_active_permission)).

In this tutorial we show you how to check if someone has got active permission for an account on the **Hive** blockchain and how to grant or revoke that permission using the [beem](https://github.com/holgern/beem) library.

Providing another user active permission for your account enables them to do fund transfers from your account.  This can be useful in setting up a secondary account(s) to manage funds for a main account or having a backup should you lose passwords for the main account.

One of the common practice nowadays is to lend/delegate HP to another account, above same technique can be used to create market around it with minimum 3rd party trust.  All your funds stay in your account.  You can use/create automated system where you can lease for certain period of time and system can take care of payments and release of delegations (notify clients).  Even better, you can use [multi-signature <i class="fas fa-search fa-xs" />]({{ '/search?q=multisig' | relative_url }})  feature to establish 100% trust where clients will have to confirm, approve transactions.

Active permissions and authority should be used with utmost care, you don't want to lose your funds.  It is really not easy to hack Hive accounts, let alone take control over it.  But without careful use (revealing private keys) losing liquid funds are not that difficult and it takes only couple seconds to do that, keeping most value powered up always helps.

See [this article](https://hive.blog/@good-karma/steem-multi-authority-permissions-and-how-active-authority-works-part-2-f158813ec0ec1) for more detail around active authorities.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`allow`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.allow) and [`disallow`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.disallow) methods found within the `Account` instance.  Before we grant or revoke permission, we use the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) module to check whether the requested user already has that permission or not.  This is not strictly necessary but adds to the usability of the process.

The `disallow` method uses the same parameters except for `weight` which is not required.

There is currently a bug with the `disallow` method when using it on the testnet that we normally connect to. Due to that bug, we are using the production server for this tutorial. Special care should be taken when creating transactions as everything we do will affect `real` accounts.

There is a permission limit defined by [`HIVE_MAX_AUTHORITY_MEMBERSHIP`]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_MAX_AUTHORITY_MEMBERSHIP' | relative_url }}) that limits the number of authority membership to 40 (max).

Also see:
* [account_update_operation]({{ '/apidefinitions/#broadcast_ops_account_update' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Input user info and connection to production
1. [**Username validation**](#username) - Check validity of user and foreign account
1. [**Check permission status**](#status) - Check current permission status of foreign account
1. [**Commit to blockchain**](#commit) - Commit transaction to blockchain

#### 1. App setup and connection <a name="setup"></a>

In this tutorial we use 2 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries for the application.

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
```

We require the `private active key` of the user in order for the `allow` or `disallow` to be committed to the blockchain.  The values are supplied via the terminal/console before we initialize the beem class with the supplied private key included.

```python
# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# connect to production server with active key
client = Hive('http://127.0.0.1:8090', keys=[wif_active_key])
```

#### 2. Username validation <a name="username"></a>

Both the main account granting the permission and the account that permission is being granted to are first checked to make certain that they do in fact exist.  We do this with the `Account` module.

```python
# check valid user
account = Account(account, blockchain_instance=client)

print('Current active authorizations: ' + str(account['active']['account_auths']))

# get account to authorise and check if valid
foreign = input('Please enter the account name for ACTIVE authorization: ')
if (foreign == account.name):
  print('Cannot allow or disallow active permission to your own account')
  exit()

foreign = Account(foreign, blockchain_instance=client)
```

#### 3. Check permission status <a name="status"></a>

In order to determine which function to execute (`allow` or `disallow`) we first need to check whether the requested user already has permission or not.  We do this with the same variable created in the previous step.  The `Account` module has a value - `active` - that contains an array of all the usernames that has been granted posting permission for the account being queried.  We use this check to limit the options of the user as you cannot grant permission to a user that already has permission or revoke permission of a user that does not yet have permission.  The information is displayed on the options list.

```python
# check if foreign account already has active auth
title = ''

for auth in account['active']['account_auths']:
  if (auth[0] == foreign.name):
    title = (foreign.name + ' already has active permission. Please choose option from below list')
    options = ['DISALLOW', 'CANCEL']
    break

if (title == ''):
  title = (foreign.name + ' does not yet active permission. Please choose option from below list')
  options = ['ALLOW', 'CANCEL']
```

#### 4. Commit to blockchain <a name="commit"></a>

Based on the check in the previous step, the user is given the option to `allow`, `disallow` or `cancel` the operation completely.  All the required parameters have already been assigned via console/terminal input and based on the choice of the user the relevant function can be executed.  A confirmation of the successfully executed action is displayed on the UI.

```python
option, index = pick(options, title)

if (option == 'CANCEL'):
  print('operation cancelled')
  exit()

if (option == 'ALLOW'):
  account.allow(foreign=foreign.name, weight=1, permission='active', threshold=1)
  print(foreign.name + ' has been granted active permission')
else:
  account.disallow(foreign=foreign.name, permission='active', threshold=1)
  print('active permission for ' + foreign.name + ' has been removed')
```

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/31_grant_active_permission`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
