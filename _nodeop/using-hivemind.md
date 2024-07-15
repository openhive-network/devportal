---
title: titles.using_hivemind
position: 6
description: descriptions.using_hivemind
exclude: true
layout: full
canonical_url: using-hivemind.html
---

## Intro

Hivemind is a "consensus interpretation" layer for the Hive blockchain, maintaining the state of social features such as post feeds, follows, and communities. Written in Python, it synchronizes an SQL database with chain state, providing developers with a more flexible/extensible alternative to the raw hived API. This means that you can bypass hived and access data in a more traditional way, for example, with SQL. But you can't use SQL on hived. So Hivemind solves that problem. Hivemind does not support any queries to do with wallets, orders, escrow, keys, recovery, or account history.

<!-- A good source of additional information on Hivemind and how to use it can be found in [this Hive article](https://hive.blog/hivemind/@inertia/hivemind-queries) by @inertia. -->

#### Supported API functionality:

**Core API set available in Hivemind:**

* condenser_api.get_followers
* condenser_api.get_following
* condenser_api.get_follow_count
* condenser_api.get_content
* condenser_api.get_content_replies
* condenser_api.get_state
* condenser_api.get_trending_tags
* condenser_api.get_discussions_by_trending
* condenser_api.get_discussions_by_hot
* condenser_api.get_discussions_by_promoted
* condenser_api.get_discussions_by_created
* condenser_api.get_discussions_by_blog
* condenser_api.get_discussions_by_feed
* condenser_api.get_discussions_by_comments
* condenser_api.get_replies_by_last_update 
* condenser_api.get_blog
* condenser_api.get_blog_entries
* condenser_api.get_discussions_by_author_before_date

Also see non-hived methods backed by Hivemind: [bridge]({{ '/apidefinitions/#apidefinitions-bridge' | relative_url }})

**Additional functions available within hivemind library**

The majority of these functions are reliant on hived so any changes to hived would affect these function calls. The only two functions not directly reliant on hived are `stream_blocks` and `get_hive_per_mvest`.

*   get_accounts
*   get_all_account_names
*   get_content_batch
*   get_block
*   stream_blocks
*   \_gdgp (get dynamic global properties)
*   head_time
*   head_block
*   last_irreversible
*   gdgp_extended
*   get_hive_per_mvest
*   get_feed_price
*   get_hive_price
*   get_blocks_range

Detailed information on the Hivemind library can be found in the [Hivemind repo](https://gitlab.syncad.com/hive/hivemind/-/blob/master/hive/steem/client.py).

#### Hivemind dependencies and setup

<!-- Hivemind is available as a pre-built docker image which can be downloaded directly from Dockerhub at [https://hub.docker.com/r/hive/hivemind/](https://hub.docker.com/r/hive/hivemind/). -->

If you would prefer to install Hivemind yourself you can do so following the basic instructions below.

This setup can be performed on an Ubuntu server.

There are two dependencies for setting up the dev environment on ubuntu for running Hivemind:

*   Python

```bash
$ sudo apt-get update
$ sudo apt-get install python3 python3-pip
```

*   Postgres

```bash
$ sudo apt-get install postgresql
```

More detailed documentation on the setup of Hivemind can be found at the [Hivemind github repository](https://gitlab.syncad.com/hive/hivemind).

Once the dependencies have been installed the database can be created and the environment variables set.

```bash
$ sudo service postgresql start
$ su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgres';\""
$ su - postgres -c "createdb hive"
$ su - postgres -c "psql -d hive -c \"CREATE EXTENSION intarray;\""
$ export DATABASE_URL=postgresql://postgres:postgres@localhost:5432/hive
$ export PG_PASSWORD=postgres
$ sudo service postgresql restart
```

##### Installation

```bash
$ git clone https://gitlab.syncad.com/hive/hivemind.git
$ cd hivemind
$ git submodule update --init --recursive
$ python3 setup.py build
$ sudo pip3 install jinja2
$ sudo python3 setup.py install
```

By default Hivemind will connect to the mainnet [https://api.hive.blog](https://api.hive.blog) but if required you can change this to connect to a testnet. To do this set the environment variable as described below.

```bash
# Note as of 2021-05-14, Hivemind still internally uses the environment variable called STEEMD_URL for this.
$ export STEEMD_URL='http://127.0.0.1:8091'
```

Now that the basic setup is done you are able to sync the database.

```bash
$ hive sync
```

**Note:** Do not use a public node to `hive sync`.  Instead of doing an initial sync, you can use a data dump, to speed up the process: [Daily Hivemind backups
 :: How to restore](https://peakd.com/hive-139531/@emrebeyler/daily-hivemind-backups#how-to-restore)
 
```bash
# Assunes 8 cpu cores:
$ pg_restore -j 8 -U postgres -d hive path/to/dump_file.dump
$ hive sync
```

You can also check the status of your synced database.

```bash
$ hive status
```

Once the synchronization is complete you can start the Hivemind server which will allow you to start performing queries on your local database.

```bash
$ hive server
```

By default the server is available on [http://0.0.0.0:8080](http://0.0.0.0:8080), this can also be changed by adding an environment variable.

```bash
$ export HTTP_SERVER_PORT=8090
```
