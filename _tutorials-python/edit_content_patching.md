---
title: 'PY: Edit Content Patching'
position: 12
description: "How to edit post content with diff_match_patch using Python."
layout: full
canonical_url: edit_content_patching.html
---
Full, runnable src of [Edit Content Patching](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/12_edit_content_patching) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-12_edit_content_patching.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/12_edit_content_patching)).

In this tutorial we show you how to patch and update posts/comments on the **Hive** blockchain using the `commit` class found within the [beem](https://github.com/holgern/beem) library.

## Intro

Being able to patch a post is critical to save resources on Hive.  The beem library has a built-in functionality to transmit transactions to the blockchain. We are using the `diff_match_patch` class for python to create a `patch` for a post or comment.  There is already a tutorial on how to create a new post so the focus of this tutorial will be on `patching` the content of the post.  We will be using a couple of methods provided by the `diff_match_patch` module.

`diff_main` - This compares two text fields to find the differences.
`diff_cleanupSemantic` - This reduces the number of edits by eliminating semantically trivial equalities.
`diff_levenshtein` - Computes the Levenshtein distance: the number of inserted, deleted or substituted characters
`patch_make` - Creates a patch based on the calculated differences. This method can be executed in 3 different ways based on the parameters. By using the two separate text fields in question, by using only the calculated difference, or by using the original text along with the calculated difference.
`patch_apply` - This applies the created patch to the original text field.

## Steps

1. [**App setup**](#setup) - Library install and import.
1. [**Post to update**](#post) - Input and retrieve post information, connection to testnet
1. [**Patching**](#patch) - Create the patch to update the post
1. [**New post commit**](#commit) - Commit the post to the blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use 2 packages:

- `beem` - hive library and interaction with Blockchain
- `diff_match_patch` - used to compute the difference between two text fields to create a patch

We import the libraries.

```python
import beem
import getpass
from beem import Hive
from beem.account import Account
from beem.comment import Comment
from beem.transactionbuilder import TransactionBuilder
from beembase import operations
from diff_match_patch import diff_match_patch
```

#### 2. Post to update <a name="post"></a>

We require the `private posting key` of the user in order for the transfer to be committed to the blockchain. This is why we are using a testnet. The values are supplied via the terminal/console before we initialise the steem class. There are some demo accounts available but we encourage you to create your own accounts on this testnet and create balances you can claim; it's good practice.

The user inputs the author and permlink of the post that they wish to edit.  See the [`submit post`]({{ '/tutorials-python/submit_post.html' | relative_url }}) tutorial to create a new post before trying the patch process.

```python
#check valid username
#capture user information
post_author = input('Please enter the AUTHOR of the post you want to edit: ')

#connect node
client = Hive('http://127.0.0.1:8091')

#check valid post_author
try:
  userinfo = Account(post_author, blockchain_instance=client)
except:
  print('Oops. Looks like user ' + post_author + ' doesn\'t exist on this chain!')
  exit()

post_permlink = input('Please enter the PERMLINK of the post you want to edit: ')

#get details of selected post
try:
  details = beem.comment.Comment(post_author + '/' + post_permlink)
except:
  print('Oops. Looks like ' + post_author + '/' + post_permlink + ' doesn\'t exist on this chain!')
  exit()

print('\n' + 'Title: ' + details.title)
o_body = details.body
print('Body:' + '\n' + o_body + '\n')

n_body = input('Please enter new post content:' + '\n')
```

The user also inputs the updated text in the console/terminal.  This will then give us the two text fields to compare.

#### 3. Patching <a name="patch"></a>

The module is initiated and the new post text is checked for validity.

```python
#initialise the diff match patch module
dmp = diff_match_patch()

#Check for null input
if (n_body == '') :
  print('\n' + 'No new post body supplied. Operation aborted')
  exit()
else :
  # Check for equality
  if (o_body == n_body) :
    print('\n' + 'No changes made to post body. Operation aborted')
    exit()
```

The `diff` is calculated and a test is done to check the `diff` length against the total length of the new text to determine if it will be better to patch or just replace the text field.  The value to be sent to the blockchain is then assigned to the `new_body` parameter.

```python
#check for differences in the text field
diff = dmp.diff_main(o_body, n_body)
#Reduce the number of edits by eliminating semantically trivial equalities.
dmp.diff_cleanupSemantic(diff)
#create patch
patch = dmp.patch_make(o_body, diff)
#create new text based on patch
patch_body = dmp.patch_toText(patch)
#check patch length
if (len(patch_body) < len(o_body)) :
  new_body = patch_body
else :
  new_body = n_body
```

#### 4. New post commit <a name="commit"></a>

The only new parameter is the changed body text. All the other parameters to do a commit is assigned directly from the original post entered by the user.

```python
tx = TransactionBuilder(blockchain_instance=client)
tx.appendOps(operations.Comment(**{
  "parent_author": details.parent_author,
  "parent_permlink": details.parent_permlink,
  "author": details.author,
  "permlink": details.permlink,
  "title": details.title,
  "body": new_body,
  "json_metadata": details.json_metadata
}))

wif_posting_key = getpass.getpass('Posting Key: ')
tx.appendWif(wif_posting_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print('\n' + 'Content of the post has been successfully updated: ' + str(broadcast_tx))
```

A simple confirmation is displayed on the screen for a successful commit.

We encourage users to play around with different values and data types to fully understand how this process works. You can also check the balances and transaction history on the [testnet portal](http://testnet-condenser.hive.blog/).

### To Run the tutorial

Before running this tutorial, launch your local testnet, with port 8091 mapped locally to the docker container:

```bash
docker run -d -p 8091:8091 inertia/tintoy:latest
```

For details on running a local testnet, see: [Setting Up a Testnet]({{ '/tutorials-recipes/setting-up-a-testnet.html' | relative_url }})

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/12_edit_content_patching`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
