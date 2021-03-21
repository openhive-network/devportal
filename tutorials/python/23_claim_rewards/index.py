import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_posting_key = getpass.getpass('Enter private POSTING key: ')

# connect node
client = Hive('http://127.0.0.1:8090', keys=[wif_posting_key])

# get account reward balances
account = Account(account, blockchain_instance=client)

reward_hive = account['reward_hive_balance']
reward_hbd = account['reward_hbd_balance']
reward_vests = account['reward_vesting_balance']

print('Reward Balances:' + '\n' + 
  '\t' + str(reward_hive) + '\n' + 
  '\t' + str(reward_hbd) + '\n' + 
  '\t' + str(reward_vests)
)

if reward_hive.amount + reward_hbd.amount + reward_vests.amount == 0:
  print('\n' + 'No rewards to claim')
  exit()

input('\n' + 'Press enter to continue to claim selection')

# choice of claim
title = 'Please choose claim type: '
options = ['ALL', 'SELECTED', 'CANCEL']
# get index and selected claim type
option, index = pick(options, title)

if option == 'CANCEL':
  print('\n' + 'Operation cancelled')
  exit()
  
# commit claim based on selection
if option == 'ALL':
  account.claim_reward_balance
  print('\n' + 'All reward balances have been claimed. New reward balances are:' + '\n')
else:
  claim_hive = float(input('\n' + 'Please enter the amount of HIVE to claim: ') or '0')
  claim_hbd = float(input('Please enter the amount of HBD to claim: ') or '0')
  claim_vests = float(input('Please enter the amount of VESTS to claim: ') or '0')

  if claim_hive + claim_hbd + claim_vests == 0:
    print('\n' + 'Zero values entered, no claim to submit')
    exit()
  
  if claim_hive > reward_hive or claim_hbd > reward_hbd or claim_vests > reward_vests:
    print('\n' + 'Requested claim value higher than available rewards')
    exit()
  
  account.claim_reward_balance(reward_hive=claim_hive, reward_hbd=claim_hbd, reward_vests=claim_vests)
  print('\n' + 'Claim has been processed. New reward balances are:' + '\n')

# get updated account reward balances
input("Press enter for new account balances")

account.refresh()

reward_hive = account['reward_hive_balance']
reward_hbd = account['reward_hbd_balance']
reward_vests = account['reward_vesting_balance']

print('\t' + str(reward_hive) + '\n' + 
  '\t' + str(reward_hbd) + '\n' + 
  '\t' + str(reward_vests)
)

