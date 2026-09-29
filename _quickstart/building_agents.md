---
title: titles.building_agents
position: 5
description: descriptions.building_agents
---

Guide for building LLM agents, automation bots, and Cursor/MCP-style tools on Hive. Prefer protocol-compatible libraries, public HTTPS nodes for reads, and constrained signing for writes.

#### Who this is for

- LLM agents and coding assistants that call Hive JSON-RPC or client libraries
- Automation bots that observe chain state, fetch data, and submit transactions
- Cursor, MCP, or similar tool integrations that need a stable stack and safe key handling

#### Preferred stack

Use this ladder unless you have a hard dependency on a legacy client:

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — protocol-compatible transaction and object handling (TypeScript, C++, Python)
2. **Beekeeper** — key management and signing without exposing keys in application logic
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — observe, fetch, and submit automation on top of WAX and Beekeeper
4. **DHive / Hive-JS** — legacy JavaScript clients; fine for existing apps, not preferred for new agent work

| Component | Links |
| --- | --- |
| WAX docs | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| WAX Mintlify site | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| WAX agent index (`llms.txt`) | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| SDK overview | [SDK Libraries]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [SDK Reference]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### Public HTTPS nodes

Point read-only JSON-RPC at a public HTTPS API. Known stables include `api.hive.blog`, `api.deathwing.me`, and `anyx.io`. Prefer the live list and health details on [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}). Do not hard-code a single endpoint in production agents; rotate or fall back when a node is unhealthy.

#### Minimal JSON-RPC example

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

See also [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) and [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }}).

#### Auth and key safety

- Prefer the **posting** key (or Keychain / Beekeeper-managed signing) for agent writes that only need social or `custom_json` authority
- Never put **active** or **owner** keys in agent prompts, chat logs, CI output, or client-side source
- Budget **resource credits (RC)** before high-frequency broadcast; see [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) and the [RC demo (Python)]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- For interactive login flows, see [Authentication]({{ '/quickstart/#quickstart-authentication' | relative_url }}) (HiveSigner, Keychain, HiveAuth)

#### App data and analytics

- Use **`custom_json`** operations for application-specific payloads (id + JSON body) instead of overloading posts when you only need structured app state. Example pattern: [Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- For read-heavy analytics agents, prefer **HAF** (Hive Application Framework) SQL/API access over hammering condenser endpoints. See [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})

#### Workerbee tutorials

End-to-end portal recipes for [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) (current WAX-chain constructor APIs):

- [Workerbee getting started]({{ '/tutorials-recipes/workerbee-getting-started.html' | relative_url }}) — install, start, stream blocks
- [Subscribe and filter]({{ '/tutorials-recipes/workerbee-subscribe-filter.html' | relative_url }}) — accounts, posts/comments/votes, `custom_json`, `.and` / `.or`
- [Errors and reconnect]({{ '/tutorials-recipes/workerbee-errors-reconnect.html' | relative_url }}) — observer errors, `iterate(true)`, stop/start/delete, endpoint rotation

Upstream: [Workerbee](https://gitlab.syncad.com/hive/workerbee) · [filter categories](https://gitlab.syncad.com/hive/workerbee/-/blob/main/docs/predefined_filter_categories.md)

#### Portal machine-readable index

This portal publishes an agent-oriented link dump at [https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt). Pair it with the WAX Mintlify `llms.txt` above when scaffolding Hive tooling.
