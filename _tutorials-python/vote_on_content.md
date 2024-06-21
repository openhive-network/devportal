---
title: 'PY: Vote On Content'
position: 17
description: "How to vote on a post/comment using Python."
layout: full
canonical_url: vote_on_content.html
---
Full, runnable src of [Vote On Content](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/17_vote_on_content) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-17_vote_on_content.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/17_vote_on_content)).

In this tutorial we will explain and show you how to to check if a user has voted on specified content and also how to submit a vote on the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

Voting is a way of promoting good content via an `upvote` or reporting misuse, spam or other unfit content by `downvoting`. The Hive python library has a built-in function to transmit transactions to the blockchain. We are using the `vote` method found within the `commit` class in the the library. Before we vote on content we first check whether the user has already voted. This is not strictly necessary as a voting operation overrides the previous vote value. We use the [`get_active_votes`](https://beem.readthedocs.io/en/latest/beem.vote.html#beem.vote.ActiveVotes) function to check for this. This function only requires two parameters, the `author` and the `permlink` for the comment/post that the query is for. This returns a list of the current voters for that comment. The `vote` function has 3 parameters:

1. _identifier_ - This is a combination of the author and permink of the post/comment that the vote will be on
1. _weight_ - This value determines whether the vote is an upvote (+100.0), a downvote (-100.0), or zero (0) to remove previous vote.
1. _username_ - The name of the account that is executing the vote

Also see:
* [vote_operation]({{ '/apidefinitions/#broadcast_ops_vote' | relative_url }})
* [get_active_votes]({{ '/apidefinitions/#condenser_api.get_active_votes' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information**](#userinfo) - Input user information and connection to Hive node
1. [**Check vote status**](#votestat) - Vote status of post/comment
1. [**Commit vote**](#commit) - Commit vote to the blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use 3 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the `testnet`.

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.vote import ActiveVotes
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Vote
```

Because this tutorial alters the blockchain we connect to the testnet so we don't create spam on the production server.

#### 2. User information<a name="userinfo"></a>

We also require the `private posting key` of the user that wishes to vote on the selected content so the action can be committed to the blockchain. This is why we have to specify this along with the `testnet` node. The values are supplied via the terminal/console before we initialise the beem class. We have supplied a test account, `cdemo` to use with this tutorial but any account set up on the testnet can be used.

```python
# capture user information
voter = input('Please enter your username (voter): ')

# connect node
# If using mainnet, try with demo account: cdemo, posting key: 5JEZ1EiUjFKfsKP32b15Y7jybjvHQPhnvCYZ9BW62H1LDUnMvHz
# client = Hive('https://testnet.openhive.network') # Public Testnet
client = Hive('http://127.0.0.1:8090') # Local Testnet
```

#### 3. Check vote status<a name="votestat"></a>

In order to give the user an educated choice we first check whether they have already voted on the given post/comment. The author and permlink for the post is supplied via the console/terminal.

```python
# capture variables
author = input('Author of post/comment that you wish to vote for: ')
permlink = input('Permlink of the post/comment you wish to vote for: ')
```

The vote status check is done with a simple query to the blockchain.

```python
# check vote status
# noinspection PyInterpreter
print('checking vote status - getting current post votes')
identifier = ('@' + author + '/' + permlink)
author_account = Account(author, blockchain_instance=client)
result = ActiveVotes(identifier, blockchain_instance=client)
print(len(result), ' votes retrieved')
```

This query returns a list of the current voters on the specified post/comment. The result is checked against the username to determine what the current status is.

```python
if result:
  for vote in result :
    if vote['voter'] == voter:
      title = "This post/comment has already been voted for"
      break
    else:
      title = "No vote for this post/comment has been submitted"
else:
  title = "No vote for this post/comment has been submitted"
```

#### 4. Commit vote<a name="commit"></a>

The result from the previous step is used to give the user a choice in what the next step in the operation should be.

```python
# option to continue
options = ['Add/Change vote', 'Cancel without voting']
option, index = pick(options, title)
```

The user is given a choice to either continue with the vote or cancel the operation. If the user elects to continue, the `vote` function is executed. The weight of the vote is input from the UI and the identifier parameter is created by combining the author and permlink values.

```python
if option == 'Add/Change vote':
  weight = input('\n' + 'Please advise weight of vote between -100.0 and 100 (zero removes previous vote): ')
  try:
    tx = TransactionBuilder(blockchain_instance=client)
    tx.appendOps(Vote(**{
      "voter": voter,
      "author": author,
      "permlink": permlink,
      "weight": int(float(weight) * 100)
    }))

    wif_posting_key = getpass.getpass('Posting Key: ')
    tx.appendWif(wif_posting_key)
    signed_tx = tx.sign()
    broadcast_tx = tx.broadcast(trx_id=True)

    print("Vote cast successfully: " + str(broadcast_tx))
  except Exception as e:
    print('\n' + str(e) + '\nException encountered.  Unable to vote')

else:
  print('Voting has been cancelled')
```

When the function is executed the selected vote weight overrides any value previously recorded on the blockchain.

A simple confirmation of the chosen action is printed on the screen.

Final code:

```python
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.vote import ActiveVotes
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Vote

# capture user information
voter = input('Please enter your username (voter): ')

# connect node
# If using mainnet, try with demo account: cdemo, posting key: 5JEZ1EiUjFKfsKP32b15Y7jybjvHQPhnvCYZ9BW62H1LDUnMvHz
# client = Hive('https://testnet.openhive.network') # Public Testnet
client = Hive('http://127.0.0.1:8090') # Local Testnet

# capture variables
author = input('Author of post/comment that you wish to vote for: ')
permlink = input('Permlink of the post/comment you wish to vote for: ')

# check vote status
# noinspection PyInterpreter
print('checking vote status - getting current post votes')
identifier = ('@' + author + '/' + permlink)
author_account = Account(author, blockchain_instance=client)
result = ActiveVotes(identifier, blockchain_instance=client)
print(len(result), ' votes retrieved')

if result:
  for vote in result :
    if vote['voter'] == voter:
      title = "This post/comment has already been voted for"
      break
    else:
      title = "No vote for this post/comment has been submitted"
else:
  title = "No vote for this post/comment has been submitted"

# option to continue
options = ['Add/Change vote', 'Cancel without voting']
option, index = pick(options, title)

if option == 'Add/Change vote':
  weight = input('\n' + 'Please advise weight of vote between -100.0 and 100 (zero removes previous vote): ')
  try:
    tx = TransactionBuilder(blockchain_instance=client)
    tx.appendOps(Vote(**{
      "voter": voter,
      "author": author,
      "permlink": permlink,
      "weight": int(float(weight) * 100)
    }))

    wif_posting_key = getpass.getpass('Posting Key: ')
    tx.appendWif(wif_posting_key)
    signed_tx = tx.sign()
    broadcast_tx = tx.broadcast(trx_id=True)

    print("Vote cast successfully: " + str(broadcast_tx))
  except Exception as e:
    print('\n' + str(e) + '\nException encountered.  Unable to vote')

else:
  print('Voting has been cancelled')

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/17_vote_on_content`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
