---
title: 'PY: Password Key Change'
position: 34
description: "How to change your accounts password and keys"
layout: full
canonical_url: password_key_change.html
---
Full, runnable src of [Password Key Change](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/34_password_key_change) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-34_password_key_change.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/34_password_key_change)).

In this tutorial we will explain and show you how to change your account password and keys on the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to update your account details on the blockchain.  We are using the [`Account_update`](https://beem.readthedocs.io/en/latest/beembase.operationids.html?highlight=Account_update#beembase-operationids) operation and [`TransactionBuilder`](https://beem.readthedocs.io/en/latest/beem.transactionbuilder.html#beem.transactionbuilder.TransactionBuilder) to make these changes.  We first get the existing keys from your account then recreate these from your new password. Once these have been created using your new password we commit them to the blockchain.

Also see:
* [account_update_operation]({{ '/apidefinitions/#broadcast_ops_account_update' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to production
1. [**User input**](#input) - Input user and limit parameters
1. [**Connect to the blockchain**](#connection) - Connect to the blockchain using the parameters collected from the user
1. [**Configure new keys**](#configure) - Setup the new json object that will have the new keys derived from your new password
1. [**Commit changes to blockchain**](#commit) - Commit the account update to the blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use the following packages:

- `beem` - hive library and interaction with Blockchain
- `json` - to dump an object as a string

We import the libraries and get parameters from the user.

```python
import getpass
import json
from beem import Hive
from beem.account import Account
from beemgraphenebase.account import PasswordKey, PrivateKey
from beem.transactionbuilder import TransactionBuilder
from beembase.operations import Account_update
```

### 2. User input<a name="input"></a>

You will first be asked for the account that we will be modifying the password for.  You will then be prompted to enter your existing password as well as your new password that we will update your account with.

```python
account = input('Account: ')
old_password = getpass.getpass('Current password: ')
new_password = getpass.getpass('New password: ')

if getpass.getpass('Confirm New password: ') != new_password:
  print('New password did not confirm.')
  exit()
```

### 3. Connect to the blockchain<a name="connection"></a>

From the parameters that have been collected we will generate the private key for the account and connect to the **Hive** blockchain. 

```python
wif_old_owner_key = str(
  PasswordKey(account, old_password, "owner").get_private_key()
)

client = Hive('http://127.0.0.1:8090', keys=[wif_old_owner_key])

account = Account(account, blockchain_instance=client)
```

### 4. Configure new keys<a name="configure"></a>

We will now generate new keys for each role using the new password as well as re-create the json that will be committed to the **Hive** blockchain.  We generate new keys using the new password for each of these roles.

```python
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
```

#### 5. Commit changes to blockchain <a name="commit"></a>

The `tx.appendOps(Account_update(**new_data))` call creates the operation that will be committed to the blockchain using the new json object we have created.

```python
tx = TransactionBuilder(blockchain_instance=client)
tx.appendOps(Account_update(**new_data))

tx.appendWif(wif_old_owner_key)
signed_tx = tx.sign()
broadcast_tx = tx.broadcast(trx_id=True)

print("Account updated successfully: " + str(broadcast_tx))
```

If you update your password and attempt to update it again to quickly you will receive the following error.

```
Assert Exception:_db.head_block_time() - account_auth.last_owner_update > HIVE_OWNER_UPDATE_LIMIT: Owner authority can only be updated once an hour.
```

You will need to wait at least an hour before attempting this again.

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/34_password_key_change`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
