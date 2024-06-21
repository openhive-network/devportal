---
title: titles.submit_post
position: 10
description: "How to submit post on Hive blockchain using Python."
layout: full
canonical_url: submit_post.html
---
Full, runnable src of [Submit Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/10_submit_post) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-10_submit_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/10_submit_post)).

In this tutorial will explain and show you how to submit a new post to the `Hive` blockchain using the `commit` class found within the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`transactionbuilder`](https://beem.readthedocs.io/en/latest/beem.transactionbuilder.html) in the the library.  It should be noted that comments and new post are both treated as the `comment` operation with the only difference being that a comment/reply has an additional parameter containing the `parent_author`/`parent_permlink` that corresponds to the original post/comment.

* _author_ - The account that you are posting from
* _title_ - The title of the post
* _body_ - The body of the post
* _permlink_ - A unique identifier, scoped to author
* _parent_author_ - Empty string (for posts) or author being replied to (for replies)
* _parent_permlink_ - Category (for posts) or permlink being replied to (for replies)
* _json_metadata_ - JSON meta object that can be attached to the post
  * _tags_ - Between 1 and 5 key words that defines the post

We will only be using the above parameters as these are the only ones required to create a basic post.  If you want to explore the other parameters further you can find more information [HERE](https://beem.readthedocs.io/en/latest/beem.comment.html#beem.comment.Comment).

Also see:
* [comment_operation]({{ '/apidefinitions/#broadcast_ops_comment' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to Hive node
2. [**Variable input and format**](#input) - Input and creation of varialbes
3. [**Post submission and result**](#submit) - Committing of transaction to the blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use the following packages:

- `random` and `string` - used to create a random string used for the `permlink`
- `getpass` - capture wif without showing it on the screen
- `json` - generate `json_metadata`
- `beem` - hive library and interaction with Blockchain

We import the libraries, connect to your local `testnet`, and initialize the Hive class.

```python
import random
import string
import getpass
import json
from beem import Hive
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Comment
```

Because this tutorial alters the blockchain we have to connect to the testnet.  We also require the `private posting key` of the contributing author in order to commit the post which is why we're using a `testnet` node.

#### 2. Variable input and format<a name="input"></a>

The first three variables are captured via a simple string input while the `tags` variable is captured in the form of an array.

```python
#capture variables
author = input('Username: ')
title = input('Post Title: ')
body = input('Post Body: ')

#capture list of tags and separate by " "
taglimit = 2 #number of tags 1 - 5
taglist = []
for i in range(1, taglimit+1):
  print(i)
  tag = input(' Tag : ')
  taglist.append(tag)
```

The `tags` parameter needs to be formatted within the `json_metadata` field as JSON.  We also use a random generator to create a new `permlink` for the post being created.

```python
#random generator to create post permlink
permlink = ''.join(random.choices(string.digits, k=10))
```

The random generator is limited to 10 characters in this case but the permlink can be [up to 256 bytes]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_MAX_PERMLINK_LENGTH' | relative_url }}).  The permlink is unique to the author only which means that multiple authors can have the same permlink for the their post.

#### 3. Post submission and result<a name="submit"></a>

The last step is to transmit the post through to the blockchain.  All the defined parameters are signed and broadcasted.  We also securely prompt for the posting key right before signing.

```python
# client = Hive('https://testnet.openhive.network') # Public Testnet
client = Hive('http://127.0.0.1:8090') # Local Testnet
tx = TransactionBuilder(blockchain_instance=client)
tx.appendOps(Comment(**{
  "parent_author": '',
  "parent_permlink": taglist[0], # we use the first tag as the category
  "author": author,
  "permlink": permlink,
  "title": title,
  "body": body,
  "json_metadata": json.dumps({"tags": taglist})
}))

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Post created successfully: " + str(broadcast_tx))
```

A simple confirmation is printed on the screen if the post is committed successfully.

You can also check on your local testnet using [database_api.find_comments]({{ '/apidefinitions/#database_api.find_comments' | relative_url }}) for the post.

Final code:

```python
import random
import string
import getpass
import json
from beem import Hive
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Comment

#capture variables
author = input('Username: ')
title = input('Post Title: ')
body = input('Post Body: ')

#capture list of tags and separate by " "
taglimit = 2 #number of tags 1 - 5
taglist = []
for i in range(1, taglimit+1):
  print(i)
  tag = input(' Tag : ')
  taglist.append(tag)

#random generator to create post permlink
permlink = ''.join(random.choices(string.digits, k=10))

# client = Hive('https://testnet.openhive.network') # Public Testnet
client = Hive('http://127.0.0.1:8090') # Local Testnet
tx = TransactionBuilder(blockchain_instance=client)
tx.appendOps(Comment(**{
  "parent_author": '',
  "parent_permlink": taglist[0], # we use the first tag as the category
  "author": author,
  "permlink": permlink,
  "title": title,
  "body": body,
  "json_metadata": json.dumps({"tags": taglist})
}))

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Post created successfully: " + str(broadcast_tx))

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
2. `cd devportal/tutorials/python/10_submit_post`
3. `pip install -r requirements.txt`
4. `python index.py`
5. After a few moments, you should see a prompt for input in terminal screen.
