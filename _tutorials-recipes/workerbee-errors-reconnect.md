---
title: titles.workerbee_errors_reconnect
position: 2
description: descriptions.workerbee_errors_reconnect
exclude: true
layout: full
canonical_url: workerbee-errors-reconnect.html
---

Basic error handling and reconnect patterns for long-running Workerbee bots. Pair with [install / start]({{ '/tutorials-recipes/workerbee-getting-started.html' | relative_url }}) and [filters]({{ '/tutorials-recipes/workerbee-subscribe-filter.html' | relative_url }}). Also see [Building agents]({{ '/quickstart/building_agents.html' | relative_url }}) (node rotation) and [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}).

## Observer `error` callbacks

Always attach `error` on subscriptions. Without a handler, observer failures can be dropped silently:

```typescript
bot.observe.onBlock().subscribe({
  next(data) {
    // handle block
  },
  error(err) {
    console.error("observer error", err);
  }
});
```

## Iteration with thrown errors

Default `for await (const block of bot)` **ignores** errors — the bot’s `[Symbol.asyncIterator]` delegates to `iterate()` with no handler.

On published `@hiveio/workerbee@1.28.4-rc1`, `bot.iterate(...)` returns a plain `AsyncIterator` (`next` / `return` only). It does **not** implement `[Symbol.asyncIterator]`, so `for await (... of bot.iterate(...))` fails TypeScript (**TS2504**) and throws at runtime (`TypeError: … is not async iterable`). Upstream type examples that `for await` the `iterate` result directly are ahead of that package build. Wrap the iterator (or call `.next()` yourself):

```typescript
function asAsyncIterable<T>(iterator: AsyncIterator<T>): AsyncIterable<T> {
  return {
    [Symbol.asyncIterator]() {
      return iterator;
    }
  };
}

try {
  for await (const block of asAsyncIterable(bot.iterate(true))) {
    console.log(block.number);
  }
} catch (err) {
  console.error("iterator failed", err);
  // recreate chain/bot or rotate endpoint, then start again
}
```

```typescript
for await (const block of asAsyncIterable(
  bot.iterate((err) => console.error("soft error", err))
)) {
  console.log(block.number);
}
```

## Stop, start, and delete

```typescript
bot.stop();          // pause the notify interval
bot.start();         // resume (start() stops any existing interval first)
bot.delete();        // tear down bot + managed wax/beekeeper resources
```

After a hard failure, prefer creating a **new** WAX chain and Workerbee instance rather than assuming the old chain is healthy.

## Rotate API endpoints

Do not hard-code a single node in production agents. On timeout or repeated RPC failure, rebuild with the next endpoint. Share one subscribe helper so the **initial** bot and every replacement both get an `error` observer that can rotate:

```typescript
import { createHiveChain } from "@hiveio/wax";
import WorkerBee from "@hiveio/workerbee";

const ENDPOINTS = [
  "https://api.hive.blog/",
  "https://api.deathwing.me/",
  "https://anyx.io/"
];

async function connect(endpointIndex = 0) {
  const apiEndpoint = ENDPOINTS[endpointIndex % ENDPOINTS.length];
  const chain = await createHiveChain({ apiEndpoint });
  const bot = new WorkerBee(chain);
  bot.start();
  return { bot, endpointIndex, apiEndpoint };
}

function subscribeLive(
  liveBot: InstanceType<typeof WorkerBee>,
  onError: (err: unknown) => void
) {
  liveBot.observe.onBlock().subscribe({
    next(data) {
      console.log("block", data.block.number);
    },
    error: onError
  });
}

let { bot, endpointIndex } = await connect(0);

async function reconnect(reason: unknown) {
  console.error("reconnecting:", reason);
  try {
    bot.stop();
    bot.delete();
  } catch {
    /* ignore teardown races */
  }
  ({ bot, endpointIndex } = await connect(endpointIndex + 1));
  subscribeLive(bot, (err) => {
    void reconnect(err);
  });
}

// Required: initial bot must be subscribed or rotation never starts
subscribeLive(bot, (err) => {
  void reconnect(err);
});
```

Higher-level helpers under `@hiveio/workerbee/blog-logic` (`configureEndpoints`, chain reset after timeouts) exist for blog-oriented apps; core bots can stick to the recreate pattern above.

## Related

- Upstream README: [hive/workerbee](https://gitlab.syncad.com/hive/workerbee/-/blob/main/README.md)
- [SDK Reference]({{ '/resources/#resources-sdk-reference' | relative_url }}) · [Tools]({{ '/resources/#resources-tools' | relative_url }}) · [llms.txt](https://developers.hive.io/llms.txt)
