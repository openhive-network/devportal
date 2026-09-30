# Hive devportal MCP server

Reference [Model Context Protocol](https://modelcontextprotocol.io) server for Hive developer docs and JSON-RPC. It is a local stdio process. It is **not** a public hosted endpoint, and it does **not** sign transactions or hold keys.

This note is the design for Work Item [#87](https://gitlab.syncad.com/hive/devportal/-/work_items/87). Tools come from the OpenRPC document published with the portal (`/openrpc.json`, MR !182), so method definitions are not hand-copied.

## Tools and resources

| Kind | Name | Role |
| --- | --- | --- |
| Tool | `list_methods` | Search the OpenRPC catalog (name, API, summary). No network call. |
| Tool | `get_method_schema` | One method: `paramStructure`, params, result schema, one example. |
| Tool | `hive_rpc_call` | JSON-RPC POST to an allowlisted HTTPS node. Catalog methods only. |
| Tool | `fetch_doc_page` | Plain text of a `developers.hive.io` or staging page. |
| Resource | `hive://schema/openrpc` | Catalog summary (source, namespaces, method count). |
| Resource template | `hive://method/{name}` | Same payload as `get_method_schema`. Not enumerated (hundreds of methods). |

Individual RPC methods are **not** registered as separate MCP tools. A 280-tool list would crowd the agent context and drift from OpenRPC. Agents discover a method, read its descriptor, then call it.

`condenser_api` methods use a positional `params` array. AppBase methods such as `database_api` use a named `params` object. Shapes are inferred from documented examples; the HTML API reference stays authoritative.

## Safety

Denied unless `HIVE_MCP_ALLOW_BROADCAST=1`:

- `network_broadcast_api.*`
- any method whose name contains `.broadcast_` (including `condenser_api.broadcast_transaction` and `wallet_bridge_api.broadcast_transaction`)
- specialized mutators: `chain_api.push_transaction`, `network_node_api.add_node`, `network_node_api.set_allowed_peers`, `witness_api.enable_fast_confirm`, `witness_api.disable_fast_confirm`

Always denied (broadcast opt-in does not unlock these):

- `debug_node_api.*`, including key-bearing `debug_generate_blocks` and `debug_generate_blocks_until`

The opt-in does not add a signing path. The process has no key parameter. Sign with Beekeeper, Keychain, or HiveAuth in a different process, then pass an already-signed transaction only if you enabled broadcast on a host you trust.

`hive_rpc_call` nodes must be `https` origins on the built-in list (`api.hive.blog`, `api.deathwing.me`, `anyx.io`) or `HIVE_MCP_NODES`. IP addresses, credentials, non-443 ports, and subpaths are rejected. Redirects are refused.

`fetch_doc_page` allows only `https://developers.hive.io` and `http(s)://developers-staging.hive.io`. Other hosts, including link-local metadata IPs, are rejected before fetch.

Default rate limit is 60 tool calls per minute per process (`HIVE_MCP_RATE_LIMIT`). There is no multi-tenant auth because the server is stdio-local. Do not put it on a public port.

## Schema source

On startup the server tries, in order:

1. `--schema <file>` or `HIVE_OPENRPC_PATH`
2. `HIVE_OPENRPC_URL` if set (no fallback)
3. `https://developers.hive.io/openrpc.json`, then `http://developers-staging.hive.io/openrpc.json`

Production does not serve `/openrpc.json` until `develop` is released to `master`. Staging already does, so the fallback keeps a checkout working before that release. After production publishes the file, the first URL wins.

## Install

From a checkout of this repository (Node.js 20+):

```bash
cd mcp
npm ci
npm test
npm start
```

`npm start` speaks MCP on stdio and logs to stderr. Point `--schema` at a local `openrpc.json` if you do not want the network fetch:

```bash
node src/index.js --schema /path/to/openrpc.json
```

### Cursor / MCP client config

```json
{
  "mcpServers": {
    "hive": {
      "command": "node",
      "args": ["/absolute/path/to/devportal/mcp/src/index.js"]
    }
  }
}
```

Optional environment on that entry: `HIVE_MCP_ALLOW_BROADCAST`, `HIVE_MCP_NODES`, `HIVE_MCP_DEFAULT_NODE`, `HIVE_OPENRPC_URL`, `HIVE_OPENRPC_PATH`, `HIVE_MCP_RATE_LIMIT`.

### Docker

The image is also stdio-only. Do not publish it without your own auth and network policy.

```bash
docker build -t hive-devportal-mcp mcp
docker run -i --rm hive-devportal-mcp
```

## Out of scope

- Custodial keys, Keychain bridging, or replacing WAX / Workerbee / dhive
- A public multi-tenant MCP URL
- Full-text search over every tutorial (use `fetch_doc_page` with a path from `llms.txt`)
