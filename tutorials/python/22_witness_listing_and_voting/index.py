import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.witness import Witness, WitnessesVotedByAccount

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Active Key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)

# print list of currently voted for witnesses
print('\n' + 'WITNESSES CURRENTLY VOTED FOR')
vote_list = WitnessesVotedByAccount(account.name, blockchain_instance=client)
for witness in vote_list:
  pprint.pprint(witness.account.name)

input('Press enter to continue')

# choice of action
title = ('Please choose action')
options = ['VOTE', 'UNVOTE', 'CANCEL']
# get index and selected permission choice
option, index = pick(options, title)

if (option == 'CANCEL') :
    print('\n' + 'operation cancelled')
    exit()

if (option == 'VOTE') :
    # vote process
    witness_vote = input('Please enter the witness name you wish to vote for: ')
    witness = Witness(witness_vote, blockchain_instance=client)
    if witness_vote in vote_list :
        print('\n' + witness_vote + ' cannot be voted for more than once')
        exit()
    account.approvewitness(witness_vote)
    print('\n' + witness_vote + ' has been successfully voted for')
else :
    # unvote process
    witness_unvote = input('Please enter the witness name you wish to remove the vote from: ')
    if witness_unvote not in vote_list :
        print('\n' + witness_unvote + ' is not in your voted for list')
        exit()
    account.disapprovewitness(witness_unvote)
    print('\n' + witness_unvote + ' has been removed from your voted for list')
