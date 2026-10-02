---
title: titles.workerbee_getting_started
position: 2
description: descriptions.workerbee_getting_started
exclude: true
layout: full
canonical_url: workerbee-getting-started.html
---

Install [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee), connect through WAX, and stream live blocks. Prefer this stack for new automation and agent work over legacy DHive streaming patterns.

Canonical upstream: [Workerbee README](https://gitlab.syncad.com/hive/workerbee/-/blob/main/README.md) · [high-level docs](https://hive.pages.syncad.com/workerbee-doc) · [filter categories](https://gitlab.syncad.com/hive/workerbee/-/blob/main/docs/predefined_filter_categories.md). Portal context: [Building agents]({{ '/quickstart/building_agents.html' | relative_url }}), [SDK Reference]({{ '/resources/#resources-sdk-reference' | relative_url }}), [Tools]({{ '/resources/#resources-tools' | relative_url }}), [llms.txt](https://developers.hive.io/llms.txt).

## Requirements

- Node.js **20+**
- npm packages: `@hiveio/workerbee` and peer `@hiveio/wax` (`>= 2.0.0 < 2.1.0` at time of writing)

```bash
npm install @hiveio/workerbee @hiveio/wax
```

Point reads at a public HTTPS node (see [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }})). Examples below use `https://api.hive.blog/`.

## Create a chain and start the bot

Current `@hiveio/workerbee` constructs with a WAX chain interface (not a no-arg constructor):

```typescript
import { createHiveChain } from "@hiveio/wax";
import WorkerBee from "@hiveio/workerbee";

const chain = await createHiveChain({
  apiEndpoint: "https://api.hive.blog/"
});

const bot = new WorkerBee(chain);
bot.start();

console.log("Workerbee running:", bot.running, "version:", bot.getVersion());
```

`start()` begins the live notify loop. Call `bot.stop()` to pause and `bot.delete()` when tearing down (also releases the managed WAX/Beekeeper objects when Workerbee owns them).

## Stream every new block

The bot is an async iterator over live block headers (errors are ignored on the default iterator):

```typescript
for await (const { id, number, timestamp, witness } of bot) {
  console.log(`Block #${number} ${id} @ ${timestamp.toISOString()} by ${witness}`);
}
```

Equivalent observer form:

```typescript
bot.observe.onBlock().subscribe({
  next(data) {
    console.log(`Block #${data.block.number}`);
  },
  error: console.error
});
```

## First account observer

Listen for activity that impacts a specific account:

```typescript
bot.observe.onImpactedAccounts("gtg").subscribe({
  next(data) {
    for (const { transaction } of data.impactedAccounts["gtg"] ?? []) {
      console.log(`Impacted tx ${transaction.id}`);
    }
  },
  error: console.error
});
```

## Next steps

- [Subscribe, filter operations, and reconnect]({{ '/tutorials-recipes/workerbee-subscribe-filter.html' | relative_url }}) — account/type filters, `.and` / `.or`, error handling, endpoint rotation
- [Workerbee errors and reconnect basics]({{ '/tutorials-recipes/workerbee-errors-reconnect.html' | relative_url }})
- Upstream examples: [gitlab.syncad.com/hive/workerbee/-/tree/main/examples](https://gitlab.syncad.com/hive/workerbee/-/tree/main/examples)
