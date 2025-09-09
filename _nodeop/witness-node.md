---
title: titles.witness_node
position: 13
description: descriptions.witness_node
exclude: true
layout: full
canonical_url: witness-node.html
---

### Intro

Witnesses (aka block producers) are a crucial part for the decentralization of the Hive blockchain. In this guide, we will share how to build and start a witness node. Anyone who has some technical knowledge can set up a witness node and start contributing to the decentralization, be part of consensus, and start earning some rewards.

If you prefer a docker version of these instructions, please refer to:

[exchangequickstart.md](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/exchangequickstart.md)

### Building hived (Hive blockchain P2P node)

The Hive blockchain P2P node software is called `hived`. Building a hived node requires at least 16GB of RAM.

Only Linux-based systems are supported as a build and runtime platform. Currently Ubuntu 22.04 LTS is the minimum base OS supported by the build and runtime processes. The build process requires tools available in the default Ubuntu package repository.

#### Getting hive source code

The first step is to get the source code. Clone the git repository using the following command:

```
git clone --recurse --branch master https://github.com/openhive-network/hive
```

#### Building hived as a docker image

Probably the easiest way to build hived is as a docker image. Use the `build_instance.sh` helper script to build the image (you would typically change `my-tag` to the hived version number, for example `1.27.8`):

```
    ../hive/scripts/ci-helpers/build_instance.sh my-tag ../hive registry.gitlab.syncad.com/hive/hive
```

<details><summary>Expand build_instance.sh optional parameters</summary>

- `--network-type` specifies the type of P2P network supported by the hived node being built. Allowed values are:
    - mainnet (default)
    - mirrornet
    - testnet

- `--export-binaries=PATH` - extracts the built binaries from the created docker image

</details>

The example command above will build an image named `registry.gitlab.syncad.com/hive/hive/instance:my-tag`

To run the given image, you can use the `run_hived_img.sh` helper script:

```
    ../hive/scripts/run_hived_img.sh registry.gitlab.syncad.com/hive/hive/instance:my-tag --name=hived-instance --data-dir=/home/hived/datadir --shared-file-dir=/home/hived/shm_dir --detach --preserve-container
```

To stop, use `docker stop hived-instance`. A successfully stopped docker container should leave the message ***exited cleanly***. 


#### Building native binaries on Ubuntu 22.04 LTS

You may alternatively prefer to build hived as a native binary. A hived node is built using CMake.

By default, Ninja is used as the build executor. Ninja supports parallel compilation and by default will allow up to N simultaneous compiles where N is the number of CPU cores on your build system.

If your build system has a lot of cores and not a lot of memory, you may need to explicitly limit the number of parallel build steps allowed (e.g `ninja -j4` to limit to 4 simultaneous compiles).

#### Compile-Time Options (cmake options)

##### CMAKE_BUILD_TYPE=[Release/RelWithDebInfo/Debug]

Specifies whether to build with or without optimizations and without or with
the symbol table for debugging. Unless you are specifically debugging or
running tests, it is recommended to build as Release or at least RelWithDebInfo (which includes debugging symbols, but does not have a significant impact on performance).

##### BUILD_HIVE_TESTNET=[OFF/ON]

Builds hived for use in a private testnet. Also required for building unit tests.

##### HIVE_CONVERTER_BUILD=[ON/OFF]

Builds Hive project in MirrorNet configuration (similar to testnet, but enables importing mainnet data to create a better testing environment).

##### Prerequisites

Run the script below, or based on its contents, manually install the required packages:

```
    sudo ../hive/scripts/setup_ubuntu.sh --dev
```

##### Configure cmake

```
    mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -GNinja ../hive
```

##### Build with Ninja

To start the build process, simply run:

```
    ninja
```

Or if you want to build only specific binary targets use:

```
    ninja hived cli_wallet
```

**If at any time you find this documentation not up-to-date or imprecise, please take a look at the CI/CD scripts in the scripts/ci-helpers directory.**

#### Building on Other Platforms

- macOS instructions are old and obsolete, feel free to contribute.
- Windows build instructions do not exist yet.
- The developers normally compile with gcc and clang. These compilers should be well-supported.
- Community members occasionally attempt to compile the code with mingw, Intel and Microsoft compilers. These compilers may work, but the developers do not use them. Pull requests fixing warnings / errors from these compilers are accepted.

### Configure the witness node

After building `hived`, the witness or consensus node requires a `config.ini` file and the directories `data-dir` and `shared-file-dir`. `config.ini` has various configuration settings for the node, `data-dir` is where the `block_log` file containing all blockchain history will be put, and `shared-file-dir` is where the file containing the blockchain state will be put. If you use an NVMe, you can keep `shared-file-dir` on disc, otherwise it is recommended to keep it in memory. 

