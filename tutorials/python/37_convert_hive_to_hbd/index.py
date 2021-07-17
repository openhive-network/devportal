from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Enter private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)
total_hbd = account['hbd_balance']
total_hive = account['balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_hbd) + '\n' + str(total_hive) + '\n')

# get recipient name
convert_amount = float(input('Enter the amount of HIVE to convert to HBD: ') or '0')

if (convert_amount <= 0):
  print("Must be greater than zero.")
  exit()

# parameters: amount, request_id
account.collateralized_convert(convert_amount)

print('\n' + format(convert_amount, '.3f') + ' HIVE has been converted to HBD')

# get remaining account balance for HBD and HIVE
account.refresh()
total_hbd = account['hbd_balance']
total_hive = account['balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_hbd) + '\n' + str(total_hive))

