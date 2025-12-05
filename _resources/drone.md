---
title: titles.drone
position: 8
description: descriptions.drone
canonical_url: drone.html
---

Drone is an API caching layer application for the Hive blockchain. It is built using Rust with Actix Web, and its primary purpose is to cache and serve API requests for a specific set of methods.
Drone is totally meant to be a Jussi replacement, it aims to improve API node performance.

The purpose of this document is to help developers and node operators set up their own drone node within a docker container.

> **Note:** Drone is the modern replacement for [Jussi]({{ '/resources/jussi.html' | relative_url }}), offering better performance and reliability through Rust.

### Intro

Drone is a reverse proxy that sits between the API client and the `hived` server. It allows node operators to route an API call to nodes that are optimized for the particular call, as if they are all hosted from the same place.

### Sections

* [Features](#features)
* [Installation](#installation)
  * [Docker (Recommended)](#docker-recommended)
  * [Native](#native)
* [Configuration](#configuration)
* [Cached API Methods](#cached-api-methods)
* [Endpoints](#endpoints)
* [Repository](#repository)

### Features<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

* Written in Rust for optimal performance and reliability.
* Actix Web for high-performance, asynchronous HTTP handling.
* LRU cache with time-based expiration to store API responses.
* Multiple API endpoints support for seamless request handling with HAF apps.
* Caching support for select Hive API methods to reduce strain on API nodes.
* Compatible with existing Jussi configurations for easy migration.

### Installation<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

#### Docker (Recommended)<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

##### To run `drone` using Docker:

```bash
git clone https://gitlab.syncad.com/hive/drone.git
cd drone
cp config.example.yaml config.yaml
# Edit config.yaml to configure your endpoints
docker-compose up --build -d
```

The docker-compose setup will:
- Build the Rust application
- Expose the service on port 3000 (mapped to internal port 8999)
- Mount your config.yaml file
- Set up logging with a maximum size of 20GB

#### Native<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

To run `drone` natively, you'll need Rust installed on your system.

```bash
git clone https://gitlab.syncad.com/hive/drone.git
cd drone
cp config.example.yaml config.yaml
# Edit config.yaml to configure your endpoints
cargo run --release
```

For production deployments, you can build the binary:

```bash
cargo build --release
./target/release/drone
```

##### Try out your local configuration:

```bash
curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_block", "params":[8675309], "id":1}' http://localhost:9000
```

---

### Configuration<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Drone uses a YAML configuration file (`config.yaml`) instead of JSON. The configuration is divided into several sections:

#### Drone Settings

```yaml
drone:
  port: 9000                        # Port to listen on
  hostname: 0.0.0.0                # Bind address
  cache_max_capacity: 4294967296   # Max cache size (4GB)
  operator_message: "Drone by Deathwing"
  middleware_connection_threads: 8  # HTTP connection pool size
```

#### Backend Configuration

Define your backend servers:

```yaml
backends:
  hived: http://haproxy:7008
  hivemind: http://haproxy:7002
  hafah: http://haproxy:7003
  hived-sync: http://haproxy:7006
```

#### URL Routing

Route specific API methods to appropriate backends:

```yaml
urls:
  bridge: hivemind
  hived: hived
  appbase.condenser_api.get_block: hived
  appbase.block_api.get_block: hafah
  # ... more routes
```

#### TTL Configuration

Set cache TTL (Time To Live) for different methods:

```yaml
ttls:
  hived: 3
  hived.login_api: NO_CACHE
  hived.network_broadcast_api: NO_CACHE
  hived.database_api.get_block: EXPIRE_IF_REVERSIBLE
  bridge.get_discussion: 6
  # ... more TTL settings
```

TTL values can be:
- **Positive integer**: Cache for that many seconds
- **NO_CACHE**: Don't cache this method
- **NO_EXPIRE**: Cache forever
- **EXPIRE_IF_REVERSIBLE**: Cache for 9 seconds if reversible, forever if irreversible

#### Timeouts

Configure request timeouts:

```yaml
timeouts:
  hived: 5
  hived.network_broadcast_api: 0  # 0 = no timeout
  bridge: 30
```

---

### Cached API Methods<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

The list of which methods are cached and their cache TTL is configured in the `config.yaml` file. The keys used to specify the method names in the config file follow Jussi's rules for parsing method names, so you should be able to port your existing Jussi `config.json` easily.

### Endpoints<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

The application has the following two primary endpoints:

**`GET /`**: Health check endpoint that returns the application status, version, and operator message in JSON format.

Example response:
```json
{
  "status": "OK",
  "version": "0.3.0",
  "operator_message": "Drone by Deathwing"
}
```

**`POST /`**: API call endpoint that takes the JSON-RPC request, caches the response (if supported), and returns the response data.

Example request:
```bash
curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_dynamic_global_properties", "params":[], "id":1}' http://localhost:9000
```

---

### Repository<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

* Repository: [gitlab.syncad.com/hive/drone](https://gitlab.syncad.com/hive/drone)
* Issues: [gitlab.syncad.com/hive/drone/-/issues](https://gitlab.syncad.com/hive/drone/-/issues)

---
