import getpass
import json
from pick import pick
import beem
from beem.account import Account
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Custom_json

# capture user information
account = input('Please enter your username: ')

# capture variables
author = input('Author to follow: ')

if author == account:
  print("Do you follow yourself?")
  exit()

# connect node and private posting key, demo account being used: cdemo, posting key: 5JEZ1EiUjFKfsKP32b15Y7jybjvHQPhnvCYZ9BW62H1LDUnMvHz
hive = beem.Hive('http://127.0.0.1:8090')

author = Account(author, blockchain_instance=hive)
account = Account(account, blockchain_instance=hive)
already_following = False

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

# get index and selected action
options = ['Follow', 'Unfollow', 'Exit']
option, index = pick(options, title)
tx = TransactionBuilder(blockchain_instance=hive)

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

