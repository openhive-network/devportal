---
title: Hive Testnet
position: 3
exclude: true
---

Hive blockchain software is written in C++ and in order to modify the source code you need some understanding of the C++ programming language. Each Hive node runs an instance of this software, so in order to test your changes, you will need to know how to install dependencies which can be found in the [Hive repo](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md). This also means that some knowledge of System administration is also required. There are multiple advantages of running a testnet, you can test your scripts or applications on a testnet without extra spam on the live network, which allows much more flexibility to try new things. Having access to a testnet also helps you to work on new features and possibly submit new or improved pull requests to official the Hive GitHub repository.

## Running a Testnet Node

```bash
docker run -d -p 8090:8090 inertia/tintoy:latest
```

For details on running a local testnet, see: [Setting Up a Testnet]({{ '/tutorials-recipes/setting-up-a-testnet.html' | relative_url }})
