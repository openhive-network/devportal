---
title: titles.workerbee_subscribe_filter
position: 2
description: descriptions.workerbee_subscribe_filter
exclude: true
layout: full
canonical_url: workerbee-subscribe-filter.html
---

Subscribe to live Hive activity with Workerbee observers: posts, comments, votes, custom JSON, and combined filters. Assumes you already [installed and started a bot]({{ '/tutorials-recipes/workerbee-getting-started.html' | relative_url }}).

Full category tree: [predefined_filter_categories.md](https://gitlab.syncad.com/hive/workerbee/-/blob/main/docs/predefined_filter_categories.md). Stack guidance: [Building agents]({{ '/quickstart/building_agents.html' | relative_url }}) · [SDK Reference]({{ '/resources/#resources-sdk-reference' | relative_url }}) · [llms.txt](https://developers.hive.io/llms.txt).

## Setup (reminder)

```typescript
import { createHiveChain } from "@hiveio/wax";
import WorkerBee from "@hiveio/workerbee";

const chain = await createHiveChain({ apiEndpoint: "https://api.hive.blog/" });
const bot = new WorkerBee(chain);
bot.start();
```

## Filter by account and content type

```typescript
// New posts by one or more authors
bot.observe.onPosts("gtg", "blocktrades").subscribe({
  next(data) {
    for (const account of Object.keys(data.posts)) {
      for (const { operation } of data.posts[account] ?? []) {
        console.log(`Post @${operation.author}/${operation.permlink}`);
      }
    }
  },
  error: console.error
});

// Comments
bot.observe.onComments("gtg").subscribe({
  next(data) {
    console.log("comment event", data);
  },
  error: console.error
});

// Votes involving accounts
bot.observe.onVotes("gtg").subscribe({
  next(data) {
    console.log("vote event", data);
  },
  error: console.error
});

// Application custom_json by id (agent / game payloads)
bot.observe.onCustomOperation("follow").subscribe({
  next(data) {
    for (const { operation } of data.customOperations["follow"] ?? []) {
      console.log("custom_json follow", operation);
    }
  },
  error: console.error
});
```

## Combine filters (implicit OR, explicit `.or` / `.and`)

Chained observers default to **OR** (fire when any condition matches; duplicates in one cycle are coalesced):

```typescript
bot.observe
  .onImpactedAccounts("alice", "bob")
  .onPosts("gtg")
  .subscribe({
    next(data) {
      console.log("account activity and/or gtg post", data);
    },
    error: console.error
  });
```

Require **all** conditions with `.and` (AND binds tighter than OR):

```typescript
import { EManabarType } from "@hiveio/wax";

bot.observe
  .onAccountsFullManabar(EManabarType.RC, "initminer")
  .and
  .onNewAccount()
  .subscribe({
    next(data) {
      console.log("full RC and a new account in the same cycle", data);
    },
    error: console.error
  });
```

## Historical then live

`providePastOperations` backfills a block range (or relative time like `'-7d'`), then you can keep the same observer style for live data:

```typescript
bot.providePastOperations(96_549_390, 96_549_415)
  .onPosts("gtg")
  .subscribe({
    next(data) {
      console.log("historical posts", data);
    },
    error: console.error,
    complete() {
      console.log("backfill complete");
    }
  });
```

## Unsubscribe

```typescript
const sub = bot.observe.onBlock().subscribe({ next() { /* ... */ }, error: console.error });
// later:
sub.unsubscribe();
```

## Related

- [Getting started]({{ '/tutorials-recipes/workerbee-getting-started.html' | relative_url }})
- [Errors and reconnect]({{ '/tutorials-recipes/workerbee-errors-reconnect.html' | relative_url }})
- Legacy DHive streaming contrast: [Streaming blockchain transactions]({{ '/tutorials-recipes/virtual-operations-when-streaming-blockchain-transactions.html' | relative_url }})