These can be auto-generated on the first run of hived. Simply start and then immediately stop the node and this will generate the file and two directories. (Code repository reference for [example.config.ini](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/example_config.ini).)

<details><summary>Expand example config.ini for a witness node:</summary>

```
#################################################################################
#                                                                               #
#                 CHAIN STATE CONFIGURATION (SHARED MEM ETC.)                   #
#                                                                               #
#################################################################################

# Shared file size
shared-file-size = 25G
shared-file-dir = /shm/

# A 2-precision percentage (0-10000) that defines the threshold for when to 
# autoscale the shared memory file. Setting this to 0 disables autoscaling. 
# The recommended value for consensus node is 9500 (95%). Full node is 9900 (99%).
shared-file-full-threshold = 9500

# A 2-precision percentage (0-10000) that defines how quickly to scale the shared memory file. 
# When autoscaling occurs, the file's size will be increased by this percentage. 
# Setting this to 0 disables autoscaling. The recommended value is between 1000 and 2000 (10-20%).
shared-file-scale-rate = 1000

# Target blocks to flush
flush = 1000
# flush shared memory changes to disk every N blocks
# flush-state-interval = 

#################################################################################
#                                                                               #
#                        PLUGIN/RPC CONFIGURATION                               #
#                                                                               #
#################################################################################

# Plugin(s) to enable, may be specified multiple times
plugin = witness 
# required for creating and importing Hive 1.24+ State Snapshots
plugin = state_snapshot

#################################################################################
#                                                                               #
#                           WITNESS CONFIGURATION                               #
#                                                                               #
#################################################################################

# name of witness controlled by this node (e.g. initwitness )
# the username MUST be wrapped in double quotes.
# Example: witness = "someguy123"
# witness =

# WIF PRIVATE KEY to be used by one or more witnesses or miners
# Use cli_wallet and the command 'suggest_brain_key'
# to generate a random private key. Enter the wif_priv_key here.
# Example: private-key = 5JFyopMgaXJJycEaJcoch7RygGMhhEjBC6jxCovWtshFDGq7Nw4
# private-key =

# Skip enforcing bandwidth restrictions. Default is true in favor of rc_plugin.
witness-skip-enforce-bandwidth = 1

# Enable block production, even if the chain is stale.
enable-stale-production = 0

# Percent of witnesses (0-99) that must be participating in order to produce blocks
required-participation = 33


#################################################################################
#                                                                               #
#                     NETWORK CONFIGURATION (SEEDS/PORTS)                       #
#                                                                               #
#################################################################################

# Endpoint for P2P node to listen on
p2p-endpoint = 0.0.0.0:2001

# Maxmimum number of incoming connections on P2P endpoint
p2p-max-connections = 200

# Endpoint for websocket RPC to listen on
webserver-http-endpoint = 0.0.0.0:8091
webserver-ws-endpoint = 0.0.0.0:8090
# Local unix http endpoint for webserver requests.
# webserver-unix-endpoint = 
# Enable the RFC-7692 permessage-deflate extension for the WebSocket server (only used if the client requests it).  This may save bandwidth at the expense of CPU
# webserver-enable-permessage-deflate = 

# Local http and websocket endpoint for webserver requests. Deprecated in favor of webserver-http-endpoint and webserver-ws-endpoint
# rpc-endpoint = 

# P2P network parameters. (Default: {"listen_endpoint":"0.0.0.0:0","accept_incoming_connections":true,"wait_if_endpoint_is_busy":true,"private_key":"0000000000000000000000000000000000000000000000000000000000000000","desired_number_of_connections":20,"maximum_number_of_connections":200,"peer_connection_retry_timeout":30,"peer_inactivity_timeout":5,"peer_advertising_disabled":false,"maximum_number_of_blocks_to_handle_at_one_time":200,"maximum_number_of_sync_blocks_to_prefetch":2000,"maximum_blocks_per_peer_during_syncing":200,"active_ignored_request_timeout_microseconds":6000000} )
# p2p-parameters = 


# If you plan to use this server as an actual RPC node with a moderately high volume of requests,
# then you should increase this - between 64 and 256 are sensible thread pool sizes for an RPC node.
webserver-thread-pool-size = 4

# Endpoint for TLS websocket RPC to listen on
# rpc-tls-endpoint =

# The TLS certificate file for this server
# server-pem =

# Password for this certificate
# server-pem-password =

# API user specification, may be specified multiple times
# api-user =

############################ SEEDS ############################

# P2P nodes to connect to on startup (may specify multiple times)
p2p-seed-node = api.hive.blog:2001              # blocktrades
p2p-seed-node = seed.openhive.network:2001      # gtg
p2p-seed-node = seed.ecency.com:2001            # good-karma
p2p-seed-node = rpc.ausbit.dev:2001             # ausbitbank
p2p-seed-node = hive-seed.roelandp.nl:2001      # roelandp
p2p-seed-node = hive-seed.arcange.eu:2001       # arcange
p2p-seed-node = anyx.io:2001                    # anyx
p2p-seed-node = hived.splinterlands.com:2001    # aggroed
p2p-seed-node = seed.hive.blue:2001             # guiltyparties
p2p-seed-node = hive-api.3speak.tv:2001         # threespeak
p2p-seed-node = node.mahdiyari.info:2001        # mahdiyari
p2p-seed-node = hive-seed.lukestokes.info:2001  # lukestokes.mhth
p2p-seed-node = api.deathwing.me:2001           # deathwing
p2p-seed-node = seed.liondani.com:2016          # liondani
p2p-seed-node = hiveseed-se.privex.io:2001      # privex
p2p-seed-node = seed.mintrawa.com:2001          # mintrawa
p2p-seed-node = hiveseed.rishipanthee.com:2001  # rishi556


############################  END SEEDS ############################

# Pairs of [BLOCK_NUM,BLOCK_ID] that should be enforced as checkpoints.
# checkpoint =

# Block signing key to use for init witnesses, overrides genesis file
# dbg-init-key =

# Defines a range of accounts to track as a json pair ["from","to"] [from,to)
# track-account-range =

# Disables automatic account history trimming
history-disable-pruning = 0

# Where to export data (NONE to discard)
block-data-export-file = NONE

# How often to print out block_log_info (default 1 day)
# 5 mins
block-log-info-print-interval-seconds = 300

# Whether to defer printing until block is irreversible
block-log-info-print-irreversible = 1

# Where to print (filename or special sink ILOG, STDOUT, STDERR)
block-log-info-print-file = ILOG

# Set the maximum size of cached feed for an account
follow-max-feed-size = 500

# Block time (in epoch seconds) when to start calculating feeds
follow-start-feeds = 0

# json-rpc log directory name.
# log-json-rpc = 

# Skip rejecting transactions when account has insufficient RCs. This is not recommended.
rc-skip-reject-not-enough-rc = 0

# Generate historical resource credits
rc-compute-historical-rc = 0

# The location (root-dir) of the snapshot storage, to save/read portable state dumps
snapshot-root-dir = "snapshot"

# Endpoint to send statsd messages to.
# statsd-endpoint = 

# Size to batch statsd messages.
statsd-batchsize = 1

# Whitelist of statistics to capture.
# statsd-whitelist = 

# Blacklist of statistics to capture.
# statsd-blacklist = 

# Block time (in epoch seconds) when to start calculating promoted content. Should be 1 week prior to current time.
tags-start-promoted = 0

# Skip updating tags on startup. Can safely be skipped when starting a previously running node. Should not be skipped when reindexing.
tags-skip-startup-update = 0

# Defines the number of blocks from the head block that transaction statuses will be tracked.
transaction-status-block-depth = 64000

# Defines the block number the transaction status plugin will begin tracking.
transaction-status-track-after-block = 0


#################################################################################
#                                                                               #
#                           LOGGING CONFIGURATION                               #
#                                                                               #
#################################################################################

# Whether to print backtrace on SIGSEGV
backtrace = yes

log-appender = {"appender":"stderr","stream":"std_error"} {"appender":"p2p","file":"logs/p2p/p2p.log"}
# Console appender definition json: {"appender", "stream"}
#log-appender = {"appender":"stderr","stream":"std_error"}

# File appender definition json:  {"appender", "file"}
#log-appender = {"appender":"p2p","file":"logs/p2p/p2p.log"}

# Logger definition json: {"name", "level", "appender"}
log-logger = {"name":"default","level":"info","appender":"stderr"} {"name":"user","level":"debug","appender":"stderr"} {"name":"p2p","level":"warn","appender":"p2p"}
```

