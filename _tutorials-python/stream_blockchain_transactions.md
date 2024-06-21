---
title: 'PY: Stream Blockchain Transactions'
position: 13
description: "How to stream transactions on the live **Hive** blockchain"
layout: full
canonical_url: stream_blockchain_transactions.html
---
Full, runnable src of [Stream Blockchain Transactions](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/13_stream_blockchain_transactions) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-13_stream_blockchain_transactions.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/13_stream_blockchain_transactions)).

In this tutorial we show you how to stream transactions on the **Hive** blockchain using the `blockchain` class found within the [beem](https://github.com/holgern/beem) library.

## Intro

Tutorial is demonstrating the typical process of streaming operations on Hive.  We will show some information from certain ops, based on certain conditions.

We are using the `blockchain.stream()` function provided by beem which returns each operation after it has been accepted by witnesses.  By default it follows irreversible blocks which was accepted by all witnesses.

Also see:
* [block_api.get_block]({{ '/apidefinitions/#block_api.get_block' | relative_url }})
* [block_api.get_block_range]({{ '/apidefinitions/#block_api.get_block_range' | relative_url }})
* [account_history_api.enum_virtual_ops]({{ '/apidefinitions/#account_history_api.enum_virtual_ops' | relative_url }})

## Steps

1. [**App setup**](#app-setup) Configure imports and initialization of libraries
1. [**Stream blocks**](#stream-blocks) Stream blocks
1. [**Sample result**](#sample-result) Sample results

#### 1. App setup<a name="app-setup"></a>

In this tutorial we use 1 package:

beem library and interaction with Blockchain

```python
from beem.blockchain import Blockchain
from beem import Hive

h = Hive()
blockchain = Blockchain(blockchain_instance=h)
```

Above we create an instance of Blockchain which will give us the ability to stream the live transactions from the blockchain.

#### 2. Stream blocks<a name="stream-blocks"></a>

Next we create an instance of `stream` and then loop through the steam as transactions are available and print them to the screen.

```python
stream = blockchain.stream()

for op in stream:
  if op["type"] == 'comment':
    if len(op["parent_author"]) == 0:
      print(op["author"] + " authored a post: " + op["title"])
    else:
      print(op["author"] + " replied to " + op["parent_author"])
```

For this tutorial, we are only interested in the `comment` operation.  Then, we check if the author wrote a top-level post or a reply.

Also see: [Broadcast Ops]({{ '/apidefinitions/#apidefinitions-broadcast-ops' | relative_url }})

#### 3. Sample result<a name="sample-result"></a>

```
shortsegments replied to edje
riverflows replied to breezin
ejmh.vibes replied to kiritoccs
carlosadolfochac authored a post: NATURA.
hiveupme replied to prydefoltz
shortsegments replied to filotasriza3
walterprofe authored a post: Límites 01 Introducción
poshbot replied to prydefoltz
```

Final code:

```python
from beem.blockchain import Blockchain
from beem import Hive

h = Hive()
blockchain = Blockchain(blockchain_instance=h)
stream = blockchain.stream()

for op in stream:
  if op["type"] == 'comment':
    if len(op["parent_author"]) == 0:
      print(op["author"] + " authored a post: " + op["title"])
    else:
      print(op["author"] + " replied to " + op["parent_author"])
    

```

---

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/13_stream_blockchain_transactions`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
