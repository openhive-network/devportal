---
title: Hive Testnet
position: 3
exclude: true
---

Hive blockchain software is written in C++ and in order to modify the source code you need some understanding of the C++ programming language. Each Hive node runs an instance of this software, so in order to test your changes, you will need to know how to install dependencies which can be found in the [Hive repo](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md). This also means that some knowledge of System administration is also required. There are multiple advantages of running a testnet, you can test your scripts or applications on a testnet without extra spam on the live network, which allows much more flexibility to try new things. Having access to a testnet also helps you to work on new features and possibly submit new or improved pull requests to official the Hive GitHub repository.

## Public Testnet

> The Hive Public Testnet is maintained to aid developers who want to rapidly test their applications.  Unless your account was created very recently, you should be able to participate in the testnet using your own mainnet account and keys (though please be careful, if you leak your key during testnet, your mainnet account will be compromised).

* Chain ID: `18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e`
* P2P: `testnet.openhive.network:2001`
* API: `https://testnet.openhive.network`
* Condenser: [testblog.openhive.network](https://testblog.openhive.network/)
* Wallet: [testwallet.openhive.network](https://testwallet.openhive.network/)

Also see: [hive.blog/hive-139531/@gtg/hf25-public-testnet-reloaded-rc2](https://hive.blog/hive-139531/@gtg/hf25-public-testnet-reloaded-rc2)

## Running a Private Testnet Node

Alternatively, if you would like to run a private local testnet, you can get up and running with docker:

```bash
docker run -d -p 8090:8090 inertia/tintoy:latest
```

For details on running a local testnet, see: [Setting Up a Testnet]({{ '/nodeop/setting-up-a-testnet.html' | relative_url }})