</details>

To provide a value for the `private-key` setting of config.ini, we first need to generate a witness key pair. We can do this using the CLI wallet. 


### Using the CLI wallet

hived comes with a CLI wallet which can be used to sign and broadcast transactions. To use the CLI wallet, you need a running instance of hived. So run your hived instance and then use this helper script to run the CLI wallet:

```
    /home/hived/hive/scripts/run_cli_wallet_img.sh hived-instance
```

The wallet will initially ask you to set up a password. It will create a `wallet.json` file in the hived data-dir directory and will use the password to encrypt this file with any keys stored there. So be sure to save your password and then set up the wallet with it - use the `set_password` command and provide your password as the argument:

```
    set_password my_very_strong_password
```

After the initial setup, you can unlock your wallet with:

```
    unlock my_very_strong_password
```

Then use `suggest_brain_key` to generate a public/private key pair to serve as your witness keys. 

```
    suggest_brain_key
```

Save these keys. Then exit the wallet:

```
    exit
```


### Running your node as a witness

Note: if you are running hived in docker and aren't connected with the docker container via ssh, you can always re-connect with:

```
    docker exec -it hived-instance /bin/sh
```

To perform your witness functions, you need your private witness key in your node.  Find the `private-key` setting in `config.ini` and add there your private witness key generated in the CLI wallet section above. It should be without quotes. 

