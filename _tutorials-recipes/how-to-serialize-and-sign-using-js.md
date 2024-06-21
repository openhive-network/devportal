---
title: titles.how_to_serialize
position: 1
description: Serialization and signing without additional Hive Javascript libraries.
exclude: true
layout: hive-post
canonical_url: https://hive.blog/steem/@mahdiyari/how-to-serialize-and-sign-steem-transactions-using-javascript-without-steem-javascript-libraries
---

<center>
  <img src="https://images.hive.blog/1536x0/https://cdn.steemitimages.com/DQmdV8sZiyYpz8qq1WJErHKfgZgPyuZsBgtuzwkhoP8DED2/document-428334_640.jpg" />
</center>

When you are sending HIVE or HBD to another account, when you are writing a post or a comment, or when you are voting or downvoting a post, you are broadcasting transactions into the Hive blockchain. In other words, any action you take on Hive blockchain is a transaction.

#### What makes transactions so special?
A transaction needs to be signed by the account owner and verified by the blockchain before including in the blocks. Without a signature, the transaction will be rejected by the blockchain.

You may ask "why signing? isn't there another way?"
Without using signatures, blockchain needs a way to authenticate users before broadcasting transactions. And for authenticating users, there must be a key included in the request that sent to the blockchain.

As you know, sending keys over to a server that claims to be a blockchain node is risky. Since anyone can run a blockchain node and capture keys. Of course, we can't trust the blockchain that lacks security.

With the help of encryption, we can sign transactions on our own hardware and send signed transactions securely to any server. A signed transaction doesn't include any key. Just a signature that proves the transaction is coming from the account owner.

#### How to broadcast transactions?
Broadcasting a transaction is pretty easy.
But before broadcasting, the transaction must be signed.
And for signing a transaction, the transaction must be serialized.

