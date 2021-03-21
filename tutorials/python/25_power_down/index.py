import pprint
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

# get account balance for vesting shares
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
powering_down = ((to_withdraw_vests - withdrawn_vests) / denom) * base_per_mvest

print(symbol + ' Power currently powering down: ' + format(powering_down, '.3f') + ' ' + symbol +
  '\n' + 'Available ' + symbol + ' Power: ' + format(available_base, '.3f') + ' ' + symbol)

input('\n' + 'Press enter to continue' + '\n')

# choice of transfer
title = 'Please choose an option: '
options = ['Power down ALL', 'Power down PORTION', 'Cancel Transaction']
# get index and selected transfer type
option, index = pick(options, title)

# parameters: amount, account
if (option == 'Cancel Transaction'):
  print('transaction cancelled')
  exit()

if (option == 'Power down ALL'):
  if (available_vests == 0):
    print('No change to withdraw amount')
    exit()
  amount_vests = to_withdraw_vests + available_vests
  amount = (amount_vests / denom) * base_per_mvest
else:
  amount = float(input('Please enter the amount of ' + symbol + ' you would like to power down: ') or '0')
  amount_vests = (amount * denom) / base_per_mvest

if (amount_vests <= (to_withdraw_vests + available_vests)):
  account.withdraw_vesting(amount_vests)
  print(format(amount, '.3f') + ' ' + symbol + ' (' + format(amount_vests, '.6f') + ' ' + vesting_symbol + ') now powering down')
  exit()

if (amount_vests == to_withdraw_vests):
  print('No change to withdraw amount')
  exit()

print('Insufficient funds available')

