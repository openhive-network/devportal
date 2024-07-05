---
title: titles.submit_comment_reply
position: 11
description: descriptions.submit_comment_reply
layout: full
canonical_url: submit_comment_reply.html
---
Full, runnable src of [Submit Comment Reply](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/11_submit_comment_reply) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-11_submit_comment_reply.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/11_submit_comment_reply)).

This tutorial will explain and show you how to submit a new comment to the `Hive` blockchain using the `commit` class found within the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`transactionbuilder`](https://beem.readthedocs.io/en/latest/beem.transactionbuilder.html) in the the library.  It should be noted that comments and new post are both treated as the `comment` operation with the only difference being that a comment/reply has an additional parameter containing the `parent_author`/`parent_permlink` that corresponds to the original post/comment.

* _author_ - The account that you are posting from
* _title_ - The title of the reply (usually empty for replies)
* _body_ - The body of the reply
* _permlink_ - A unique identifier, scoped to author
* _parent_author_ - Author being replied to (for replies) or empty string (for posts)
* _parent_permlink_ - Permlink being replied to (for replies) or category (for posts)

We will only be using the above parameters as these are the only ones required to create a basic post.  If you want to explore the other parameters further you can find more information [HERE](https://beem.readthedocs.io/en/latest/beem.comment.html#beem.comment.Comment).

A comment made on a post is defined as a `root comment`. You can also comment on someone else's (or your own) comment, in which case the `parent` parameters would be that of the comment, and not the original post.

Also see:
* [comment_operation]({{ '/apidefinitions/#broadcast_ops_comment' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to Hive node
1. [**Variable input and format**](#input) - Input and creation of varialbes
1. [**Initialize class**](#initialize) - Initialize the beem class with the relevant node and private key
1. [**Post submission and result**](#submit) - Committing of transaction to the blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use the following packages:

- `random` and `string` - used to create a random string used for the `permlink`
- `getpass` - capture wif without showing it on the screen
- `beem` - hive library and interaction with Blockchain

We import the libraries and connect to the `testnet`.

```python
import random
import string
import getpass
from beem import Hive
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Comment
```

Because this tutorial alters the blockchain we have to connect to the testnet.  We also require the `private posting key` of the contributing author in order to commit the post which is why we're using a `testnet` node.

#### 2. Variable input and format<a name="input"></a>

The first three variables are captured via a simple string input.

```python
#capture variables
parent_author = input('Parent author: ')
parent_permlink = input('Parent permlink: ')
author = input('Username: ')
title = input('Post Title: ')
body = input('Post Body: ')
```

We also use a random generator to create a new `permlink` for the post being created.

```python
#random generator to create post permlink
permlink = ''.join(random.choices(string.digits, k=10))
```

The random generator is limited to 10 characters in this case but the permlink can be [up to 256 bytes]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_MAX_PERMLINK_LENGTH' | relative_url }}).  The permlink is unique to the author only which means that multiple authors can have the same permlink for the their reply.

#### 3. Initialize class<a name="initialize"></a>

We initialize the beem class by connecting to the specific `testnet` node. We also require the `private posting key` of the contributing author in order to commit the post which is also specified during this operation.

```python
# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

#connect node and private posting key
client = Hive(node_url, keys=[wif])
```

#### 4. Post submission and result<a name="submit"></a>

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
from beem import Hive
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Comment

#capture variables
parent_author = input('Parent author: ')
parent_permlink = input('Parent permlink: ')
author = input('Username: ')
title = input('Post Title: ')
body = input('Post Body: ')

#random generator to create post permlink
permlink = ''.join(random.choices(string.digits, k=10))

# client = Hive('https://testnet.openhive.network') # Public Testnet
client = Hive('http://127.0.0.1:8090') # Local Testnet
tx = TransactionBuilder(blockchain_instance=client)
tx.appendOps(Comment(**{
  "parent_author": parent_author,
  "parent_permlink": parent_permlink,
  "author": author,
  "permlink": permlink,
  "title": title,
  "body": body
}))

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Comment created successfully: " + str(broadcast_tx))

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/11_submit_comment_reply`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
