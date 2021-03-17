from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# connect node and private active key
client = Hive('http://127.0.0.1:8091', keys=[wif_active_key])

# get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)
total_hive = account['balance']
total_hbd = account['hbd_balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_hive) + '\n' + str(total_hbd) + '\n')

# get recipient name
convert_amount = float(input('Enter the amount of HBD to convert to HIVE: ') or '0')

if (convert_amount <= 0):
  print("Must be greater than zero.")
  exit()

# parameters: amount, request_id
account.convert(convert_amount)

print('\n' + format(convert_amount, '.3f') + ' HBD has been converted to HIVE')

# get remaining account balance for HIVE and HBD
account.refresh()
total_hive = account['balance']
total_hbd = account['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_hive) + '\n' + str(total_hbd))

