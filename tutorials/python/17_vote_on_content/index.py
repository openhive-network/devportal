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