#### Available documents:
- [Transaction signing in a nutshell](https://hive.blog/@xeroc/steem-transaction-signing-in-a-nutshell) by @xeroc (3 years ago - Python)

I couldn't find anything else.

#### Available libraries(JS):
- [hive-js](https://gitlab.syncad.com/hive/hive-js)
- [dhive](https://gitlab.syncad.com/hive/dhive)
- [hive-tx](https://github.com/mahdiyari/hive-tx-js)

hive-js and dhive both are working in most cases.
But I couldn't use hive-js nor dhive on the Nativescript environment (framework for Android and IOS applications). So I created Hive-TX. A complete but light library. Hive-TX should work in almost every situation.

I will explain things that are not available directly anywhere else. If you don't understand any part, just comment below. (or maybe google it 🤷)

***
# Step 1
#### Creating Transaction:
As you know, a transaction consists of 6 variables inside an object:
```
const transaction = {
  ref_block_num: Number,
  ref_block_prefix: Number,
  expiration: Date,
  operations: Array,
  extensions: Array,
  signatures: Array
}
```

We will fill this object by the end of the post. 

@xeroc explained most of the properties. Check [this post](https://hive.blog/@xeroc/steem-transaction-signing-in-a-nutshell) for explanation of variables.

Defining 4 of 6 needed variables:
```
const props = getDynamicGlobalProperties()
const refBlockNum = props.head_block_number & 0xffff
const refBlockPrefix = Buffer.from(props.head_block_id, 'hex').readUInt32LE(4)
const expireTime = 1000 * 60
const expiration = new Date(Date.now() + expireTime)
    .toISOString()
    .slice(0, -5)
const extensions = []
```

Without operations, there is no transaction!
You can include one or more operations in this array. Check [broadcast-ops]({{ '/apidefinitions/#apidefinitions-broadcast-ops' | relative_url }}) for list of all available operations.
```
const operations = [
  [
    'vote',
    {
      voter: 'guest123',
      author: 'guest123',
      permlink: '20191107t125713486z-post',
      weight: 9900
    }
  ]
]
```
#### Transaction is created:

```
const transaction = {
  ref_block_num: refBlockNum,
  ref_block_prefix: refBlockPrefix,
  expiration,
  operations,
  extensions
}
```
The only missing part is `signatures`

***
# Step 2
#### Serializing transaction:

Create a new ByteBuffer:
```
const ByteBuffer = require('bytebuffer')
const buffer = new ByteBuffer(
    ByteBuffer.DEFAULT_CAPACITY,
    ByteBuffer.LITTLE_ENDIAN
  )
```
Every variable should be serialized according to the data type of its value.

We will use the following serialization for transaction object:

- ref_block_num => UInt16 (16bit unsigned integer)
- ref_block_prefix & expiration => UInt32 (32bit unsigned integer)
- operations: 
voter & author & permlink => VString (varint32 prefixed UTF8 encoded string)
weight => Int16 (16bit signed integer)
- extensions => VString

Also, you need operation_id of operation. operation_id is the position of the operation defined in the Hive blockchain. [`operations.hpp`](https://gitlab.syncad.com/hive/hive/-/blob/master/libraries/protocol/include/hive/protocol/operations.hpp) is the list of operations on the Hive blockchain.
```
vote_operation: 0
comment_operation: 1
transfer_operation: 2
...
```

The code:
```
buffer.writeUInt16(refBlockNum)
buffer.writeUInt32(refBlockPrefix)
buffer.writeUInt32(expiration)
buffer.writeVarint32(operations.length) // number of operations
buffer.writeVarint32(0) // operation id
buffer.writeVString(voter)
buffer.writeVString(author)
buffer.writeVString(permlink)
buffer.writeInt16(weight)
buffer.writeVarint32(extensions.length) // number of extensions
// in case of any extensions
// buffer.writeVString(extensions[0])
```

The serialized transaction is ready.

***
# Step 3
#### Create Digest from Transaction:

First, convert byte buffer to the actual buffer:
```
buffer.flip() // set offset = 0
const transactionData = Buffer.from(buffer.toBuffer())
```
Create SHA256 hash of transactionData and chain id (digest):
```
const chainId = 'beeab0de00000000000000000000000000000000000000000000000000000000'
const CHAIN_ID = Buffer.from(chainId, 'hex')

const input = Buffer.concat([CHAIN_ID, transactionData])
```
You have 2 options here:
- crypto-js
```
const CryptoJS = require('crypto-js')
const wa = CryptoJS.lib.WordArray.create(input)
const digest = Buffer.from(
    CryptoJS.SHA256(wa).toString(CryptoJS.enc.Hex),
    'hex'
  )
```
- crypto
```
const crypto = require('crypto')
const digest = crypto.createHash('sha256').update(input).digest()
```
<b>USE ONLY ONE OF ABOVE (`crypto-js` or `crypto`)</b>

I used crypto-js in Hive-TX but you can use whichever that works for you. The code for `crypto` is also commented out in Hive-TX which can be easily replaced with `crypto-js`.

Now prepare private key:
```
const bs58 = require('bs58')
const key = '5JRaypasxMx1L97ZUX7YuC5Psb5EAbF821kkAGtBj7xCJFQcbLg'
const keyBuffer = bs58.decode(key)
const privateKey = keyBuffer.slice(0, -4).slice(1)
```

With digest and private key, we can finally sign the transaction.

***
# Step 4
#### Sign the Transaction:

We will use this function in the signing process to verify the signature ([why?](https://hive.blog/@dantheman/steem-and-bitshares-cryptographic-security-update)):

```
const isCanonicalSignature = signature => {
  return (
    !(signature[0] & 0x80) &&
    !(signature[0] === 0 && !(signature[1] & 0x80)) &&
    !(signature[32] & 0x80) &&
    !(signature[32] === 0 && !(signature[33] & 0x80))
  )
}
```

We can sign the transaction with more than one key in the case of multi-signature accounts (aka multisig). Just repeat the process of signing for the signedTransaction.



```
const signedTransaction = { ...transaction } // copy transaction object
if (!signedTransaction.signatures) {
  signedTransaction.signatures = []
}

// repeat for multi-signature accounts
const secp256k1 = require('secp256k1')
let rv = {}
let attempts = 0
do {
  const input = Buffer.concat([digest, Buffer.alloc(1, ++attempts)])
  const wa = CryptoJS.lib.WordArray.create(input)
  const options = {
    data: Buffer.from(
      CryptoJS.SHA256(wa).toString(CryptoJS.enc.Hex),
      'hex'
    )
  }
  rv = secp256k1.sign(digest, privateKey, options)
} while (!isCanonicalSignature(rv.signature))
const signature = {signature: rv.signature, recovery: rv.recovery}

```
Finally, the transaction is signed!
But, we must convert the signature into the string and include in the transaction object:

```
const sigBuffer = Buffer.alloc(65)
sigBuffer.writeUInt8(signature.recovery + 31, 0)
signature.signature.copy(buffer, 1)
const stringSignature = sigBuffer.toString('hex')
signedTransaction.signatures.push(stringSignature)
```

**Note**: It is often useful for the client to determine what the transaction id will be before broadcast.  This is optional because once broadcasted, the node will return the transaction id.  To determine the transaction id (`trx_id`) *before* the next step (broadcast), see:

[Understanding Transaction Status :: Client-side Computation]({{ '/tutorials-recipes/understanding-transaction-status.html#client-side-computation' | relative_url }})

# Step 5
#### Broadcast the Transaction:
`signedTransaction` is ready to be broadcasted into the blockchain using `Condenser Api` and `broadcast_transaction_synchronous` method.

If you understand all the steps from 1 to 4, I think you should know how to make a post-call to a Hive node and broadcast the transaction. In case you don't, check the [broadcast transaction]({{ '/apidefinitions/#condenser_api.broadcast_transaction_synchronous' | relative_url }}) method.

You can use any library. I used `axios` to broadcast transaction:
```
const axios = require('axios')
const node = 'https://api.hive.blog'
const call = async (method, params = []) => {
  const res = await axios.post(
    node,
    JSON.stringify({
      jsonrpc: '2.0',
      method,
      params,
      id: 1
    })
  )
  if (res && res.statusText === 'OK') {
    return res.data
  }
}

const result = await call('condenser_api.broadcast_transaction_synchronous', [
  signedTransaction
])
console.log(result)
```

***
## Conclusion:

After reading or writing this code you will appreciate the software that is doing all this process behind the scene when you are clicking on the upvote button.

You don't have to write this code from scratch. [hive-tx](https://github.com/mahdiyari/hive-tx-js) is already coded in the same way.  See the [announcement post](https://hive.blog/hive-139531/@mahdiyari/hive-js-and-hive-tx-migration-to-hive-breaking-changes-for-browsers).

---

*Adapted from an [article](https://hive.blog/@mahdiyari/how-to-serialize-and-sign-steem-transactions-using-javascript-without-steem-javascript-libraries) by [@mahdiyari](https://hive.blog/@mahdiyari)*
