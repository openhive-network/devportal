import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# connect node and private active key
client = Hive('http://127.0.0.1:8091', keys=[wif_active_key])

# check valid user and get account balance
account = Account(account, blockchain_instance=client)
balance = account['balance']
symbol = balance.symbol

print('Available balance: ' + str(balance) + '\n')

input('Press any key to continue')

# choice of account
title = 'Please choose an option for an account to power up: '
options = ['SELF', 'OTHER']
# get index and selected transfer type
option, index = pick(options, title)

if (option == 'OTHER') :
  # account to power up to
  to_account = input('Please enter the ACCOUNT to where the ' + symbol + ' will be powered up: ')
  to_account = Account(to_account, blockchain_instance=client)
else :
  print('\n' + 'Power up ' + symbol + ' to own account' + '\n')
  to_account = account

# amount to power up
amount = float(input('Please enter the amount of ' + symbol + ' to power up: ') or '0')

# parameters: amount, to, account
if (amount == 0) :
  print('\n' + 'No ' + symbol + ' entered for powering up')
  exit()

if (amount > balance) :
  print('\n' + 'Insufficient funds available')
  exit()

account.transfer_to_vesting(amount, to_account.name)
print('\n' + str(amount) + ' ' + symbol + ' has been powered up successfully to ' + to_account.name)

# get new account balance
account.refresh()
balance = account['balance']
print('New balance: ' + str(balance))

