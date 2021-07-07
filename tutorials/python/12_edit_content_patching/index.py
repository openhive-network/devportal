import beem
import getpass
from beem import Hive
from beem.account import Account
from beem.comment import Comment
from beem.transactionbuilder import TransactionBuilder
from beembase import operations
from diff_match_patch import diff_match_patch

#capture user information
post_author = input('Please enter the AUTHOR of the post you want to edit: ')

#connect node
# client = Hive('https://testnet.openhive.network') # Public Testnet
client = Hive('http://127.0.0.1:8090') # Local Testnet

#check valid post_author
try:
  userinfo = Account(post_author, blockchain_instance=client)
except:
  print('Oops. Looks like user ' + post_author + ' doesn\'t exist on this chain!')
  exit()

post_permlink = input('Please enter the PERMLINK of the post you want to edit: ')

#get details of selected post
try:
  details = beem.comment.Comment(post_author + '/' + post_permlink, blockchain_instance=client)
except:
  print('Oops. Looks like ' + post_author + '/' + post_permlink + ' doesn\'t exist on this chain!')
  exit()

print('\n' + 'Title: ' + details.title)
o_body = details.body
print('Body:' + '\n' + o_body + '\n')

n_body = input('Please enter new post content:' + '\n')

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
