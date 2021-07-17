---
title: 'RB: Convert HBD to Hive'
position: 32
description: "How to convert your HBD to HIVE using Ruby."
layout: full
canonical_url: convert_hbd_to_hive.html
---
Full, runnable src of [Convert HBD to Hive](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/32_convert_hbd_to_hive) can be downloaded as part of: [tutorials/ruby](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-32_convert_hbd_to_hive.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/32_convert_hbd_to_hive)).

Also see:
* [convert_operation]({{ '/apidefinitions/#broadcast_ops_convert' | relative_url }})

### Sections

1. [Making the api call](#making-the-api-call) - broadcasting the operation
    1. [Example api call](#example-api-call) - make the call in code
    1. [Example api call using script](#example-api-call-using-script) - using our tutorial script
    1. [Example Output](#example-output) - output from a successful call
    1. [Example Error](#example-error) - error output from a unsuccessful call
1. [Convert Fields](#convert-fields) - understanding the result
1. [To Run](#to-run) - Running the example.

### Making the api call

[`vote_on_content.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/17_vote_on_content/vote_on_content.rb)

To broadcast the operation, we can use a `Radiator::Transaction` instance:

```ruby
tx = Radiator::Transaction.new


tx.process(true)
```

Passing `true` to `Radiator::Transaction#process` will broadcast the operations queued in the `operations` array of the transaction.

#### Example api call

If we want to convert, for example:

```ruby
tx.operations << {
  type: :convert,
  owner: owner,
  requestid: requestid,
  amount: amount
}
```

#### Example api call using script

And to do the same with our tutorial script:

```bash
ruby convert_hbd_to_hive.rb
```

#### Example Output

From the example we get the following output from our script:

```json
{
  "jsonrpc": "2.0",
  "result": {
    "id": "e658349eeaa8e941fe232ee0aff0da7ecfadd726",
    "block_num": 44835272,
    "trx_num": 0,
    "expired": false
  },
  "id": 10
}
```

The response we get after broadcasting the transaction gives us the transaction id ([`244a67b...`](https://hiveblocks.com/tx/e658349eeaa8e941fe232ee0aff0da7ecfadd726)), block number ([`44835272`](https://hiveblocks.com/b/44835272)), and the transaction number of that block (`0`).

### Example Error

If an invalid asset is given (e.g.: `HBD` is for mainnet; 'TBD' is for testnet), we will get back an error:

```json
{
  "code": -32003,
  "message": "Assert Exception:false: Cannot parse asset symbol",
  "data": {
    "code": 10,
    "name": "assert_exception",
    "message": "Assert Exception",
    "stack": [
      {
        "context": {
          "level": "error",
          "file": "condenser_api_legacy_asset.cpp",
          "line": 66,
          "method": "string_to_asset_num",
          "hostname": "",
          "timestamp": "2021-06-29T01:13:43"
        },
        "format": "false: Cannot parse asset symbol",
        "data": {
        }
      },
      {
        "context": {
          "level": "warn",
          "file": "condenser_api_legacy_asset.cpp",
          "line": 197,
          "method": "from_string",
          "hostname": "",
          "timestamp": "2021-06-29T01:13:43"
        },
        "format": "",
        "data": {
          "from": "10.000 HBD"
        }
      }
    ]
  }
}
```

This indicates that the convert was not included in the blockchain because it was given an invalid asset argument.

### Convert Fields

Broadcasting a `convert` operation will require the following fields:

* `owner` - account that is doing the convert op
* `requestid` - conversion request identifier
* `amount` - amount of HBD to convert

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started.html' | relative_url }}).  Then you can create and execute the script (or clone from this repository) with the following arguments:

{% include local-testnet.html %}

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/32_convert_hbd_to_hive
bundle install
ruby convert_hbd_to_hive.rb
```
