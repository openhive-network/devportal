---
title: titles.account_recovery
position: 35
description: descriptions.account_recovery
layout: full
canonical_url: account_recovery.html
---
Full, runnable src of [Account Recovery](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/35_account_recovery) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-35_account_recovery.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/35_account_recovery)).

In this tutorial we show you how to request account recovery for a user and also recover that account on the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library.

The recovery system is used to recover hacked accounts.  In the event that you lose your password, your account is lost forever.  You must know at least one old password that was used on your account within 30 days.  This recovery process can only be executed once an hour.  Stolen Account Recovery gives the rightful account owner 30 days to recover their account from the moment the thief changed their owner key.

## Intro

There are two parties involved in recovering an account.  The user that requires their account to be recovered, and the recovery account (or trustee) which is the account that created the username on the blockchain.  For example, anyone creating their account through the Peakd webiste, their recovery account would be Peakd.  If however your account was created for you by another user, that user is the one that would have to initialize your account recovery.  The recovery account can be changed however to whichever user you require.

For other recovery options, see: [Hive Account Recovery - Major update and new User Interface](https://peakd.com/@arcange/hive-account-recovery-major-update-and-new-user-interface)

For this tutorial we are using the `beem-python` library which contains the required functions to execute this recovery process.  There are two main sections to this process.  Firstly, there is the `request_account_recovery` function where the owner is verified and the intent for account recovery is transmitted to the blockchain.  The second part is the actual `recover_account` process.  Along with this we also create a complete set of new account keys (posting, active, owner and memo) in order for the account to function properly.  If these keys are not generated you will receive an error when trying to log in with your new password: `This password is bound to your account's owner key and can not be used to login to this site. However, you can use it to update your password to obtain a more secure set of keys`

The `request_account_recovery` function has the following parameters:

1.  _account to recover_ - The account name that wishes to be recovered
1.  _recovery account_ - The trustee account / account owner that will recover the account
1.  _new owner authority_ - The new owner PUBLIC key of the account to be recovered
1.  _extensions_ - empty array

The `recover_account` function has the following parameters:

1.  _account_to_recover_ - The account name that wishes to be recovered
1.  _new_owner_authority_ - The new owner PUBLIC key of the account to be recovered
1.  _recent_owner_authority_ - The OLD owner PUBLIC key of the account to be recovered
1.  _extensions_ - empty array

Also see:
* [request_account_recovery_operation]({{ '/apidefinitions/#broadcast_ops_request_account_recovery' | relative_url }})
* [recover_account_operation]({{ '/apidefinitions/#broadcast_ops_recover_account' | relative_url }})
* [account_update_operation]({{ '/apidefinitions/#broadcast_ops_account_update' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Input user info and connection to production
1. [**Owner key creation**](#owner_key) - Creation of new and old owner keys
1. [**Recovery request operation and transmission**](#recovery_request) - creation of data object, operation and transmission of recovery request function
1. [**Account recovery and new account keys data objects**](#new_keys) - creation of new account keys and objects for account update and recovery
1. [**Account recovery commit**](#recovery_commit) - transmit account recovery to blockchain
1. [**Account update commit**](#account_commit) - transmit account key update to blockchain

#### 1. App setup and connection <a name="setup"></a>

In this tutorial we use 1 packages:

- `beem` - beem-python library and interaction with Blockchain

We import the libraries for the application.

```python
import getpass
import beembase
from beem.account import Account
from beem import Hive
from beem.transactionbuilder import TransactionBuilder
from beemgraphenebase.account import PasswordKey
from beembase.objects import Permission
```

There are 5 inputs required.  The account name to be recovered along with the old and new passwords.  We also require the account name and private active key of the recovery account (account owner / trustee).  For the first step in the process we initialize the beem class with the private key from the recovery account.  The values are supplied via the terminal/console.

```python
# capture user information
account = input('account to be recovered: ')
old_password = getpass.getpass('recent password for account: ')
new_password = getpass.getpass('new password for account: ')

recovery_account = input('account owner (recovery account name): ')
recovery_account_private_key = getpass.getpass('account owner private ACTIVE key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

client = Hive(node_url, keys=[recovery_account_private_key])
account = Account(account, blockchain_instance=client)
recovery_account = Account(recovery_account, blockchain_instance=client)
```

The new password for the account to be recovered must be at least 32 characters long.

#### 2. Owner key creation <a name="owner_key"></a>

Both new and old owner keys are generated from the passwords supplied in the first step.  For a more in depth look at creating keys please refer to [this]({{ '/tutorials-python/password_key_change.html' | relative_url }}) tutorial on changing your password and keys.

```python
# create new account owner keys
new_account_owner_private_key = PasswordKey(account.name, new_password, role='owner').get_private_key()
new_account_owner_private_key_string = str(new_account_owner_private_key)
new_account_owner_public_key = str(new_account_owner_private_key.pubkey)

# create old account owner keys
old_account_owner_private_key = PasswordKey(account.name, old_password, role='owner').get_private_key()
old_account_owner_private_key_string = str(old_account_owner_private_key)
old_account_owner_public_key = str(old_account_owner_private_key.pubkey)
```

The Hive blockchain knows the history of your account, and every owner key that has ever been used for it.  When you enter your recent password, it uses that to generate an owner key that can match up to a previous owner public key on the account.  Without that password and owner key, the recovery account can't do anything to recover your account.

#### 3. Recovery request operation and transmission <a name="recovery_request"></a>

The `new_owner_authority` containing the new public key is formatted in order to be used in the `request_account_recovery` operation.  Once the data object has been created, the operation is transmitted to the blockchain to confirm that the account in question is going to be recovered.

```python
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
```

#### 4. Account recovery and new account keys data objects <a name="new_keys"></a>

The old owner key is formatted and the object for the account recovery function is created with the required parameters.

```python
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
```

The object for the account key update operation is created with the relevant keys created in the correct format within the object.

```python
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
```

#### 5. Account recovery commit <a name="recovery_commit"></a>

The beem class is initialized once more but with the required WIF for this specific section.  This is necessary when different keys are required at various steps.  The `recover_account` function is transmitted to the blockchain via the `TransactionBuilder` operation in order to append the new private keys.  The operation is then broadcast.

```python
# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# recover account initialisation and transmission
client = Hive(node_url, keys=[recovery_account_private_key])

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
```

#### 6. Account update commit <a name="account_commit"></a>

The same basic process is followed as in the previous step.  For this step however we require the new owner private key which is initialized in the beem class.  The `TransactionBuilder` operation is used once more for the transmission to the blockchain.

```python
# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# update account keys initialisation and transmission
client = Hive(node_url, keys=[new_account_owner_private_key])

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
```

Final code:

```python
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
# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

client = Hive(node_url, keys=[recovery_account_private_key])
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

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# recover account initialisation and transmission
client = Hive(node_url, keys=[recovery_account_private_key])

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

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# update account keys initialisation and transmission
client = Hive(node_url, keys=[new_account_owner_private_key])

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

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/35_account_recovery`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
