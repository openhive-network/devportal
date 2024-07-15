---
title: titles.clive
position: 3
description: descriptions.clive
exclude: true
layout: full
canonical_url: clive.html
---

Command line options are typically expressed with double-dash (e.g., `--replay-blockchain`):

```bash
hived --data-dir=. --replay-blockchain
```

... or ...

```bash
hived --replay-blockchain --p2p-seed-node=hiveseed-se.privex.io:2001
```

Note, as the above example shows, options like `p2p-seed-node` are available as both a `config.ini` option as well a command-line options.  Nearly all options available as `config.ini` options are also available as command-line options.  See: [Node Config]({{ '/nodeop/node-config.html' | relative_url }})

The following are *only* available as command-line options.

### Sections

* [`disable-get-block`](#disable-get-block)
* [`statsd-record-on-replay`](#statsd-record-on-replay)
* [`transaction-status-rebuild-state`](#transaction-status-rebuild-state)
* [`p2p-force-validate`](#p2p-force-validate)
* [`replay-blockchain`](#replay-blockchain)
* [`force-open`](#force-open)
* [`resync-blockchain`](#resync-blockchain)
* [`stop-replay-at-block`](#stop-replay-at-block)
* [`advanced-benchmark`](#advanced-benchmark)
* [`set-benchmark-interval`](#set-benchmark-interval)
* [`dump-memory-details`](#dump-memory-details)
* [`check-locks`](#check-locks)
* [`validate-database-invariants`](#validate-database-invariants)
* [`account-history-rocksdb-immediate-import`](#account-history-rocksdb-immediate-import)
* [`exit-after-replay`](#exit-after-replay)
* [`force-replay`](#force-replay)
* [`account-history-rocksdb-immediate-import`](#account-history-rocksdb-immediate-import)
* [`account-history-rocksdb-stop-import-at-block`](#account-history-rocksdb-stop-import-at-block)
* [`load-snapshot`](#load-snapshot)
* [`dump-snapshot`](#dump-snapshot)

* Testnet Only
    * [`chain-id`](#chain-id)

### `disable-get-block`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Disable `get_block` API call.

```bash
--disable-get-block
```

### `statsd-record-on-replay`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Records statsd events during replay

Used by plugin: `statsd`

See: [#2276]({{ 'https://github.com/steemit/steem/issues/2276' | archived_url }})

```bash
--statsd-record-on-replay
```

### `transaction-status-rebuild-state`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Indicates that the transaction status plugin must re-build its state upon startup.

Used by plugin: `transaction_status`

See: [Plugin & API List]({{ '/nodeop/plugin-and-api-list.html#transaction_status_api' | relative_url }}), [#2458]({{ 'https://github.com/steemit/steem/issues/2458' | archived_url }})

```bash
--transaction-status-rebuild-state
```

### `p2p-force-validate`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Force validation of all transactions.

```bash
--p2p-force-validate
```

### `replay-blockchain`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Clear chain database and replay all blocks.

```bash
--replay-blockchain
```

### `force-open`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Force open the database, skipping the environment check.  If the binary or configuration has changed, replay the blockchain explicitly using `--replay-blockchain`.  If you know what you are doing you can skip this check and force open the database using `--force-open`.

**WARNING: THIS MAY CORRUPT YOUR DATABASE. FORCE OPEN AT YOUR OWN RISK.**

See: [#3446]({{ 'https://github.com/steemit/steem/issues/3446' | archived_url }})

```bash
--force-open
```

### `resync-blockchain`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Clear chain database and block log.

```bash
--resync-blockchain
```

### `stop-replay-at-block`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Stop and exit after reaching given block number

See: [#1590]({{ 'https://github.com/steemit/steem/issues/1590' | archived_url }})

```bash
--stop-replay-at-block=1234
```

### `advanced-benchmark`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Make profiling for every plugin.

See: [#1996]({{ 'https://github.com/steemit/steem/issues/1996' | archived_url }})

```bash
--advanced-benchmark
```

### `set-benchmark-interval`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Print time and memory usage every given number of blocks.

See: [#1590]({{ 'https://github.com/steemit/steem/issues/1590' | archived_url }})

```bash
--set-benchmark-interval
```

### `dump-memory-details`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Dump database objects memory usage info. Use `set-benchmark-interval` to set dump interval.

See: [#1985]({{ 'https://github.com/steemit/steem/issues/1985' | archived_url }})

```bash
--dump-memory-details
```

### `check-locks`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Check correctness of *chainbase* locking.

```bash
--check-locks
```

### `validate-database-invariants`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Validate all supply invariants check out.

See: [#1477]({{ 'https://github.com/steemit/steem/issues/1477' | archived_url }}), [#1649]({{ 'https://github.com/steemit/steem/issues/1649' | archived_url }})

```bash
--validate-database-invariants
```

### `account-history-rocksdb-immediate-import`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Allows to force immediate data import at plugin startup.  By default storage is supplied during reindex process.

See: [#1987]({{ 'https://github.com/steemit/steem/issues/1987' | archived_url }})

```bash
--account-history-rocksdb-immediate-import
```

### `account-history-rocksdb-stop-import-at-block`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Allows you to specify the block number that the data import process should stop at.

See: [#1987]({{ 'https://github.com/steemit/steem/issues/1987' | archived_url }})

```bash
--account-history-rocksdb-stop-import-at-block=1234
```

### `exit-after-replay`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Exit after reaching given block number

```bash
--exit-after-replay
```

### `force-replay`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Before replaying clean all old files

```bash
--force-replay
```

### `load-snapshot`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Allows to force immediate snapshot import at plugin startup.  All data in state storage are overwritten.

```bash
--load-snapshot=snapshot.json
```

See: [v1.24.2](https://gitlab.syncad.com/hive/hive/-/releases/v1.24.2)

### `dump-snapshot`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Allows to force immediate snapshot dump at plugin startup.  All data in the snaphsot storage are overwritten.

```bash
--dump-snapshot=snapshot.json
```

See: [v1.24.2](https://gitlab.syncad.com/hive/hive/-/releases/v1.24.2)

### `chain-id`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Chain ID to connect to.  **Testnet only.**

See: [PR#1631]({{ 'https://github.com/steemit/steem/pull/1631' | archived_url }}), [#2827]({{ 'https://github.com/steemit/steem/issues/2827' | archived_url }})

```bash
--chain-id=d043ab83d223f25f37e1876fe48a240d49d8e4b1daa2342064990a8036a8bb5b
```
