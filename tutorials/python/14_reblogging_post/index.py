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
