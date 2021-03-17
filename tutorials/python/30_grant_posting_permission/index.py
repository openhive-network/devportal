from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# connect to production server with active key
client = Hive('http://127.0.0.1:8091', keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)

print('Current posting authorizations: ' + str(account['posting']['account_auths']))

# get account to authorise and check if valid
foreign = input('Please enter the account name for POSTING authorization: ')
if (foreign == account.name):
  print('Cannot allow or disallow posting permission to your own account')
  exit()

foreign = Account(foreign, blockchain_instance=client)

# check if foreign account already has posting auth
title = ''

for auth in account['posting']['account_auths']:
  if (auth[0] == foreign.name):
    title = (foreign.name + ' already has posting permission. Please choose option from below list')
    options = ['DISALLOW', 'CANCEL']
    break

if (title == ''):
  title = (foreign.name + ' does not yet posting permission. Please choose option from below list')
  options = ['ALLOW', 'CANCEL']

option, index = pick(options, title)

if (option == 'CANCEL'):
  print('operation cancelled')
  exit()

if (option == 'ALLOW'):
  account.allow(foreign=foreign.name, weight=1, permission='posting', threshold=1)
  print(foreign.name + ' has been granted posting permission')
else:
  account.disallow(foreign=foreign.name, permission='posting', threshold=1)
  print('posting permission for ' + foreign.name + ' has been removed')

