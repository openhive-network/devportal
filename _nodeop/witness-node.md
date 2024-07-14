---
title: titles.witness_node
position: 13
description: descriptions.witness_node
exclude: true
layout: full
canonical_url: witness-node.html
---

### Intro

Witnesses are crucial part for decentralization of the Hive blockchain. In this guide, we will share how to build and start witness node.
Anyone who has some technical knowledge can setup witness node and start contributing to decentralization and be part of consensus, start earning some rewards.

If you prefer a docker version of these instructions, please refer to:

[exchangequickstart.md](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/exchangequickstart.md)

### Building hived (Hive blockchain P2P node)

Building a hived node requires at least 16GB of RAM.

A hived node is built using CMake.

By default, Ninja is used as the build executor. Ninja supports parallel compilation and by default will allow up to N simultaneous compiles where N is the number of CPU cores on your build system.

If your build system has a lot of cores and not a lot of memory, you may need to explicitly limit the number of parallel build steps allowed (e.g `ninja -j4` to limit to 4 simultaneous compiles).

Only Linux-based systems are supported as a build and runtime platform. Currently Ubuntu 22.04 LTS is the minimum base OS supported by the build and runtime processes. The build process requires tools available in the default Ubuntu package repository.

#### Getting hive source code

To get the source code, clone a git repository using the following command line:

```
git clone --recurse --branch master https://github.com/openhive-network/hive
```

#### Compile-Time Options (cmake options)

##### CMAKE_BUILD_TYPE=[Release/RelWithDebInfo/Debug]

Specifies whether to build with or without optimizations and without or with
the symbol table for debugging. Unless you are specifically debugging or
running tests, it is recommended to build as Release or at least RelWithDebInfo (which includes debugging symbols, but does not have a significant impact on performance).

##### BUILD_HIVE_TESTNET=[OFF/ON]

Builds hived for use in a private testnet. Also required for building unit tests.

##### HIVE_CONVERTER_BUILD=[ON/OFF]

Builds Hive project in MirrorNet configuration (similar to testnet, but enables importing mainnet data to create a better testing environment).

#### Building hived as a docker image

We ship a Dockerfile.

```
    mkdir workdir
    cd workdir # use an out-of-source build directory to keep the source directory clean
    ../hive/scripts/ci-helpers/build_instance.sh my-tag ../hive registry.gitlab.syncad.com/hive/hive
```

`build_instance.sh` has optional parameters:
- `--network-type` specifies the type of P2P network supported by the hived node being built. Allowed values are:
    - mainnet (default)
    - mirrornet
    - testnet

- `--export-binaries=PATH` - extracts the built binaries from the created docker image

The example command above will build an image named `registry.gitlab.syncad.com/hive/hive/instance:my-tag`

To run the given image, you can use a helper script:

```
    ../hive/scripts/run_hived_img.sh registry.gitlab.syncad.com/hive/hive/instance:my-tag --name=hived-instance --data-dir=/home/hive/datadir --shared-file-dir=/home/hive/datadir
```

#### Building native binaries on Ubuntu 22.04 LTS

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
- The developers normally compile with gcc and clang. These compilers should
  be well-supported.
- Community members occasionally attempt to compile the code with mingw,
  Intel and Microsoft compilers. These compilers may work, but the
  developers do not use them. Pull requests fixing warnings / errors from
  these compilers are accepted.

### Configure witness node

After building `hived`, witness or consensus node require `config.ini` file which could be auto generated on first run of `./hived`.
You can start and stop node immediately which will create config.ini and all necessary files/folders, modify `config.ini` and start node again.
Code repository reference for [example.config.ini](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/example_config.ini).

Example of config for witness node:

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

