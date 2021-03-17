from pick import pick
import getpass
from beem import Hive
from beem.account import Account
import random

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# connect node and private active key
client = Hive('http://127.0.0.1:8091', keys=[wif_active_key])

# check for valid account and get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)

total_base = account['balance']
total_debt = account['hbd_balance']
savings_base = account['savings_balance']
savings_debt = account['savings_hbd_balance']

symbol_base = total_base.symbol
symbol_debt = total_debt.symbol

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
print('CURRENT SAVINGS BALANCE:' + '\n' + str(savings_base) + '\n' + str(savings_debt) + '\n')

input('Press enter to continue with the transfer' + '\n')

# choice of transfer/withdrawal
title1 = 'Please choose transfer type: '
options1 = ['Transfer', 'Withdrawal', 'Cancel']
# get index and selected transfer type
transfer_type, index = pick(options1, title1)

if transfer_type == 'Cancel':
  print('Transaction cancelled')
  exit()

# choice of currency
title2 = 'Please choose currency: '
options2 = [symbol_base, symbol_debt]
# get index and selected currency
asset, index = pick(options2, title2)

if asset == symbol_base:
  # get HIVE transfer amount
  amount = float(input('Enter amount of ' + symbol_base + ' to transfer: ') or '0')
else:
  # get HBD transfer amount
  amount = float(input('Enter amount of ' + symbol_debt + ' to transfer: ') or '0')

if transfer_type == 'Transfer':
  account.transfer_to_savings(amount, asset, '')
  print('\n' + 'Transfer to savings balance successful')
else:
  # create request ID random integer
  request_id = random.randint(1,1000000)
  account.transfer_from_savings(amount, asset, '', request_id=request_id)
  print('\n' + 'Withdrawal from savings successful, transaction ID: ' + str(request_id))

# get remaining account balance for HIVE and HBD
account.refresh()
total_base = account['balance']
total_debt = account['hbd_balance']
savings_base = account['savings_balance']
savings_debt = account['savings_hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
print('CURRENT SAVINGS BALANCE:' + '\n' + str(savings_base) + '\n' + str(savings_debt) + '\n')

