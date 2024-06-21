---
title: titles.reblogging_post
position: 14
description: "We will show how to reblog or reblog post using Python, with username and posting private key."
layout: full
canonical_url: reblogging_post.html
---
Full, runnable src of [Reblogging Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/14_reblogging_post) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-14_reblogging_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/14_reblogging_post)).

Tutorial will also explain and show you how to sign/broadcast transaction on **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

Beem has built-in functionality to commit transaction and broadcast it to the network. 

Also see:
* [custom_json_operation]({{ '/apidefinitions/#broadcast_ops_custom_json' | relative_url }})

## Steps

1. [**App setup**](#app-setup) - Library install and import
1. [**Post list**](#post-list) - List of posts to select from trending filter 
1. [**Enter user credentials**](#credentials-list) - Enter user credentails to sign transaction

#### 1. App setup <a name="app-setup"></a>

In this tutorial we use 3 packages, `pick` - helps us to select filter interactively. `beem` - hive library, interaction with Blockchain. `pprint` - print results in better format.

First we import all three library and initialize Hive class:

```python
import pprint
from pick import pick
import getpass
import json
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.comment import Comment
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Custom_json

# hive = Hive(['https://testnet.openhive.network']) # Public Testnet
hive = Hive(['http://127.0.0.1:8090']) # Local Testnet
```

#### 2. Post list <a name="post-list"></a>

Next we will fetch and make list of accounts and setup `pick` properly.

```python
q = Query(limit=5, tag="")
d = Discussions(blockchain_instance=hive)

#author list from hot post list
posts = d.get_discussions('hot', q, limit=5)

title = 'Please choose post to reblog: '
options = []
# post list
for post in posts:
  options.append('@' + post["author"] + '/' + post["permlink"])
```

This will show us list of posts to select in terminal/command prompt. And after selection we will get formatted post as an `option` variable.

#### 3. Enter user credentials <a name="credentials-list"></a>

Next in order to sign transaction, application asks for username and posting private key to sign transaction and broadcast it.

```python
# get index and selected post
option, index = pick(options, title)
pprint.pprint("You selected: " + option)

comment = Comment(option, blockchain_instance=hive)

account = input("Enter your username? ")

tx = TransactionBuilder(blockchain_instance=hive)
tx.appendOps(Custom_json(**{
  'required_auths': [],
  'required_posting_auths': [account],
  'id': 'reblog',
  'json': json.dumps(['reblog', {
    'account': account,
    'author': comment.author,
    'permlink': comment.permlink
  }])
}))

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Reblogged successfully: " + str(broadcast_tx))
```

If transaction is successful you shouldn't see any error messages, otherwise you will be notified.

Final code:

```python
import pprint
from pick import pick
import getpass
import json
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.comment import Comment
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Custom_json

# hive = Hive(['https://testnet.openhive.network']) # Public Testnet
hive = Hive(['http://127.0.0.1:8090']) # Local Testnet
q = Query(limit=5, tag="")
d = Discussions(blockchain_instance=hive)

#author list from hot post list
posts = d.get_discussions('hot', q, limit=5)

title = 'Please choose post to reblog: '
options = []
# post list
for post in posts:
  options.append('@' + post["author"] + '/' + post["permlink"])

# get index and selected post
option, index = pick(options, title)
pprint.pprint("You selected: " + option)

comment = Comment(option, blockchain_instance=hive)

account = input("Enter your username? ")

tx = TransactionBuilder(blockchain_instance=hive)
tx.appendOps(Custom_json(**{
  'required_auths': [],
  'required_posting_auths': [account],
  'id': 'reblog',
  'json': json.dumps(['reblog', {
    'account': account,
    'author': comment.author,
    'permlink': comment.permlink
  }])
}))

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Reblogged successfully: " + str(broadcast_tx))

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/14_reblogging_post`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
