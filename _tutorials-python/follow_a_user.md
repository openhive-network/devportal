---
title: 'PY: Follow A User'
position: 18
description: "How to follow or unfollow an author using Python."
layout: full
canonical_url: follow_a_user.html
---
Full, runnable src of [Follow A User](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/18_follow_a_user) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-18_follow_a_user.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/18_follow_a_user)).

In this tutorial we will explain and show you how to follow or unfollow any author on the **Hive** blockchain using the tools found within the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are going to use the "follow" and "unfollow" custom json operations.  Before we can follow/unfollow we first have to check what the current 'follow status' is of the author, using [`get_following`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.get_following) on an account.  There are three pieces of information within the `follow/unfollow` operation:

1. _follow/unfollow_ - The name of the author that will be followed/unfollowed
1. _what_ - The list of states to be followed.  Valid states are `["blog"]`, `["ignore"]`, and `[]` (empty to clear a previous state)
1. _account_ - The name of the account that is executing the follow/unfollow

## Steps

1.  [**App setup**](#setup) - Library install and import. Connection to testnet
1.  [**User information**](#userinfo) - Input user information and connection to Hive node
1.  [**Check author status**](#authorstat) - Validity check on requested autor to follow
1.  [**Follow status**](#followstat) - Check whether specified author is already followed
1.  [**Follow/Unfollow Broadcast**](#broadcast) - Broadcast the follow/unfollow operation

#### 1. App setup <a name="setup"></a>

In this tutorial we use the follow packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the `testnet`.

```python
import getpass
import json
from pick import pick
import beem
from beem.account import Account
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Custom_json
```

Because this tutorial alters the blockchain we connect to the testnet so we don't create spam on the production server.

#### 2. User information<a name="userinfo"></a>

We also require the `private posting key` of the user that wishes to follow a selected author in order to commit the action to the blockchain. This is why we have to specify this along with the `testnet` node. The values are supplied via the terminal/console before we initialise the beem class. We have supplied a test account, `cdemo` to use with this tutorial but any demo account set up on the testnet can be used.

```python
# capture user information
account = input('Please enter your username: ')

# capture variables
author = input('Author to follow: ')

if author == account:
  print("Do you follow yourself?")
  exit()

# connect node and private posting key, demo account being used: cdemo, posting key: 5JEZ1EiUjFKfsKP32b15Y7jybjvHQPhnvCYZ9BW62H1LDUnMvHz
hive = beem.Hive('http://127.0.0.1:8090')
```

#### 3. Check author status<a name="authorstat"></a>

To insure the validity of the `follow` process, we first check to see if the `author` provided by the user is in fact an active username. This is done with a simple call to the blockchain which returns an array of all the user information. If the author does not exist, we raise and exception.

```python
author = Account(author, blockchain_instance=hive)
account = Account(account, blockchain_instance=hive)
already_following = False
```

Once the author name is confirmed to be valid we can move on to check the follow status of that author.

#### 4. Follow status<a name="followstat"></a>

If the author check comes back with a value we use a simple `if` statement to initialize the database query for the follow status.  A comprehensive tutorial is available to retrieve a list of followers and users that are being followed in the tutorial specified in the `intro`.  As we are only interested in a very specific author we can narrow the query results down to a single result.  That result then determines what the available actions are.

```python
if author:
  # check current follow status of specified author
  following = account.get_following()

  if len(following) > 0 and author.name in following:
    title = "Author is already being followed, please choose action"
    already_following = True
  else:
    title = "Author has not yet been followed, please choose action"
else:
  print('Author does not exist')
  exit()
```

The result from the `follow` query is printed on the UI and the user is asked to select the next action to take based on that information. If the author does not exit the program exits automatically.

```python
# get index and selected action
options = ['Follow', 'Unfollow', 'Exit']
option, index = pick(options, title)
tx = TransactionBuilder(blockchain_instance=hive)
```

Once we know what the user wants to do, we can move on to the actual broadcast.

#### 5. Follow/Unfollow Broadcast<a name="broadcast"></a>

Once the user has selected which action to take we user another set of `if` statements to execute that selection.

```python
if option == 'Follow' :
  if not already_following:
    tx.appendOps(Custom_json(**{
      'required_auths': [],
      'required_posting_auths': [account.name],
      'id': 'follow',
      'json': json.dumps(['follow', {
        'follower': account.name,
        'following': author.name,
        'what': ['blog'] # set what to follow
      }])
    }))
elif option == 'Unfollow' :
  if already_following:
    tx.appendOps(Custom_json(**{
      'required_auths': [],
      'required_posting_auths': [account.name],
      'id': 'follow',
      'json': json.dumps(['follow', {
        'follower': account.name,
        'following': author.name,
        'what': [] # clear previous follow
      }])
    }))

if len(tx.ops) == 0:
  print('Action Cancelled')
  exit()

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print(option + ' ' + author.name + ": " + str(broadcast_tx))
```

A simple confirmation of the chosen action is printed on the screen.

### To Run the tutorial

Before running this tutorial, launch your local testnet, with port 8090 mapped locally to the docker container:

```bash
docker run -d -p 8090:8090 inertia/tintoy:latest
```

For details on running a local testnet, see: [Setting Up a Testnet]({{ '/tutorials-recipes/setting-up-a-testnet.html' | relative_url }})

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/18_follow_a_user`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
