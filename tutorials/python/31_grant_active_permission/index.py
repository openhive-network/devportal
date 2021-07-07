from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect with active key
client = Hive(node_url, keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)

print('Current active authorizations: ' + str(account['active']['account_auths']))

# get account to authorise and check if valid
foreign = input('Please enter the account name for ACTIVE authorization: ')
if (foreign == account.name):
  print('Cannot allow or disallow active permission to your own account')
  exit()

foreign = Account(foreign, blockchain_instance=client)

# check if foreign account already has active auth
title = ''

for auth in account['active']['account_auths']:
  if (auth[0] == foreign.name):
    title = (foreign.name + ' already has active permission. Please choose option from below list')
    options = ['DISALLOW', 'CANCEL']
    break

if (title == ''):
  title = (foreign.name + ' does not yet active permission. Please choose option from below list')
  options = ['ALLOW', 'CANCEL']

option, index = pick(options, title)

if (option == 'CANCEL'):
  print('operation cancelled')
  exit()

if (option == 'ALLOW'):
  account.allow(foreign=foreign.name, weight=1, permission='active', threshold=1)
  print(foreign.name + ' has been granted active permission')
else:
  account.disallow(foreign=foreign.name, permission='active', threshold=1)
  print('active permission for ' + foreign.name + ' has been removed')
