import getpass
import beembase
from beem.account import Account
from beem import Hive
from beem.transactionbuilder import TransactionBuilder
from beemgraphenebase.account import PasswordKey
from beembase.objects import Permission

# capture user information
account = input('account to be recovered: ')
old_password = getpass.getpass('recent password for account: ')
new_password = getpass.getpass('new password for account: ')

recovery_account = input('account owner (recovery account name): ')
recovery_account_private_key = getpass.getpass('account owner private ACTIVE key: ')

client = Hive('http://127.0.0.1:8091', keys=[recovery_account_private_key])
account = Account(account, blockchain_instance=client)
recovery_account = Account(recovery_account, blockchain_instance=client)

# create new account owner keys
new_account_owner_private_key = PasswordKey(account.name, new_password, role='owner').get_private_key()
new_account_owner_private_key_string = str(new_account_owner_private_key)
new_account_owner_public_key = str(new_account_owner_private_key.pubkey)

# create old account owner keys
old_account_owner_private_key = PasswordKey(account.name, old_password, role='owner').get_private_key()
old_account_owner_private_key_string = str(old_account_owner_private_key)
old_account_owner_public_key = str(old_account_owner_private_key.pubkey)

# owner key format
new_owner_authority = {
  "key_auths": [
    [new_account_owner_public_key, 1]
  ],
  "account_auths": [],
  "weight_threshold": 1
}

# recovery request data object creation
request_op_data = {
  'account_to_recover': account.name,
  'recovery_account': recovery_account.name,
  'new_owner_authority': new_owner_authority,
  'extensions': []
}

# recovery request operation creation
request_op = beembase.operations.Request_account_recovery(**request_op_data)

print('request_op_data')
print(request_op_data)

# recovery request broadcast
request_result = client.finalizeOp(request_op, recovery_account.name, "active")

print('request_result')
print(request_result)

# owner key format
recent_owner_authority = {
  "key_auths": [
    [old_account_owner_public_key, 1]
  ],
  "account_auths": [],
  "weight_threshold": 1
}

# recover account data object
op_recover_account_data = {
  'account_to_recover': account.name,
  'new_owner_authority': new_owner_authority,
  'recent_owner_authority': recent_owner_authority,
  'extensions': []
}

# account keys update data object
op_account_update_data = {
  "account": account.name,
  "active": {
    "key_auths": [
      [str(PasswordKey(account.name, new_password, role='active').get_private_key().pubkey), 1]
    ],
    "account_auths": [],
    "weight_threshold": 1
  },
  "posting": {
    "key_auths": [
      [str(PasswordKey(account.name, new_password, role='posting').get_private_key().pubkey), 1]
    ],
    "account_auths": [],
    "weight_threshold": 1
  },
  "memo_key": str(PasswordKey(account.name, new_password, role='memo').get_private_key().pubkey),
  "json_metadata": ""
}

# recover account initialisation and transmission
client = Hive('http://127.0.0.1:8091', keys=[recovery_account_private_key])

op_recover_account = beembase.operations.Recover_account(**op_recover_account_data)

print('op_recover_account')
print(op_recover_account)

tb = TransactionBuilder(blockchain_instance=client)
tb.appendOps([op_recover_account])
tb.appendWif(str(old_account_owner_private_key))
tb.appendWif(str(new_account_owner_private_key))
tb.sign()

result = tb.broadcast()
print('result')
print(result)

# update account keys initialisation and transmission
client = Hive('http://127.0.0.1:8091', keys=[new_account_owner_private_key])

op_account_update = beembase.operations.Account_update(**op_account_update_data)

print('op_account_update')
print(op_account_update)

tb = TransactionBuilder(blockchain_instance=client)
tb.appendOps([op_account_update])
tb.appendWif(str(new_account_owner_private_key))
tb.sign()

result = tb.broadcast()

print('result')
print(result)

