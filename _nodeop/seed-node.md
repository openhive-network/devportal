---
title: titles.seed_node
position: 10
description: descriptions.seed_node
exclude: true
layout: full
canonical_url: seed-node.html
---

### Intro

This tutorial will show how to setup the lowest possible resource seed node.

### Sections

* [Minimum Requirements](#minimum-requirements)
* [Building `hived`](#building-hived)
* [Configure Node](#configure-node)
* [Latest Block Log](#latest-block-log)
* [Sync Node](#sync-node)
* [Troubleshooting](#troubleshooting)

### Minimum Requirements

This tutorial assumes Ubuntu Server 18.04 LTS 8GB RAM and 500GB SSD/HDD.

### Building `hived`

```bash
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install autoconf automake autotools-dev bsdmainutils \
  build-essential cmake doxygen gdb libboost-all-dev libreadline-dev \
  libssl-dev libtool liblz4-tool ncurses-dev pkg-config python3-dev \
  python3-pip nginx fcgiwrap awscli gdb libgflags-dev libsnappy-dev zlib1g-dev \
  libbz2-dev liblz4-dev libzstd-dev
mkdir -p ~/src
cd ~/src
git clone --branch master https://gitlab.syncad.com/hive/hive.git
cd hive
git submodule update --init --recursive
mkdir -p build
cd build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DSKIP_BY_TX_ID=ON \
  -DHIVE_LINT_LEVEL=OFF \
  ..
make -j$(nproc)
sudo make install
```

### Configure Node

```bash
mkdir -p ~/hive_data
cd ~/hive_data
hived --data-dir=.
```

At the startup banner, press `^C` (Ctrl+C) to exit `hived`.  As a side effect, a default data-dir is created.  Now we can purge the empty blockchain and create `config.ini` as follows:

```bash
rm -Rf blockchain
nano config.ini
```

Then make the following changes to the generated `config.ini`:

* Enable plugins: `p2p`
* Pick a port for p2p to `2001`.

To summarize, the *changed* values are:

```ini
plugin = p2p
p2p-endpoint = 0.0.0.0:2001
```

Save `config.ini`.

#### Latest Block Log

Download the block log (optional but recommended).

```bash
cd ~/hive_data
mkdir -p blockchain
wget -O blockchain/block_log https://gtg.openhive.network/get/blockchain/block_log
hived --data-dir=. --replay-blockchain
```

### Sync Node

If you did not download the latest block log:

```bash
cd ~/hive_data
hived --data-dir=. --resync-blockchain
```

After *replay* or *resync* is complete, the console will display `Got ## transactions from  ...`.  It's possible to close `hived` with `^C` (Ctrl+C).  Then, to start the node again:

```bash
cd ~/hive_data
hived --data-dir=.
```

### Troubleshooting<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

**Problem:** Got an error while trying to compile `hived`:

`c++: internal compiler error: Killed (program cc1plus)`

**Solution:** Add more memory or enable swap.

To enable swap (do not enable swap on a VPS like Digital Ocean):

```bash
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=4000
sudo chmod 600 /var/swap.img
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
```

---

**Problem:** Got an error while replaying:

`IO error: While open a file for appending: /root/hive_data/./blockchain/rocksdb_witness_object/012590.sst: Too many open files`

**Solution:** You're using MIRA, but this tutorial recommends *not* to (`-DENABLE_MIRA=OFF`).  If you really *intend* to try MIRA, you will need to set higher limits.  Note, if you are also running `hived` as `root` (not recommended), you must explicitly set hard/soft nofile/nproc lines for `root` instead of `*` in `/etc/security/limits.conf`.

To set the open file limit ...

```bash
sudo nano /etc/security/limits.conf
```

Add the following lines:

```conf
*      hard    nofile     94000
*      soft    nofile     94000
*      hard    nproc      64000
*      soft    nproc      64000
```

To set the `fs.file-max` limit ...

```bash
sudo nano /etc/sysctl.conf
```

Add the following line:

```ini
fs.file-max = 2097152
```

Load the new settings:

```bash
sudo sysctl -p
```

Once you save these files, you may need to logout and login again.
