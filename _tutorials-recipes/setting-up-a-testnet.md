---
title: Setting Up a Testnet
position: 1
description: |
  "Quick-start" for deploying a Hive-based Testnet.
exclude: true
layout: full
canonical_url: setting-up-a-testnet.html
---

### Intro

Running a testnet is ideal for application developers who want to verify their app without broadcasting signed transactions over the mainnet.  It's also a great way for blockchain developers to verify changes to the blockchain and can allow witnesses to get a preview of changes that they are expected to approve.

Setting up a testnet can be as simple as running a single Docker command, such as:

```bash
docker run -d -P inertia/tintoy:latest
```

This docker command is useful for rapid testnet deploy because it only creates 2,000 accounts.

But in this tutorial, we will go over the **no docker** approach which will create all accounts that exist on mainnet.  The idea is to try to mirror the accounts and balances in proportion to the mainnet.

If you want full details on setting up a testnet using Tinman, head over to that github:

https://gitlab.syncad.com/hive/tinman

Otherwise, let's do the complete Quick Start:

### Sections

* [Minimum Requirements](#minimum-requirements)
* [Installing Tinman](#installing-tinman)
* [Building `hived`](#building-hived)
* [Snapshot](#snapshot)
* [Configure Tinman](#configure-tinman)
* [Actions](#actions)
* [Configure Bootstrap Node](#configure-bootstrap-node)
* [Bootstrap Node](#bootstrap-node)
* [Configure Seed Node](#configure-seed-node)
* [Seed Node](#seed-node)
* [Gatling (Optional)](#gatling-optional)
* [Troubleshooting](#troubleshooting)

### Minimum Requirements<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

This tutorial assumes Ubuntu Server 18.04 LTS 16GB RAM and 300GB SSD/HDD.

Running a testnet can be done on minimal hardware, but in order to build a snapshot of accounts, you should already be running your own local Hive node because getting the snapshot is time consuming and if this process is interrupted, you'll have to start over.

Not only are we going to use `tinman` to build the snapshot, we also need to compile `hived` and configure it to run our testnet.

### Installing Tinman<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

First, we need python (for `tinman`) and some other libraries:

```bash
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install virtualenv python3 libyajl-dev git pv
virtualenv -p $(which python3) ~/ve/tinman
source ~/ve/tinman/bin/activate
mkdir -p ~/src
cd ~/src
git clone --branch master https://gitlab.syncad.com/hive/tinman.git
cd tinman
pip install pipenv
pipenv install
pip install .
```

### Building `hived`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Next, let's build `hived`.  Note, we are using the `develop` branch but you can use whatever branch you want.  To see a list of branches that are currently being worked on, refer to: https://gitlab.syncad.com/hive/hive/-/branches/active

```bash
sudo apt-get install autoconf automake autotools-dev bsdmainutils \
  build-essential cmake doxygen gdb libboost-all-dev libreadline-dev \
  libssl-dev libtool liblz4-tool ncurses-dev pkg-config python3-dev \
  python3-pip nginx fcgiwrap awscli gdb libgflags-dev libsnappy-dev zlib1g-dev \
  libbz2-dev liblz4-dev libzstd-dev
cd ~/src
git clone --branch develop https://gitlab.syncad.com/hive/hive.git
cd hive
git submodule update --init --recursive
mkdir -p build
cd build
HIVE_NAME=hive-tn
cmake \
  -DCMAKE_INSTALL_PREFIX="~/opt/$HIVE_NAME" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_HIVE_TESTNET=ON \
  -DLOW_MEMORY_NODE=OFF \
  -DCLEAR_VOTES=ON \
  -DSKIP_BY_TX_ID=ON \
  -DHIVE_LINT_LEVEL=OFF \
  -DENABLE_MIRA=ON \
  ..
mkdir -p ~/opt/$HIVE_NAME
make -j$(nproc) install
```

**A note on `hived` branches:**  Selecting a branch depends on why you're running a testnet.  If you are doing blockchain development, you're likely going to select your own branch where you've done some work that needs to be verified.  If you're a witness, you're likely going to select `develop` or `master` to check stability.  If you're an application developer, you should probably select the `stable` branch because you want to test your app more than test the blockchain.  Application developers might also select `develop` to try out blockchain features that have not been released yet.

### Snapshot<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

The snapshot is a copy of all accounts on the blockchain plus some other properties.  Having a full snapshot allows `tinman` to create a more realistic testnet.  Here's how we generate a snapshot:

```bash
cd ~/src/tinman
source ~/ve/tinman/bin/activate
tinman snapshot -s http://mainnet-hive-node:8090 | pv -l > snapshot.json
```

In the above example, we assume that `http://mainnet-hive-node:8090` is our Hive node on our local network.  If you use a public node to build the `snapshot.json` file instead (not recommended), just remember that this process could take quite a while and can be interrupted or rate-limited.  You should consider running your own node.

As of August 2020, assuming the Hive mainnet node is local, this process takes approximately 20 minutes to produce a 3.6 GB output file.

### Configure Tinman<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

We can take all of the defaults in `txgen.conf.example`, assuming you named your snapshot `snapshot.json`.

```bash
cd ~/src/tinman
cp txgen.conf.example txgen.conf
```

We can optionally adjust `total_port_balance` to adjust the supply on the testnet.  But keep in mind, there is a blockchain limit defined by `HIVE_INIT_SUPPLY`.

### Actions<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Now that we have our `snapshot.json` file, we can generate the actions that will build our testnet.

```bash
cd ~/src/tinman
source ~/ve/tinman/bin/activate
tinman txgen -c txgen.conf -o bootstrap-init.actions
```

Building the actions is pure data-processing that doesn’t communicate with the outside world.  It only processes the JSON snapshot and config file into more JSON.  As of September 2019, this process takes approximately 90 minutes to produce a 2 GB output file.

### Configure Bootstrap Node<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

```bash
HIVE_NAME=hive-tn
BOOTSTRAP=~/data/bootstrap
HIVED=~/opt/$HIVE_NAME/bin/hived
$HIVED --data-dir=$BOOTSTRAP
```

At the startup banner, press `^C` (Ctrl+C) to exit `hived`.  As a side effect, a default data-dir is created.  Now we can purge the empty blockchain and create `config.ini` as follows:

```bash
rm -Rf $BOOTSTRAP/blockchain
nano $BOOTSTRAP/config.ini
```

Then make the following changes to the generated `config.ini`:

* Enable plugins `chain debug_node p2p webserver block_api chain_api database_api debug_node_api network_broadcast_api`
* Pick a random port for p2p, say `12541`
* Edit `shared-file-size` down, say `12G`
* Pick a random port for `webserver-http-endpoint` and set `webserver-ws-endpoint` to the next-highest port.

To summarize, the *changed* values are:

```ini
plugin = chain debug_node p2p webserver block_api chain_api database_api debug_node_api network_broadcast_api
shared-file-size = 12G
p2p-endpoint = 0.0.0.0:12541
webserver-http-endpoint = 0.0.0.0:18751
webserver-ws-endpoint = 0.0.0.0:18752
```

Save `config.ini` and start `hived`:

```bash
$HIVED --data-dir=$BOOTSTRAP
```

### Bootstrap Node<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Note, the secret can be any string.  In this tutorial, we are using `hive-is-alive` as the secret.  Keep in mind that any person with knowledge of the secret will be able to transact using any account on your testnet.

```bash
HIVE_NAME=hive-tn
GET_DEV_KEY=~/opt/$HIVE_NAME/bin/get_dev_key
SIGN_TRANSACTION=~/opt/$HIVE_NAME/bin/sign_transaction

cd ~/src/tinman
source ~/ve/tinman/bin/activate

( \
  echo '["set_secret", {"secret":"hive-is-alive"}]' ; \
  cat bootstrap-init.actions \
) | \
tinman keysub --get-dev-key $GET_DEV_KEY | \
tinman submit -t http://127.0.0.1:18751 \
    --signer $SIGN_TRANSACTION \
    -f die \
    --timeout 600
```

The above command will send `bootstrap-init.actions` to the bootstrap node using "fastgen" (as rapidly as possible).  Fastgen functionality is provided by `debug_node_api`.  Without fastgen, this process would take 3 seconds per 40 action (by default).

### Configure Seed Node<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Once the bootstrap is complete and we no longer need fastgen to import actions, we can start a new testnet node without `debug_node_api`.  For simplicity, this new seed node will also run our initial witnesses for block signing.

We need to keep the Bootstrap Node running, so do the following in a new shell session:

```bash
HIVE_NAME=hive-tn
SEED=~/data/seed
HIVED=~/opt/$HIVE_NAME/bin/hived
GET_DEV_KEY=~/opt/$HIVE_NAME/bin/get_dev_key
$HIVED --data-dir=$SEED
```

Again, at the startup banner, press `^C` (Ctrl+C) to exit `hived`.

```bash
rm -Rf $SEED/blockchain
nano $SEED/config.ini
```

Then make the following changes to the generated `config.ini`:

* Enable plugins `chain p2p webserver witness database_api network_broadcast_api block_api`
* Pick the Bootstrap ip/port for p2p-seed-node `127.0.0.1:12541`
* Pick a new port for p2p, say `2541`
* Edit `shared-file-size` down, say `24G`
* Pick a new random port for `webserver-http-endpoint` and set `webserver-ws-endpoint` to the next-highest port.
* Enable stale block production with `enable-stale-production = true`
* Set required participation with `required-participation = 0`
* Add whitelist for RC with `rc-account-whitelist = porter tnman`
* TODO research: `rc-skip-reject-not-enough-rc = true`

Now we need to add the names of all of the witnesses:

```bash
for N in $(seq 0 21)
do
echo "witness = \"init-$N\"" >> $SEED/config.ini
done
```

Add their private keys as well, note we are assuming the secret is `hive-is-alive` for this tutorial:

```bash
for K in $($GET_DEV_KEY hive-is-alive block-init-0:21 | cut -d '"' -f 4)
do
echo "private-key = $K" >> $SEED/config.ini
done
```

To summarize, the *changed and new* values are:

```ini
plugin = chain p2p webserver witness database_api network_broadcast_api block_api
shared-file-size = 24G
p2p-seed-node = 127.0.0.1:12541
p2p-endpoint = 0.0.0.0:2541
webserver-http-endpoint = 0.0.0.0:8751
webserver-ws-endpoint = 0.0.0.0:8752
enable-stale-production = true
required-participation = 0
rc-account-whitelist = porter tnman
rc-skip-reject-not-enough-rc = true
witness = "init-0"
witness = "init-1"
witness = "init-2"
witness = "init-3"
witness = "init-4"
witness = "init-5"
witness = "init-6"
witness = "init-7"
witness = "init-8"
witness = "init-9"
witness = "init-10"
witness = "init-11"
witness = "init-12"
witness = "init-13"
witness = "init-14"
witness = "init-15"
witness = "init-16"
witness = "init-17"
witness = "init-18"
witness = "init-19"
witness = "init-20"
witness = "init-21"
private-key = 5J1giwxi3QwU56N7J4WMaJiRaRmfnp5F27QPZ7itnW4o7ePuUs2
private-key = 5KV3k9PJzrE6h7gvnZcrfXBjazZZ6UdCQjfePfv7hxbmWMFtZ1r
private-key = 5JypUTzFq4zuyowWCjUJwsmph2Gwx49hUMVpAYT1PzbnmUDG4sh
private-key = 5JqvwS7jQDY5wyCeQ9wBKAx6XgoLBf4hZZz6Cd3rb5NCP3pMiZ7
private-key = 5JWQaGiV8Z9ssNCCTm5Hx2VdhEV8G82nV6RwSwAWBYQWfoM3Dzf
private-key = 5KW5fY5gpTBYt7YJNBnfPWc2BzE1o6GJiLB8Hc2YaZ7sz71VFtc
private-key = 5K8aRoTDwELSyZJZLkv6mPQy2tQRQ3p2cqNVxK2tMQZfrZThg2R
private-key = 5KCVYYBwkDt2TY7Eaw3TJvLRhEdxR3ruMVqyN6RPcbbCSLhDTbu
private-key = 5Jf1sxJhTo4ZEog5LDxfeA8ZFsFCivtMb2HXmx7ndw7mgq15Qqk
private-key = 5Ki39i3NL6TyxRXN7d2aJFPD2PEb4WXx1t7KrXc6KQqm5Zfame2
private-key = 5K2B9RhzdxhpuMxXCPszXgjJYqPD6PC66zmour3cfmGoLLRcNfa
private-key = 5J2sv5ELyuumaVeXpBJFE92dphvnyjmkLi2AyY28hr2iYPZ7Qh6
private-key = 5JZjV98gnLGm7AxVdRbiDT5DU6pibmzUUu7bxACR87nxawj1gNC
private-key = 5JFDyVEEVHAyang92s35cVH7t27GoeBg4uthWghV3yDdvj3GPcX
private-key = 5KTJe4qmj7jcubLGxKQ4WB52akWkRC98sJGbNRsxjj9yN73GGTy
private-key = 5KKxuTpqXWRsxzbJKdQCfK3mLJ4wqZ9eTswqtaQQ7bEaqEqGzHh
private-key = 5KV3ynnzdun28k9kJFxJZYvKUv8rPoq3bNVWajucvkCy9S9bMCv
private-key = 5JBD9uVVFD6NcRo6nZnAjFKYf2RqfPRZHd8PWGJNzEnfmmcqi8K
private-key = 5JiT5h3dxmiwUmfserh5yW8fjuc4zSSTkLL7t72SioqWKRJ7Sd3
private-key = 5JdVzBLVucfHpfh9gupu5j4aQT5oCSuRLhcJSs2bqvNjEVMRmSt
private-key = 5JogZpTZurEK67skra7YkAJ7hHNBuoyScowDr82nbWoYXndeWRH
```

Save `config.ini` and start `hived`:

```bash
$HIVED --data-dir=$SEED
```

At this point, our Seed Node will sync blocks from the Bootstrap Node.

### Seed Node<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Once the Seed Node has caught up to the Bootstrap Node, it's safe to shut down the Bootstrap Node.  The Seed Node will now take over block production.

Congratulations!  Your testnet is running!

### Gatling (Optional)<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

If you'd like your testnet to mirror mainnet transactions as they happen, you should run the gatling module.  Make sure your Seed Node is fully sync'd before running gatling.  Also make sure you use the same secret.

```bash
HIVE_NAME=hive-tn
GET_DEV_KEY=~/opt/$HIVE_NAME/bin/get_dev_key
SIGN_TRANSACTION=~/opt/$HIVE_NAME/bin/sign_transaction

cd ~/src/tinman
source ~/ve/tinman/bin/activate

cp gatling.conf.example gatling.conf

( \
  echo '["set_secret", {"secret":"hive-is-alive"}]' ; \
  tinman gatling -c gatling.conf -f 0 -t 0 -o - | tinman prefixsub \
) | \
tinman keysub --get-dev-key $GET_DEV_KEY | \
tinman submit --realtime -t http://127.0.0.1:8751 \
    --signer $SIGN_TRANSACTION \
    --timeout 600 \
    --fail /dev/null
```

### Troubleshooting<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

**Problem:** Got an error while trying to compile `hived`:

`c++: internal compiler error: Killed (program cc1plus)`

-or-

`virtual memory exhausted: Cannot allocate memory`

**Solution:** Add more memory or enable swap.

To enable swap (do not enable swap on a VPS like Digital Ocean):

```bash
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=4000
sudo chmod 600 /var/swap.img
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
```

---

**Problem:** Got an error while trying to create `bootstrap-init.actions`:

`ijson.common.IncompleteJSONError: b'parse error: premature EOF`

**Solution:** Re-run `tinman snapshot` in the [Snapshot](#snapshot) section.  The snapshot was likely interrupted or you ran out of disk space while saving the snapshot.  It's also possible you were rate-limited, if you're using a public node, which is one of the pitfalls of using a public node.
