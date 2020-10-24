import steembase
import steem

# connect to testnet
steembase.chains.known_chains['HIVE'] = {
    'chain_id': '79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673',
    'prefix': 'STX', 'hive_symbol': 'HIVE', 'hbd_symbol': 'HBD', 'vests_symbol': 'VESTS'
}

#capture user information
username = input('Enter username: ') #demo account: demo01
wif = input('Enter private ACTIVE key: ') #demo account: 5HxTntgeoLm4trnTz94YBsY6MpAap1qRVXEKsU5n1v2du1gAgVH

#connect node and private active key
client = steem.Hive(nodes=['https://testnet.steem.vc'], keys=[wif])

#get account balance for HIVE and HBD
userinfo = client.get_account(username)
total_hive = userinfo['balance']
total_hbd = userinfo['hbd_balance']

print('CURRENT ACCOUNT BALANCE:' + '\n' + total_hive + '\n' + total_hbd + '\n')

#get recipient name
convert_amount = input('Enter the amount of HBD to convert to HIVE: ') #must be > 0

#parameters: amount, account, request_id
client.convert(float(convert_amount), username)

print('\n' + convert_amount + ' HBD has been converted to HIVE')

#get remaining account balance for HIVE and HBD
userinfo = client.get_account(username)
total_hive = userinfo['balance']
total_hbd = userinfo['hbd_balance']

print('\n' + 'REMAINING ACCOUNT BALANCE:' + '\n' + total_hive + '\n' + total_hbd)