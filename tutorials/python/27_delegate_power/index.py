from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.amount import Amount

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# connect node and private active key
client = Hive('http://127.0.0.1:8090', keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)

balance = account['balance']
symbol = balance.symbol

# we need high precision because VESTS
denom = 1e6
delegated_vests = account['delegated_vesting_shares']
vesting_shares = account['vesting_shares']
vesting_symbol = vesting_shares.symbol
to_withdraw_vests = float(account['to_withdraw']) / denom
withdrawn_vests = float(account['withdrawn']) / denom

dgpo = client.get_dynamic_global_properties()
total_vesting_fund_hive = Amount(dgpo['total_vesting_fund_hive']).amount
total_vesting_shares_mvest = Amount(dgpo['total_vesting_shares']).amount / denom
base_per_mvest = total_vesting_fund_hive / total_vesting_shares_mvest
available_vests = (vesting_shares.amount - delegated_vests.amount - ((to_withdraw_vests - withdrawn_vests)))
available_base = (available_vests / denom) * base_per_mvest

# display active delegations (refer to tutorial #29_get_delegations_by_user)
delegations = account.get_vesting_delegations()
if len(delegations) == 0:
  print('No active delegations')
else:
  print('Current delegations:')
  for delegation in delegations:
    delegated_vests = float(delegation['vesting_shares']['amount']) / denom
    delegated_base = (delegated_vests / denom) * base_per_mvest
    print('\t' + delegation['delegatee'] + ': ' + format(delegated_base, '.3f') + ' ' + symbol)

print('\n' + 'Available ' + symbol + ' Power: ' + format(available_base, '.3f') + ' ' + symbol)

input('Press enter to continue' + '\n')

# choice of action
title = ('Please choose action')
options = ['DELEGATE POWER', 'UN-DELEGATE POWER', 'CANCEL']
# get index and selected permission choice
option, index = pick(options, title)

if (option == 'CANCEL'):
  print('operation cancelled')
  exit()

# get account to authorise and check if valid
delegatee = input('Please enter the account name to ADD / REMOVE delegation: ')
delegatee = Account(delegatee, blockchain_instance=client)

if (option == 'DELEGATE POWER'):
  amount = float(input('Please enter the amount of ' + symbol + ' you would like to delegate: ') or '0')
  amount_vests = (amount * denom) / base_per_mvest
  
  print(format(amount, '.3f') + ' ' + symbol + ' (' + format(amount_vests, '.6f') + ' ' + vesting_symbol + ') will be delegated to ' + delegatee.name)
else:
  amount_vests = 0
  print('Removing delegated VESTS from ' + delegatee.name)

account.delegate_vesting_shares(delegatee.name, amount_vests)

print('Success.')

