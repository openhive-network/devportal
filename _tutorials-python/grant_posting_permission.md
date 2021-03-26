---
title: 'PY: Grant Posting Permission'
position: 30
description: "How to give another user posting permission on your account using Python."
layout: full
canonical_url: grant_posting_permission.html
---
Full, runnable src of [Grant Posting Permission](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/30_grant_posting_permission) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-30_grant_posting_permission.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/30_grant_posting_permission)).

In this tutorial we show you how to check if someone has posting permission for an account on the **Hive** blockchain and how to grant or revoke that permission using the [beem](https://github.com/holgern/beem) library.

Providing another user posting permission for your account can be used to allow multiple users to submit posts on a single hive community.  [Peakd](https://peakd.com) is an example of such a community, as well as others, that allow you to schedule posts by automatically publishing on your behalf.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`allow`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.allow) and [`disallow`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.disallow) methods found within the `Account` instance.  Before we grant or revoke permission, we use the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) module to check whether the requested user already has that permission or not.  This is not strictly necessary but adds to the usability of the process.

The `disallow` method uses the same process except for `weight` which is not required.

There is a permission limit defined by [`HIVE_MAX_AUTHORITY_MEMBERSHIP`]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_MAX_AUTHORITY_MEMBERSHIP' | relative_url }}) that limits the number of authority membership to 40 (max).

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

print('Current posting authorizations: ' + str(account['posting']['account_auths']))

# get account to authorise and check if valid
foreign = input('Please enter the account name for POSTING authorization: ')
if (foreign == account.name):
  print('Cannot allow or disallow posting permission to your own account')
  exit()

foreign = Account(foreign, blockchain_instance=client)
```

#### 3. Check permission status <a name="status"></a>

In order to determine which function to execute (`allow` or `disallow`) we first need to check whether the requested user already has permission or not.  We do this with the same variable created in the previous step.  The `Account` module has a value - `posting` - that contains an array of all the usernames that has been granted posting permission for the account being queried.  We use this check to limit the options of the user as you cannot grant permission to a user that already has permission or revoke permission of a user that does not yet have permission.  The information is displayed on the options list.

```python
# check if foreign account already has posting auth
title = ''

for auth in account['posting']['account_auths']:
  if (auth[0] == foreign.name):
    title = (foreign.name + ' already has posting permission. Please choose option from below list')
    options = ['DISALLOW', 'CANCEL']
    break

if (title == ''):
  title = (foreign.name + ' does not yet posting permission. Please choose option from below list')
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
  account.allow(foreign=foreign.name, weight=1, permission='posting', threshold=1)
  print(foreign.name + ' has been granted posting permission')
else:
  account.disallow(foreign=foreign.name, permission='posting', threshold=1)
  print('posting permission for ' + foreign.name + ' has been removed')
```

### To Run the tutorial

Before running this tutorial, launch your local testnet, with port 8090 mapped locally to the docker container:

```bash
docker run -d -p 8090:8090 inertia/tintoy:latest
```

For details on running a local testnet, see: [Setting Up a Testnet]({{ '/nodeop/setting-up-a-testnet.html' | relative_url }})

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/30_grant_posting_permission`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
