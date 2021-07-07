import getpass
import json
from beem import Hive
from beem.account import Account
from beemgraphenebase.account import PasswordKey, PrivateKey
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Account_update

account = input('Account: ')
old_password = getpass.getpass('Current password: ')
new_password = getpass.getpass('New password: ')

if getpass.getpass('Confirm New password: ') != new_password:
  print('New password did not confirm.')
  exit()

wif_old_owner_key = str(
  PasswordKey(account, old_password, "owner").get_private_key()
)

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

client = Hive(node_url, keys=[wif_old_owner_key])

account = Account(account, blockchain_instance=client)
new_public_keys = {}

for role in ["owner", "active", "posting", "memo"]:
  private_key = PasswordKey(account.name, new_password, role).get_private_key()
  new_public_keys[role] = str(private_key.pubkey)

new_data = {
  "account": account.name,
  "json_metadata": json.dumps(account.json_metadata),
  "owner": {
    "key_auths": [
      [new_public_keys["owner"], 1]
    ],
    "account_auths": account['owner']['account_auths'],
    "weight_threshold": 1
  },
  "active": {
    "key_auths": [
      [new_public_keys["active"], 1]
    ],
    "account_auths": account['active']['account_auths'],
    "weight_threshold": 1
  },
  "posting": {
    "key_auths": [
      [new_public_keys["posting"], 1]
    ],
    "account_auths": account['posting']['account_auths'],
    "weight_threshold": 1
  },
  "memo_key": new_public_keys["memo"]
}

print("New data:")
print(new_data)

tx = TransactionBuilder(blockchain_instance=client)
tx.appendOps(Account_update(**new_data))

tx.appendWif(wif_old_owner_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Account updated successfully: " + str(broadcast_tx))
