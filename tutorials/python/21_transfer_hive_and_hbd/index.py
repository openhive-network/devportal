from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Active Key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# get account balance for HIVE and HBD
account = Account(account, blockchain_instance=client)
total_base = account['balance']
total_debt = account['hbd_balance']
base_symbol = total_base.symbol
debt_symbol = total_debt.symbol

print('CURRENT ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')

# get recipient name
recipient = input('Enter the user you wish to transfer funds to: ')

# check for valid recipient name
recipient = Account(recipient, blockchain_instance=client)

if recipient:
    # choice of transfer
    title = 'Please choose transfer type: '
    options = [base_symbol, debt_symbol, 'Cancel Transfer']
    # get index and selected transfer type
    option, index = pick(options, title)
else:
    print('Invalid recipient for funds transfer')
    exit()

if option == 'Cancel Transfer':
    print('Transaction cancelled')
    exit()

if option == base_symbol:
  # get HIVE transfer amount
  amount = input('Enter amount of ' + base_symbol + ' to transfer to ' + recipient.name + ': ')
  amount = float(amount)
  symbol = base_symbol
else:
  # get HBD transfer amount
  amount = input('Enter amount of ' + debt_symbol + ' to transfer to ' + recipient.name + ': ')
  amount = float(amount)
  symbol = debt_symbol

account.transfer(recipient.name, amount, symbol)

print('\n' + str(amount) + ' ' + symbol + ' has been transferred to ' + recipient.name)

# get remaining account balance for HIVE and HBD
account = Account(account.name, blockchain_instance=client)
total_base = account['balance']
total_debt = account['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + str(total_base) + '\n' + str(total_debt) + '\n')
