---
title: titles.setting_up_testnet
position: 15
description: descriptions.setting_up_testnet
exclude: true
layout: full
canonical_url: setting-up-a-testnet.html
---

### Intro

A local testnet lets you test applications and blockchain changes without broadcasting transactions to mainnet. [Tinman](https://gitlab.syncad.com/hive/tinman) imports account data through the `snapshot → txgen → keysub → submit` pipeline. [Tin Toy](https://hub.docker.com/r/inertia/tintoy) packages that pipeline with Hive and a sample snapshot for a small local testnet.

### Sections

* [Docker Quickstart](#docker-quickstart)
* [Minimum Requirements](#minimum-requirements)
* [Installing Tinman](#installing-tinman)
* [Building `hived`](#building-hived)
* [Snapshot](#snapshot)
* [Configure Bootstrap Node](#configure-bootstrap-node)
* [Configure Tinman](#configure-tinman)
* [Actions](#actions)
* [Bootstrap Node](#bootstrap-node)
* [Configure Seed Node](#configure-seed-node)
* [Seed Node](#seed-node)
* [Gatling (Optional)](#gatling-optional)
* [Troubleshooting](#troubleshooting)

### Docker Quickstart

Use a running Docker daemon configured for Linux containers. These commands use a Bash-compatible shell; on Windows, use WSL or Git Bash. The image is AMD64, so ARM hosts need AMD64 emulation, as provided by Docker Desktop.

```bash
docker run -d --rm --platform linux/amd64 --name tintoy \
  -p 127.0.0.1:8092:8092 \
  -p 127.0.0.1:2001:2001 \
  inertia/tintoy:1.29.0
docker logs -f tintoy
```

Wait for `tintoy: snapshot applied and seed node is producing`, then press Ctrl+C to leave the log viewer. The container keeps running. It imports a 2,000-account sample and starts 21 replacement witnesses. RPC is on port **8092** and p2p is on port **2001**.

Check the chain from another terminal:

```bash
curl -sS http://127.0.0.1:8092 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","method":"database_api.get_dynamic_global_properties","params":{},"id":1}'
```

Repeat the request after a few seconds and check that `result.head_block_number` increases. When finished:

```bash
docker stop tintoy
```

This example is ephemeral: stopping the container removes its chain data. The ports are bound to localhost because the image uses deterministic test keys. The current image provides the core Hive node; the old web applications and their ports belong to the `legacy-2021` image. See the [Tin Toy README](https://gist.github.com/inertia/b88e7bfff8862858e54c59392e2bce20) for image versions, building from source, and bootstrap details.

### Minimum Requirements

The remaining sections are for operators customizing a testnet with Tinman. They describe the individual tools and the node state each step needs. For the tested image combinations and the automated bootstrap procedure, use Tinman's [compatibility guide](https://gitlab.syncad.com/hive/tinman/-/blob/master/COMPATIBILITY.md).

Tinman supports CPython 3.12, 3.13, and 3.14. Native Hive builds currently target Linux, with Ubuntu 24.04 LTS as the minimum supported Ubuntu release and at least 16 GB RAM for compilation. Follow the [Hive build guide](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md) for the selected revision. Snapshot size, bootstrap time, and disk requirements depend on how many accounts you import; a full mainnet snapshot needs substantially more resources than Tin Toy's sample.

### Installing Tinman

On Ubuntu 24.04, install Python's virtual-environment support and the command-line tools used below:

```bash
sudo apt-get update
sudo apt-get install python3.12-venv git curl jq pv
mkdir -p ~/src
cd ~/src
git clone --branch master https://gitlab.syncad.com/hive/tinman.git
cd tinman
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install .
tinman --help
```

Tinman's optional account-creation web server has separate dependencies, installed with `python -m pip install '.[server]'`. It is not needed for the bootstrap pipeline.

### Building `hived`

Build `hived`, `get_dev_key`, and `sign_transaction` from the same Hive revision with `BUILD_HIVE_TESTNET=ON`. The signing utilities must agree with the node's network and protocol. This follows the native build procedure in the [Hive build guide](https://gitlab.syncad.com/hive/hive/-/blob/master/doc/building.md):

```bash
cd ~/src
git clone --recurse-submodules --branch master https://gitlab.syncad.com/hive/hive.git
sudo hive/scripts/setup_ubuntu.sh --dev
cmake -S hive -B hive/build -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_HIVE_TESTNET=ON
cmake --build hive/build --parallel 4 \
  --target hived get_dev_key sign_transaction
```

The binaries are `~/src/hive/build/programs/hived/hived` and `~/src/hive/build/programs/util/{get_dev_key,sign_transaction}`. Reduce parallelism if compilation runs out of memory. For repeatable experiments, select a release tag or commit before building and record it alongside the Tinman revision. Building a new revision does not establish compatibility; Tinman's compatibility guide records the combinations actually tested.

### Snapshot

Take account data from your own mainnet node. The source node needs the `database_api` plugin and an HTTP RPC endpoint. Replace the endpoint below with your node's address:

```bash
cd ~/src/tinman
source .venv/bin/activate
set -o pipefail
tinman snapshot -s http://127.0.0.1:8090 | pv -l > snapshot.json
```

A snapshot contains account data and chain properties, not the mainnet block log or all historical posts. Public endpoints can rate-limit or interrupt large snapshots. For a smaller experiment, sample the snapshot:

```bash
tinman sample -i snapshot.json -o sample-snapshot.json
```

Choose the resulting filename when configuring `txgen`. Keep the original snapshot if you need to change the sample later.

### Configure Bootstrap Node

Fast generation needs a **fresh, isolated testnet** with `database_api`, `debug_node_api`, `network_broadcast_api`, and `witness` enabled. A minimal configuration for the supported images is:

```ini
plugin = database_api
plugin = debug_node_api
plugin = network_broadcast_api
plugin = witness
shared-file-size = 8G
enable-stale-production = false
webserver-http-endpoint = 127.0.0.1:18751
```

Use an empty data directory dedicated to this testnet. Do not reuse a mainnet directory. The old `rc-account-whitelist`, `rc-start-at-block`, and `rc-skip-reject-not-enough-rc` settings are no longer available in current Hive.

For an automated bootstrap against a supported, digest-pinned Hive image, Tinman's [fastgen runner](https://gitlab.syncad.com/hive/tinman/-/blob/master/scripts/hive_compatibility.py) performs the preflight and runs the core pipeline. It requires a pristine chain at block zero, accepts a snapshot through `--snapshot`, and requires `--hive-image` to identify the actual image by digest. Follow the [fastgen instructions](https://gitlab.syncad.com/hive/tinman/-/blob/master/COMPATIBILITY.md#live-profiles) for the complete invocation and matching signing utilities.

### Configure Tinman

When running the individual commands yourself, copy the example configuration:

```bash
cd ~/src/tinman
cp txgen.conf.example txgen.conf
```

Configure these values for the target node before generating actions:

| Setting | Required value |
| --- | --- |
| `snapshot_file` | Your full or sampled snapshot filename. |
| `existing_account_names` | Accounts already present on the target, obtained through `database_api.list_accounts`, so they are not created again. The fastgen runner discovers them automatically. |
| `account_creation_fee` | The target's median fee from `database_api.get_witness_schedule`, under `median_props.account_creation_fee`. Preserve the complete asset object. |
| `hive_genesis_supply` | The liquid HIVE allocated at genesis. Amounts use integer units: with precision 3, `250000000000` means 250,000,000 HIVE. |
| `hive_max_authority_membership` | The target's `HIVE_MAX_AUTHORITY_MEMBERSHIP` from `database_api.get_config`. |
| `hive_address_prefix`, `hive_block_interval` | The target's `HIVE_ADDRESS_PREFIX` and `HIVE_BLOCK_INTERVAL`. |
| `hive_genesis_timestamp` | The timestamp baseline used by the target's block generation. |

**Read the fee after the bootstrap node has applied its initial hardforks.** A node at block zero can report a different fee from the one it will enforce when importing accounts. The fastgen runner generates its preflight block before reading these properties and aligns transaction timestamps with that block. Copying `txgen.conf.example` alone does not perform this preparation.

Zero is a valid fee only when the target reports zero. For example, Tinman's captured Hive 1.29.0 testnet image reported 0.030 HIVE after preflight; this is an example, not a universal default. `total_port_balance`, system-account allocations, and fee reserves must fit within `hive_genesis_supply`. Tinman rejects an over-budget plan. Only submit the action file after `txgen` has completed successfully; a failed run can leave partial output.

### Actions

Once the target is prepared and `txgen.conf` matches it:

```bash
cd ~/src/tinman
source .venv/bin/activate
tinman txgen -c txgen.conf -o bootstrap-init.actions
```

This step processes the snapshot locally. Imported balances are proportional to the snapshot within the configured budget. Tinman adds its manager account (`tnman` by default) to imported authorities and respects the target's combined account-and-key authority limit; excess authority members can be omitted. See the [authority policy](https://gitlab.syncad.com/hive/tinman#generating-actions) before relying on an exact mainnet authority copy.

### Bootstrap Node

For the manual pipeline, use the signing utilities from the target Hive build. The following assumes the preflight and configuration above are complete, the node is listening on port 18751, and it uses the standard testnet chain ID. For a custom chain, also pass its actual `--chain-id` to `tinman submit`.

```bash
cd ~/src/tinman
source .venv/bin/activate
GET_DEV_KEY=~/src/hive/build/programs/util/get_dev_key
SIGN_TRANSACTION=~/src/hive/build/programs/util/sign_transaction
set -o pipefail

( \
  echo '["set_secret", {"secret":"hive-is-alive"}]' ; \
  cat bootstrap-init.actions \
) | \
tinman keysub --get-dev-key "$GET_DEV_KEY" | \
tinman submit -t http://127.0.0.1:18751 \
  --signer "$SIGN_TRANSACTION" \
  --fail-file die \
  --block-timeout 600
```

`--block-timeout` controls debug block-generation requests. `--timeout` controls ordinary API requests. The example secret is public; anyone who knows it can derive these test keys. Keep this chain isolated and use the same secret when deriving witness keys.

### Configure Seed Node

After importing accounts, the seed node needs the bootstrap chain and a witness configuration. Tin Toy handles this by stopping the bootstrap node, moving its chain data, and force-replaying it with the seed node. For a custom deployment, use matching Hive binaries and follow the [Tin Toy bootstrap script](https://gist.github.com/inertia/b88e7bfff8862858e54c59392e2bce20#file-bootstrap-sh) or Hive's replay procedure. Do not copy a running node's mutable chain state.

The seed node enables `database_api`, `network_broadcast_api`, and `witness`, with `enable-stale-production = true` and `required-participation = 0` for this isolated testnet. Keep RPC on localhost and omit `debug_node_api` once fast generation is finished.

The default `txgen.conf` creates **21 replacement witnesses**, named `init-0` through `init-20`. For a manual pipeline using the example secret above, append their names and keys to the seed configuration once:

```bash
SEED=~/data/seed
GET_DEV_KEY=~/src/hive/build/programs/util/get_dev_key
for N in $(seq 0 20); do
  printf 'witness = "init-%s"\n' "$N" >> "$SEED/config.ini"
done
"$GET_DEV_KEY" hive-is-alive block-init-0:21 \
  | jq -r '.[] | "private-key = " + .private_key' >> "$SEED/config.ini"
```

Keep the genesis witness `initminer` and its test signing key configured until the replacement schedule activates, as Tin Toy does. If you used the automated fastgen runner, use its key derivation settings rather than the manual example's secret.

### Seed Node

Check the seed node's `database_api.get_dynamic_global_properties` and `database_api.get_witness_schedule` responses. The head block must continue advancing and the replacement witnesses must enter the schedule. A listening RPC port alone does not mean the testnet is producing blocks.

### Gatling (Optional)

[`tinman gatling`](https://gitlab.syncad.com/hive/tinman#gatling-transactions-from-mainnet) can replay selected mainnet activity after the testnet is running. It is optional and outside the maintained core bootstrap pipeline. Review its configuration and transaction coverage before using it; operations referencing content absent from your testnet cannot be reproduced just by importing accounts.

### Troubleshooting

* **Compilation is killed or runs out of memory:** reduce build parallelism and check the Hive build guide's RAM requirements.
* **Snapshot JSON is incomplete:** check disk space and the source RPC connection, then take a new snapshot. Do not generate actions from a partial file.
* **Account creation fails with a fee error:** read the target's median fee after hardfork initialization, correct the configuration, and start again with a fresh testnet.
* **Genesis funding exceeds supply:** reduce imported balances or other allocations, or use an appropriately configured genesis supply. Account-creation fees also consume that supply.
* **RPC responds but blocks stop:** check witness names, signing keys, and the active schedule. The default replacement set ends at `init-20`.
