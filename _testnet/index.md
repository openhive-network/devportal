---
title: titles.testnet
position: 3
layout: full
---

A Hive testnet is a separate blockchain for testing applications, node changes, and transaction flows without broadcasting to mainnet. Start with the [testnet setup guide](/nodeop/setting-up-a-testnet.html) for a local Docker deployment or an introduction to Tinman's tools.

### Features

A testnet can start with a small set of test accounts or import account data from a mainnet snapshot. [Tinman](https://gitlab.syncad.com/hive/tinman) provides the maintained `snapshot → txgen → keysub → submit` pipeline for importing accounts and allocating test balances.

An account snapshot does not copy the mainnet block log or all historical posts. Tinman adds a manager authority to imported accounts, adjusts balances to the testnet's funding plan, and enforces the target's authority limits. Imported authorities are therefore not necessarily identical to mainnet authorities.

The optional [`gatling` module](https://gitlab.syncad.com/hive/tinman#gatling-transactions-from-mainnet) can replay selected mainnet activity. It is not required to run a testnet, and transactions depending on missing posts or other state may not be reproducible.

## Running Testnet

[Tin Toy](https://hub.docker.com/r/inertia/tintoy) provides a small local testnet with a sample snapshot and configured witnesses. The [Docker quickstart](/nodeop/setting-up-a-testnet.html#docker-quickstart) specifies the image version, AMD64 platform, RPC port, and checks for block production.

For native builds, follow the [Hive build guide](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md) and enable `BUILD_HIVE_TESTNET=ON`. Current native build instructions target Linux with Ubuntu 24.04 LTS or later and require at least 16 GB RAM for compilation. Runtime and disk requirements depend on the snapshot, enabled plugins, and chain history.

Building a testnet binary does not automatically join an existing development network. Peers must agree on the chain ID, genesis configuration, protocol, and network parameters. Use the network operator's configuration when joining an existing testnet.

## Custom Testnet

Use the selected Hive revision's [testnet configuration](https://gitlab.syncad.com/hive/hive/-/blob/master/libraries/protocol/include/hive/protocol/config.hpp) and build documentation when changing genesis supply, chain identity, keys, or witness requirements. Build the signing utilities from the same revision and network configuration as the node.

Inspect the running node through `database_api.get_config`, `database_api.get_version`, `database_api.get_hardfork_properties`, and `database_api.get_witness_schedule`. Binary version, active hardfork, and median account-creation fee are separate properties; read them from the target instead of assuming a zero fee or a fixed historical hardfork.

Hive asset amounts use integer units. For precision-3 HIVE, an amount of `250000000000` represents 250,000,000 HIVE. Tinman's genesis funding plan must cover imported balances, system accounts, and account-creation fees within the actual available supply.

Testnet keys and manager authorities are for testing. Keep local RPC endpoints private and never use test keys to hold mainnet funds. For supported Python versions, pinned Hive images, and bootstrap validation, see [Tinman's compatibility guide](https://gitlab.syncad.com/hive/tinman/-/blob/master/COMPATIBILITY.md).
