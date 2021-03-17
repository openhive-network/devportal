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

client = Hive('http://127.0.0.1:8091')
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

