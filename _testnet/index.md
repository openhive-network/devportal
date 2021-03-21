---
title: Hive Testnet
position: 3
layout: full
---

Hive blockchain software is written in C++ and in order to modify the source code you need some understanding of the C++ programming language. Each Hive node runs an instance of this software, so in order to test your changes, you will need to know how to install dependencies which can be found in the [Hive repo](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md). This also means that some knowledge of System administration is also required. There are multiple advantages of running a testnet, you can test your scripts or applications on a testnet without extra spam on the live network, which allows much more flexibility to try new things. 
Having access to a testnet also helps you to work on new features and possibly submit new or improved pull requests to official the Hive GitHub repository.

### Features

A Hive testnet is a mirror of the mainnet.  This is achieved by copying the existing accounts and transactions from the mainnet state, as the they happen.  Accounts are copied from a [snapshot](https://gitlab.syncad.com/hive/tinman#taking-a-snapshot) of mainnet while the module used to copy transactions in real time is called [`gatling`](https://gitlab.syncad.com/hive/tinman#gatling-transactions-from-mainnet).  The `gatling` module runs at the final step of each testnet deployment.

The combination of `snapshot` and `gatling` means that this testnet approaches a subset of the same activity that the mainnet experiences.  Not everything can be mirrored.  For example, if someone comments or votes on a post that hasn't been mirrored to the testnet (because the post itself pre-dates the testnet deploy), those operations will also not be included.

## Running Testnet

By following official [build steps](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md#build_hive_testnetoffon) and enabling the `BUILD_HIVE_TESTNET` flag during compilation, you should be able to run the Hive Testnet locally on your workstation and join the development testnet. Docker can also be used to get started quickly. Compilation generates the `hived` executable which is the main daemon for the Hive network. Additional `cli_wallet` can also be compiled to test/connect to an instance of `hived` and request some data from the network, but it is not necessary to run a node.

The development testnet requires a certain minimum set of hardware requirements, depending on the type of compile flags that have been enabled. Because it is a mirror of the live network, private keys are the same for accounts up to the point of the snapshot timestamp of the testnet.

Joining/Running the development testnet requires around 10 GB for block log on an SSD and 8 GB RAM. The CPU requirements are the same.

Testnet has the following parameters by default (as of this writing):

* Initial supply (250 billion) - `HIVE_INIT_SUPPLY 250,000,000,000`
* Max number of blocks to be produced - `TESTNET_BLOCK_LIMIT 3,000,000`
* Address prefix, prefix on public addresses - `HIVE_ADDRESS_PREFIX "TST"`
* Chain id name, used for chain id - `HIVE_CHAIN_ID_NAME "testnet"`
* Chain id, unique id hash of chain - `HIVE_CHAIN_ID (fc::sha256::hash(HIVE_CHAIN_ID_NAME))`
* Public key of genesis account - `HIVE_INIT_PUBLIC_KEY_STR `
* Account creation fee - `HIVE_MIN_ACCOUNT_CREATION_FEE 0`

There are a number of other subtle changes that we don't need to focus on right now.

## Custom Testnet

In order to create a custom, isolated, testnet we need to modify a few things mentioned in the previous section.

In the file named `hive/libraries/protocol/include/hive/protocol/config.hpp`, we can see the first few lines dedicated to the Testnet section.  The line starts with `#ifdef IS_TEST_NET`.

Let's say we want to create a custom testnet with an initial supply of **1,000,000 HIVE**. We can change `HIVE_INIT_SUPPLY 1,000,000` and by changing `HIVE_CHAIN_ID_NAME "testnet"`, **testnet** to **mytestnet** we will automatically get a unique Chain ID for our testnet. The address prefix can be set to something like **MTN** and of course, we need to change the public and private keys to the genesis account. Note that the genesis account will receive the entire pre-mined supply of 1,000,000.  That way, you can execute a setup script to fund any newly created accounts. Such a custom testnet will not have any additional hardware requirements to run. 

A minimum of 8GB RAM should be sufficient to run a custom testnet. Currently, Hive only has Linux and Mac compiling guides to build. A testnet can either be hosted locally, on a rented AWS, or dedicated bare metal servers so one can start testing functionality, explore different APIs, and start developing.

One more crucial point to modify is to change the number of witnesses required to accept hardforks for a custom testnet, by default it is set to 17, we can change it to **1** `HIVE_HARDFORK_REQUIRED_WITNESSES 1` so that only one node instance would be sufficient and the network will be still functional and fast.

Another thing to note is that you can start a new chain with all previous hardforks already accepted, by changing the file named `hive/blob/master/libraries/chain/database.cpp` with the following function:

`void database::init_genesis( uint64_t init_supply )` inside `try` add this line:

`set_hardfork( 19, true );`

This would mean that 19 hardforks have been accepted by witnesses and the new chain will start with all previous forks included.

After these changes, all we have to do is compile the source code and get the `hived` executable. And once we fire up the custom testnet we can start testing and experimenting.

If you want to port some data from Hive main network you can use [Tinman](https://gitlab.syncad.com/hive/tinman), also developed by the Hive community, to help with taking snapshots of the main network.
