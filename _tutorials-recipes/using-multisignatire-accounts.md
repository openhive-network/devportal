---
title: Using Multisignature Accounts
position: 1
description: How to set up and use multisignature accounts on Hive Blockchain.
exclude: true
layout: hive-post
---
<center>
  <img src="https://images.hive.blog/1536x0/https://steemitimages.com/640x0/https://cdn.steemitimages.com/DQme59Hypf9j6W186aPhDKoeaRSKRMe4yLvNFemZXeuy9q8/image.png" /><br />
	<sup>Image: Skitterphoto, CC0</sup>
</center>
	
#### Repository

[https://github.com/holgern/beem](https://github.com/holgern/beem)

This post is a contribution to the [Multisignature Transaction Guide](https://hive.blog/@timcliff/steem-developer-bounty-1500-steem-multisignature-transaction-guide-details-inside) request by [@timcliff](https://hive.blog/@timcliff).

---

*Edit: In the meantime, beem/beempy was adjusted to support the full procedure out-of-the-box. For a ready-to-use CLI interface for multi-sig coming with beem, please refer to:
[Multisignature Transaction Guide for beempy](https://hive.blog/@holger80/multisignature-transaction-guide-for-beempy)*

---

#### What Will I Learn?

- You will learn how to set-up a multi-signature authority for Hive accounts
- You will learn how to prepare a transaction to be signed by multiple keys
- You will learn how to sign transactions with multiple keys and broadcast it to the chain

#### Requirements

The user must have a basic understanding of the Hive key and account authority system as well as the corresponding weights and thresholds. The user should be familiar with Python and using Python scripts on the command line. Some knowledge about [beem](https://github.com/holgern/beem) is required to go beyond the provided example.

#### Difficulty
Advanced

---

#### Setting up a multi-signature authority Hive account

The @hiveio account is an example of an account that has multiple key authorities for each role:

<center>
  <img src="https://images.hive.blog/1536x0/https://ipfs.busy.org/ipfs/Qmey6EuUPcscSPoCJTNMx6x2R1nNnKMZ6P4tCmV3dR8LoN" />
</center>

Blockchain transactions sent in the name of the @hiveio account can be signed by any of the two keys per role (owner/active/posting). While this account has multiple authorities, it is not a multi-signature account since the threshold parameter on each role is set to 1 - this means that a signature with weight 1 is sufficient to authorize the transaction.
An account becomes a multi-signature account as soon as the weight of a single signature is not sufficient to reach the threshold. Here is an example of a multi-sig account where this condition is fulfilled:

<center>
  <img src="https://images.hive.blog/1536x0/https://ipfs.busy.org/ipfs/QmTbTCagz39yLo8u9jhT6M276sQarAuQ8inPCVTcCn9wwH" />
</center>

This account has an active threshold of 40 while each of the authorized keys can provide a weight of at most 25 or 10. This means that transactions requiring the active authority need to be signed by multiple of the authorized keys.

---

##### How to set an account into this state with beem

In order to set owner, active or posting authorities, weights and thresholds, the `Account_update` function from `beembase.operations` is needed. The operation can be prepared in the following way:

```python
from beem.account import Account
from beembase import operations
acc = Account("accountname")
op = operations.Account_update(**{
    "account": acc["name"],
    'active': acc["active"],
    'posting': acc["posting"],
    'memo_key': acc['memo_key'],
    "json_metadata": acc['json_metadata'],
    "prefix": acc.hive.prefix})
```

`acc["posting"]` and `acc["active"]` are dictionaries in the style of:
```
authority = {
  'account_auths': [], 
  'key_auths': [
    ['STMKEY1...', 25], 
    ['STMKEY2...', 10]],
  'address_auths': [], 
  'weight_threshold': 100, 
  'prefix': acc.hive.prefix}
```

(adjust the keys, the weights and the threshold accordingly). Make sure that the sum of the individual weights reaches or exceeds the threshold, otherwise no combination of multiple signatures will be able to work with the active authority.

This operation can then be submitted with a `TransactionBuilder` instance:

```python
from beem.transactionbuilder import TransactionBuilder
tb = TransactionBuilder(blockchain_instance=acc.hive)
tb.appendOps([op])
tb.appendWif(owner_wif)
tb.sign()
tx = tb.broadcast()
print(tx)
```
Since this is modifying the active authority of the account, this operation has to be signed with the owner key. The same concept also applies to the posting authorities, but changing those only required the corresponding active key.

The result is what is shown in the screenshot above and was carried out with the @test.auth account.

**A basic, but ready-to-use script to set arbitrary active and posting authorities is provided here**:

[set_authorities.py](https://gist.github.com/crokkon/17e5be82d9ef073bcee80a461a11dea9#file-set_authorities-py)

This script can be used like this:
```bash
python set_authorities.py \
  --account test.auth \
  --role active \
  --threshold 40 \
  --key-weight STM7JNWU2b2DBMp9WZRGHKqE7hQA9MKn2URLBCMfU95p29vzAQn8F 25 \
  --key-weight STM5iLWNocQk8UDUVpuGytJkmLiEuK9XYvyMH3yYRdXhW6qGqbWA4 25 \
  --key-weight STM6qpVTxhWBuKUFgUHgymuQrtRwZ16bWmyZVf7ba4QzoYypEXS5X 10 \
  --key-weight STM8Hp2EPPgddvQRGYUFomX5v8ixh1LeoFKk3FCTxMwkSvzieGrDg 10 \
  --key-weight STM75MGQ6WLhSqNoUYsm6oXeGp3R5KPpaKgtoLUHTtcS5vhrWmrtJ 10 \
  --key-weight STM6Ukq4htXhnkKDdR45XgCLJY8a8eJV9ndUmLBT32ktPzYdvqPJy 10 \
  --key-weight STM6AFxvirq6P1XTeiYEwfTCMXivJsg9wmZDBrWxG5fQkvgzRZwHX 10
```
Supported `--role` parameters are `active` and `posting`. The `--key-weight` parameter takes a space-separated pair of a pubkey and a weight. There is also an `--account-weight` parameter taking an account name plus weight. Note that there is an upper limit of 40 authorities (keys and accounts combined) per role.

This is the resulting transaction from this script:

<center>
  <img src="https://images.hive.blog/1536x0/https://ipfs.busy.org/ipfs/QmNeiJmtrtRWXnr8yv3KY5MQig4ysE5vP6ua7wvpeHdo5b" />
</center>

Edit: the same state can be achieved via multiple`beempy` commands as suggested by @tcpolymath in the comments, e.g.:
```
$ beempy allow -a "test.auth" --permission active --weight 25 --threshold 40 STM7JNWU2b2DBMp9WZRGHKqE7hQA9MKn2URLBCMfU95p29vzAQn8F
```

---

##### How to prepare a transaction to be signed by multiple keys?

Transaction that are sent to the blockchain have the following format:
```
{"expiration": "2019-01-04T21:05:55", "ref_block_num": 6032, "ref_block_prefix": 1020164711, "operations": [["transfer", {"from": "test.auth", "to": "test.auth", "amount": "0.001 HIVE", "memo": ""}]], "extensions": [], "signatures": []}
```
`expiration` defines how long the transaction is going to be valid. Typical numbers are 1 minute (beem default), the maximum allowed by the blockchain is 1 hour. Since not all signatures are added instantly, choosing a longer period is reasonable in this case. `ref_block_num` and `ref_block_prefix` are values that the blockchain provides on request. The `operations` parameter contains the desired user operation (in this case transferring 0.001 HIVE to self). `extensions` is typically empty. `signatures` is a list of strings that is filled by signing this operation. In case of a "normal" transaction, the final signature filed would contain a lengthy string of characters and numbers. Multiple signatures can be achieved by signing the same operation with multiple keys independently, and list all resulting signatures in the `signatures` field.

In order to create such a base transaction, we can again use the `TransactionBuilder` class:
```python
op = operations.Transfer(**{
    'from': args.account,
    'to': args.to,
    'amount': Amount(args.amount, args.asset),
    'memo': args.memo
})
hive = Hive(expiration=3600)
tb = TransactionBuilder(blockchain_instance=hive)
tb.appendOps([op])
print("'%s'" % (json.dumps(tb.json())))
```
(note the override of the expiration period to 1h = 3600s). The resulting output was the transaction string shown above.

**A basic, but ready-to-use script to create an arbitrary transfer transaction is provided here**:

[get_transaction.py](https://gist.github.com/crokkon/17e5be82d9ef073bcee80a461a11dea9#file-get_transaction-py)

This script can be used like this:
```
python get_transaction.py \
  --account test.auth \
	--to test.auth \
	--amount 0.001 \
	--asset HIVE
```
an optional `--memo` parameter allows you to set a transfer memo as well.

Edit: also this stage can be done directly via `beempy`:
```
$ beempy -e 3600 --no-broadcast --unsigned transfer --account "test.auth" "test.auth" 0.001 HIVE
```

--- 

##### How to sign this transaction now with multiple keys and broadcast it to the chain?

Signing this transaction means appending an entry to the `signatures` list of the transaction. This signature can be obtained by loading the above transaction with the `TransactionBuilder` class, append a private key and use the `sign()` method. Each time this step is done, another signature is appended to the list:
```python
tb = TransactionBuilder(tx=op)
tb.appendWif(wif)
tb.sign(reconstruct_tx=False)
```
Important here is that the transaction has to be passed to the `TransactionBuilder` constructor and the `sign` method has to be instructed **not to** reconstruct the transaction but take it as it is. If this parameter is not set, the class will strip off existing signatures and update `expiration`, `ref_block_num` and `ref_block_prefix` to the current values.

Once the required number of signatures is appended to meet or exceed the threshold, the transaction can be broadcasted:
```python
tx = tb.broadcast()
```

**A basic, but ready-to-use script to sign transaction with multiple keys and broadcast it to the chain is provided here:**

[sign_and_broadcast.py](https://gist.github.com/crokkon/17e5be82d9ef073bcee80a461a11dea9#file-sign_and_broadcast-py)

This script can be used like shown below. The same script is fed multiple times with the output of the previous step each. This ensures, that the same transaction can be signed successively by independent people and broadcasted as soon as the weight threshold is reached:
```bash
# first signature: run with the trx created above:
$ python sign_and_broadcast.py --append-sig --trx '{"expiration": "2019-01-04T22:13:41", "ref_block_num": 7386, "ref_block_prefix": 3706177428, "operations": [["transfer", {"from": "test.auth", "to": "test.auth", "amount": "0.001 HIVE", "memo": ""}]], "extensions": [], "signatures": []}'
Enter private key:
'{"expiration": "2019-01-04T22:13:41", "ref_block_num": 7386, "ref_block_prefix": 3706177428, "operations": [["transfer", {"from": "test.auth", "to": "test.auth", "amount": "0.001 HIVE", "memo": ""}]], "extensions": [], "signatures": ["1f65df7e3fb5f3ad49c433054127d71918c10865d67367efa380edee2e9943540d1e6f97317a1cdfe547f49d89048a44bd2f9a9a7278e51b9fef98dfddaee576da"]}'

# second signature - run the same script with the output of step 1 - note the two sigs in the output:
$ python sign_and_broadcast.py --append-sig --trx '{"expiration": "2019-01-04T22:13:41", "ref_block_num": 7386, "ref_block_prefix": 3706177428, "operations": [["transfer", {"from": "test.auth", "to": "test.auth", "amount": "0.001 HIVE", "memo": ""}]], "extensions": [], "signatures": ["1f65df7e3fb5f3ad49c433054127d71918c10865d67367efa380edee2e9943540d1e6f97317a1cdfe547f49d89048a44bd2f9a9a7278e51b9fef98dfddaee576da"]}'
Enter private key:
'{"expiration": "2019-01-04T22:13:41", "ref_block_num": 7386, "ref_block_prefix": 3706177428, "operations": [["transfer", {"from": "test.auth", "to": "test.auth", "amount": "0.001 HIVE", "memo": ""}]], "extensions": [], "signatures": ["1f65df7e3fb5f3ad49c433054127d71918c10865d67367efa380edee2e9943540d1e6f97317a1cdfe547f49d89048a44bd2f9a9a7278e51b9fef98dfddaee576da", "205d6e432fa276f0ef7c5da90703811d01b1358348ec5c1de5bd1504b7990d4f42121542d5d555a8fbb974db316d84714f7da2c43a5160bc00548fda6b15c33687"]}'

# third signature: run the same script with the output of step 2, add the --broadcast parameter and note the three sigs in the output:
$ python sign_and_broadcast.py --append-sig --trx '{"expiration": "2019-01-04T22:13:41", "ref_block_num": 7386, "ref_block_prefix": 3706177428, "operations": [["transfer", {"from": "test.auth", "to": "test.auth", "amount": "0.001 HIVE", "memo": ""}]], "extensions": [], "signatures": ["1f65df7e3fb5f3ad49c433054127d71918c10865d67367efa380edee2e9943540d1e6f97317a1cdfe547f49d89048a44bd2f9a9a7278e51b9fef98dfddaee576da", "205d6e432fa276f0ef7c5da90703811d01b1358348ec5c1de5bd1504b7990d4f42121542d5d555a8fbb974db316d84714f7da2c43a5160bc00548fda6b15c33687"]}' --broadcast
Enter private key:
SUCCESS: broadcasted '{
  "expiration": "2019-01-04T22:13:41",
  "ref_block_num": 7386,
  "ref_block_prefix": 3706177428,
  "operations": [
    [
      "transfer",
      {
        "from": "test.auth",
        "to": "test.auth",
        "amount": "0.001 HIVE",
        "memo": ""
      }
    ]
  ],
  "extensions": [],
  "signatures": [
    "1f65df7e3fb5f3ad49c433054127d71918c10865d67367efa380edee2e9943540d1e6f97317a1cdfe547f49d89048a44bd2f9a9a7278e51b9fef98dfddaee576da",
    "205d6e432fa276f0ef7c5da90703811d01b1358348ec5c1de5bd1504b7990d4f42121542d5d555a8fbb974db316d84714f7da2c43a5160bc00548fda6b15c33687",
    "20049d276c86a99d472d4962dc1adbf26a6cf2bdf56a87eae74a19d19394081a9a4b0f89f89dd1c632dcee13b2f688303cbf3f2f2e85ea587c88e9ff9dd66b7c8f"
  ]
}'
```

here's the resulting transaction on hived:

https://hiveblocks.com/tx/5d1124e30b20c47f31517848500636cf7ec2e886

<center>
  <img src="https://images.hive.blog/1536x0/https://ipfs.busy.org/ipfs/QmdSjjL4TtCqMwrdfJhXL2HfyRgxnFTfgeWPVHNfjaq6Vq" />
</center>

And an example transferring 0.001 HIVE to my account with 4 signatures as required when using only the keys with weight=10:

https://hiveblocks.com/tx/ae16ba50728536b6a3a10ace03cb82512a51f6b4

<center>
  <img src="https://images.hive.blog/1536x0/https://cdn.steemitimages.com/DQmbSHNXy7Ue7dqBxZwoLmQkSDqUii3jshputHrgpQMctqG/Screenshot_trx4.png" />
</center>

(this step is currently not yet possible with `beempy`, but there is work in progress to fully integrate all steps)

---

#### Further thoughts:
* A big limitation for mass adoption of multi-sig is the fact that the maximum transaction expiration time can only be 1h at most. This can be a at least annoying or even a problem if multiple people that live in different time zones or have a life outside of Hive have to work together to reach the signature threshold.
* Even with a multi-sig active authority, transfers can still be done with the owner authority (currently requiring only one sig with the example account).
* However, the exact same concept can be applied to the owner authority as well. This has to be done carefully, since a mistake there could render the account unusable and the funds locked. With access to the recovery partner's active key, it could still be recovered, though.
* For the signing and broadcasting part, there is currently no automated check if the required number of signatures to meet or exceed the threshold is reached, but this could be implemented by reconstructing the signers of the existing signatures and checking their weight against the required threshold.

#### Proof of Work Done

All code shown here is available as a GitHub Gist:

[https://gist.github.com/crokkon/17e5be82d9ef073bcee80a461a11dea9](https://gist.github.com/crokkon/17e5be82d9ef073bcee80a461a11dea9)

---

*Adapted from an [article](https://hive.blog/@crokkon/steem-multi-signature-transaction-guide-for-beem-python-1546636997324) by [@crokkon](https://hive.blog/@crokkon)*