For the `witness` setting, put your witness account name, with quotes. 

Review all other `config.ini` settings and after you are satisfied with them, run your hived node again. It may ask you to force replay, in which case you can add the `--force-replay` option to the command for running hived. 

When you run your node, it will begin downloading the blockchain history from the beginning from other nodes and will put it in the block_log file. It will also validate each transaction in sequence from the beginning. When you make changes to `config.ini`, depending on the change, it will require re-validating the transactions again from the beginning of history - this is called 'replaying'. It takes a while so you will want to finalize your `config.ini` settings and then run the node and leave it until it has replayed all history until the present moment. Making another change may require replaying again. 

While it is replaying, you will see this on the hived logs output:

```
    Got block: #10000
```


When it has reached the present moment, it will show:

```
    Got 32 transactions on block 91000000
```

If at any point you have closed the terminal, you can connect to the hived logs output again with (if you are running hived in docker):

```
    docker logs --follow hived-instance
```

When you have reached present time and everything is working smoothly, it's time to activate your witness.


### Activating your witness

Without activating, your node will only independently validate each block and transaction. After you have activated your witness, the network will assign blocks to you to validate for the entire network. The more stake-weighted votes your witness gets, the higher it will go in the ranking and the more blocks will be assigned to it. The network gives a reward for each block assigned and successfully validated. 

To activate your witness, first connect to your CLI wallet. Then import into it your account's private active key (this will enable you to sign transactions with it):

```
    import_key your_private_active_key
```

Now we are ready to sign the transaction for activating the witness. But for this we need a CLI wallet that is connected to a hived node which has enabled some specific additional plugins besides the `witness` plugin. To do this, we can instruct our CLI wallet to connect to a remote hived node which has those plugins enabled. api.openhive.network is one such node and the following command will connect to it:

```
    /home/hived/hive/scripts/run_cli_wallet_img.sh hived-instance -sws://api.openhive.network:8090
```

The connection to the remote server may die quickly so you may need to re-connect if you haven't executed the activating command fast enough. To activate, we use the [witness_update](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/devs/operations/11_witness_update.md) operation:

```
    update_witness "your_account_name" "https://example.com" "your_public_witness_key" {"account_creation_fee":"3.000 HIVE","maximum_block_size":65536,"hbd_interest_rate":0} true
```

The second argument is the URL where people can read about your witness. The fourth argument is a JSON with network parameters. You have to be familiar with the network's workings and current state in order to determine what values you want to specify for these parameters. The documentation for them is here: [witness network parameters](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/witness_parameters.md)

You can update your values for these parameters at any time by issuing a [witness_set_properties](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/devs/operations/42_witness_set_properties.md) operation.

After activation, your account will appear in the list of witnesses (it may need some stake to vote for it before it becomes visible in the long tail of the list). Until you sign your first block, the hived version you are running will show as `0.0.0`.


### Setting your price feed

One of the useful activities witnesses perform is to regularly publish a price feed which is used to calculate the ratio between HIVE and HBD. There are a few software packages made by the community that you can choose from and install for this purpose:

- https://github.com/someguy123/hivefeed-js
- https://github.com/therealwolf42/hive-witness-essentials
- https://github.com/Jolly-Pirate/pricefeed


### Avoiding missing blocks

Each witness has a count of missed blocks - the number of times it was assigned a block by the network but missed validating it. You will want to keep your missed blocks number low by taking measures to keep your witness node online and functioning properly. Some of the above software packages can help with that. If for any reason you expect your node to be down or it is currently down, you can temporarily set your witness public key to  `STM1111111111111111111111111111111114T1Anm` so that you will not be scheduled for block production:

```
    update_witness "your_account_name" "https://example.com" "STM1111111111111111111111111111111114T1Anm" {"account_creation_fee":"3.000 HIVE","maximum_block_size":65536,"hbd_interest_rate":0} true
```