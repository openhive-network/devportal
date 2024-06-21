---
title: titles.plug_and_api_list
position: 3
description: Run a `hived` node with your preferred APIs.
exclude: true
layout: full
canonical_url: plugin-and-api-list.html
---

*This is a list of the plugins, and their associated dependencies, required to enable specific apis.*

**When setting up the config file `hived` will enable the `chain`, `p2p`, and `webserver` plugins regardless of other dependencies.**

## APIs with their respective plugin dependencies

* [`account_by_key_api`](#account_by_key_api)
* [`account_history_api`](#account_history_api)
* [`block_api`](#block_api)
* [`condenser_api`](#condenser_api)
* [`database_api`](#database_api)
* [`debug_node_api`](#debug_node_api)
* [`follow_api`](#follow_api)
* [`market_history_api`](#market_history_api)
* [`network_broadcast_api`](#network_broadcast_api)
* [`rc_api`](#rc_api)
* [`reputation_api`](#reputation_api)
* [`rewards_api`](#rewards_api)
* [`tags_api`](#tags_api)
* [`transaction_status_api`](#transaction_status_api)
* [`witness_api`](#witness_api-deprecated)

### `account_by_key_api`

* **Purpose:** Used to lookup account information based on a public key.
* **Requires:** `account_by_key`
* **Exposed Methods:** [`account_by_key_api.*`]({{ '/apidefinitions/#apidefinitions-account-by-key-api' | relative_url }})

Example in `chain.ini`:

```ini
plugin = account_by_key
plugin = account_by_key_api
```

---

### `account_history_api`

* **Purpose:** Used to lookup account history information.
* **Requires:** `account_history` or `account_history_rocksdb`
* **Exposed Methods:** [`account_history_api.*`]({{ '/apidefinitions/#apidefinitions-account-history-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = account_history
plugin = account_history_api
```

... or ...

```ini
plugin = account_history_rocksdb
plugin = account_history_api
```

---

### `block_api`

* **Purpose:** Used to query values related to the block plugin.
* **Requires:** *No additional*
* **Exposed Methods:** [`block_api.*`]({{ '/apidefinitions/#apidefinitions-block-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = block_api
```

---

### `condenser_api`

* **Purpose:** Intended to help ease the transition to AppBase.  It is recommended that apps transition away from this API.
* **Requires:** `database_api` (automatic); Jussi + Hivemind (for `condenser_api.get_state`, `condenser_api.get_account_votes`, `condenser_api.get_content`, `condenser_api.get_content_replies`, `condenser_api.get_tags_used_by_author`, `condenser_api.get_tags_used_by_author`, `condenser_api.get_post_discussions_by_payout`, `condenser_api.get_comment_discussions_by_payout`, `condenser_api.get_discussions_by_trending`, `condenser_api.get_discussions_by_created`, `condenser_api.get_discussions_by_active`, `condenser_api.get_discussions_by_cashout`, `condenser_api.get_discussions_by_votes`, `condenser_api.get_discussions_by_children`, `condenser_api.get_discussions_by_hot`, `condenser_api.get_discussions_by_feed`, `condenser_api.get_discussions_by_blog`, `condenser_api.get_discussions_by_comments`, `condenser_api.get_discussions_by_promoted`, `condenser_api.get_replies_by_last_update`, `condenser_api.get_discussions_by_author_before_date`, `condenser_api.get_followers`, `condenser_api.get_following`, `condenser_api.get_follow_count`, `condenser_api.get_feed_entries`, `condenser_api.get_feed`, `condenser_api.get_blog_entries`, `condenser_api.get_blog`, `condenser_api.get_account_reputations`, `condenser_api.get_reblogged_by`, `condenser_api.get_blog_authors`)
* **Optional:**
  * `account_by_key`
  * `reputation` (e.g.: if fronting hivemind)
  * `market_history`
  * `account_history`
* **Exposed Methods:** [`condenser_api.*`]({{ '/apidefinitions/#apidefinitions-condenser-api' | relative_url}})

Example of a limited combination in `chain.ini` (e.g., no `reputation` or `account_history` support):

```ini
plugin = account_by_key market_history
plugin = condenser_api
```

... or a full combination like ...

```ini
plugin = account_by_key reputation market_history account_history
plugin = condenser_api
```

---

### `database_api`

* **Purpose:** Used to query information about accounts, transactions, and blockchain data.
* **Requires:** Jussi + Hivemind (for `database_api.list_votes` and `database_api.find_votes`)
* **Exposed Methods:** [`database_api.*`]({{ '/apidefinitions/#apidefinitions-database-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = database_api
```

---

### `debug_node_api`

* **Purpose:** Allows all sorts of creative "what-if" experiments with the chain.
* **Requires:** `debug_node`
* **Exposed Methods:** [`debug_node_api.*`]({{ '/apidefinitions/#apidefinitions-debug-node-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = debug_node
plugin = debug_node_api
```

---

### `follow_api`

* **Purpose:** Used to lookup information related to reputation and account follow operations.
* **Requires:** Jussi + Hivemind (hived `follow` and `follow_api` plugins are *deprecated*)
* **Exposed Methods:** [`follow_api.*`]({{ '/apidefinitions/#apidefinitions-follow-api' | relative_url}})

Note, `follow_api` is no longer supported by `hived` and is provided entirely by Hivemind.  All `config.ini` plugins for this namespace should be removed.

---

### `market_history_api`

* **Purpose:** Used to lookup market history information. Can return the market and trade history of the internal HIVE:HBD market. The order book, recent trades and the market volume is made available through this plugin.
* **Requires:** `market_history` (automatic)
* **Exposed Methods:** [`market_history_api.*`]({{ '/apidefinitions/#apidefinitions-market-history-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = market_history_api
```

---

### `network_broadcast_api`

* **Purpose:** Used to broadcast transactions and blocks.
* **Requires:** `rc` (automatic)
* **Exposed Methods:** [`network_broadcast_api.*`]({{ '/apidefinitions/#apidefinitions-network-broadcast-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = network_broadcast_api
```

---

### `rc_api`

* **Purpose:** Managing of resources - curation rewards, vesting shares, etc.
* **Requires:**
  * `rc` (automatic)
  * `database_api` (automatic)
* **Exposed Methods:** [`rc_api.*`]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = rc_api
```

---

### `reputation_api`

* **Purpose:** Manage account reputation (relevant to voting on content).
* **Requires:** `reputation` (automatic)
* **Exposed Methods:** [`reputation_api.*`]({{ '/apidefinitions/#apidefinitions-reputation-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = reputation_api
```

---

### `rewards_api`

* **Purpose:** Used to simulate curve payouts.
* **Requires:** *No additional*
* **Exposed Methods:** [`rewards_api.*`]({{ '/apidefinitions/#apidefinitions-rewards-api' | relative_url}})

Note: **The `rewards_api` plugin is for testing purposes only, do not run in production.**

Example in `chain.ini`:

```ini
plugin = rewards_api
```

---

### `tags_api`

* **Purpose:** Used to lookup information about tags, posts, and discussions as well as votes.
* **Requires:** Jussi + Hivemind (hived `tags` and `tags_api` plugins are *deprecated*)
* **Exposed Methods:** [`tags_api.*`]({{ '/apidefinitions/#apidefinitions-tags-api' | relative_url}})

Note, `follow_api` is no longer supported by `hived` and is provided entirely by Hivemind.  All `config.ini` plugins for this namespace should be removed.

---

### `transaction_status_api`

* **Purpose:** Evaluates a transaction status after calling [`condenser_api.broadcast_transaction`]({{ '/apidefinitions/#condenser_api.broadcast_transaction' | relative_url}}).
* **Requires:**
  * `transaction_status` (automatic)
  * `database_api` (automatic)
* **Exposed Methods:** [`transaction_status_api.*`]({{ '/apidefinitions/#apidefinitions-transaction-status-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = transaction_status_api
```

---

### `witness_api` *(deprecated)*

* **Purpose:** The witness plugin contains all of the bandwidth logic (replaced by `rc`).  Can access the available bandwidth of an account and current reserve ratio.
* **Requires:** `rc` (automatic)
* **Exposed Methods:** [`witness_api.*`]({{ '/apidefinitions/#apidefinitions-witness-api' | relative_url}})

Example in `chain.ini`:

```ini
plugin = witness_api
```
