from pick import pick
from beem import Hive
from beem.account import Account
from beem.amount import Amount

client = Hive()

# capture username
account = input('Username: ')
account = Account(account)

balance = account['balance']
symbol = balance.symbol

# we need high precision because VESTS
denom = 1e6
dgpo = client.get_dynamic_global_properties()
total_vesting_fund_hive = Amount(dgpo['total_vesting_fund_hive']).amount
total_vesting_shares_mvest = Amount(dgpo['total_vesting_shares']).amount / denom
base_per_mvest = total_vesting_fund_hive / total_vesting_shares_mvest

# capture list limit
limit = input('Max number of vesting delegations to display: ') or '10'

# list type
title = 'Please choose the type of list: '
options = ['Active Vesting Delegations', 'Expiring Vesting Delegations']

# get index and selected list name
option, index = pick(options, title)
print('\n' + 'List of ' + option + ': ' + '\n')

if option=='Active Vesting Delegations' :
  delegations = account.get_vesting_delegations(limit=limit)
else:
  delegations = account.get_expiring_vesting_delegations("2018-01-01T00:00:00", limit=limit)

if len(delegations) == 0:
  print('No ' + option)
  exit

for delegation in delegations:
  delegated_vests = float(delegation['vesting_shares']['amount']) / denom
  delegated_base = (delegated_vests / denom) * base_per_mvest
  print('\t' + delegation['delegatee'] + ': ' + format(delegated_base, '.3f') + ' ' + symbol)

