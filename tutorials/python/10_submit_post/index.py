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

client = Hive('http://127.0.0.1:8091')
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

