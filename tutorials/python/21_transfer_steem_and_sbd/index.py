import steembase
import steem
from pick import pick

# connect to testnet
steembase.chains.known_chains['HIVE'] = {
    'chain_id': '79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673',
    'prefix': 'STX', 'hive_symbol': 'HIVE', 'hbd_symbol': 'HBD', 'vests_symbol': 'VESTS'
}

#capture user information
username = input('Enter username: ') #demo account: cdemo
wif = input('Enter private ACTIVE key: ') #demo account: 5KaNM84WWSqzwKzY82fXPaUW43idbLnPqf5SfjGxLfw6eV2kAP3

#connect node and private active key
client = steem.Hive(nodes=['https://testnet.steem.vc'], keys=[wif])

#get account balance for HIVE and HBD
userinfo = client.get_account(username)
total_hive = userinfo['balance']
total_hbd = userinfo['hbd_balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + total_hive + '\n' + total_hbd + '\n')

#get recipient name
recipient = input('Enter the user you wish to transfer funds to: ')

#check for valid recipient name
result = client.get_account(recipient)

if result:
    #choice of transfer
    title = 'Please choose transfer type: '
    options = ['HIVE', 'HBD', 'Cancel Transfer']
    # get index and selected transfer type
    option, index = pick(options, title)
else:
    print('Invalid recipient for funds transfer')
    exit()

if option == 'Cancel Transfer':
    print('Transaction cancelled')
    exit()
else:
    if option == 'HIVE':
        #get HIVE transfer amount
        amount = input('Enter amount of HIVE to transfer to ' + recipient + ': ')
        asset = 'HIVE'
    else:
        #get HBD transfer amount
        amount = input('Enter amount of HBD to transfer to ' + recipient + ': ')
        asset = 'HBD'

#parameters: to, amount, asset, memo='', account
client.transfer(recipient, float(amount), asset, '', username)
print('\n' + amount + ' ' + asset + ' has been transferred to ' + recipient)

#get remaining account balance for HIVE and HBD
userinfo = client.get_account(username)
total_hive = userinfo['balance']
total_hbd = userinfo['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + total_hive + '\n' + total_hbd + '\n')