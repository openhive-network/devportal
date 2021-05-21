---
title: RC Bandwidth System
position: 1
description: All about the RC bandwidth system, the complete rewrite of the bandwidth system.
exclude: true
layout: full
canonical_url: rc-bandwidth-system.html
---
See also [RC Bandwidth Parameters]({{ '/tutorials-recipes/rc-bandwidth-parameters.html' | relative_url }})

### Introduction

The *RC bandwidth system* is a complete rewrite of the bandwidth system.  Its goals include:

- Enable simple, effective UI feedback to users about bandwidth usage and remaining bandwidth
- Simplify the mental model of what buying additional HP gives users
- Reduce or eliminate unstable feedback in current bandwidth system

### History

HF20:  Initial implementation.

### Resource credits

Each account has a manabar called "resource credits."  Resource credits have the following characteristics:

- RC's are attached to a particular account and cannot be transferred
- An account's maximum RC is proportional to its VESTS
- Transacting uses RC
- Transactions which would cause a negative RC balance are blocked
- RC regenerates over time

### Resources

How many RC's are required for a transaction?  Statelessly compute, for each transaction, how many of each *resource* it takes.  Resources include:

- CPU (mega)cycles
- State memory
- History size

Then each resource has an exchange rate.  If CPU cycles cost 5 RC / megacycle, state memory costs 8 RC / byte, and history size costs 4 RC / byte, a transaction which takes 2 megacycles, creates 50 bytes of state, and has a 150 byte transaction size will cost `2*5 + 50*8 + 150*4 = 1010 RC`.

### Resource budget pools

A *resource budget pool* for each resource type will be established.  The resource budget pool will have a per-block linear increase, a per-block percentage decrease, and a per-transaction decrease.

For example:

- Suppose the per-block resource budget is 2500 megacycles, 5000 state bytes, and 25,000 history bytes.
- Suppose the per-block percentage decrease is 0.02%
- Suppose the pool currently contains 12,000,000 megacycles, 20,000,000 state bytes, and 80,000,000 history bytes.
- Suppose the above transaction (consuming 2 megacycles, 50 state bytes, and 150 history bytes) is the only transaction which occurs.

We can compute the new values as follows:

```
// when transaction is processed
bp.megacycles -= 2;
bp.state_bytes -= 50;
bp.history_bytes -= 150;

// per block additive
bp.megacycles += 2500;
bp.state_bytes += 5000;
bp.history_bytes += 25000;

// per block multiplicative
// of course this would be implemented as integer arithmetic
bp.megacycles *= 0.9998;
bp.state_bytes *= 0.9998;
bp.history_bytes *= 0.9998;
```

### Resource pricing

The resource budget pool can be viewed as the blockchain's "stockpile" of each resource, which it "sells" for RC.  The price of each resource is based on the current level of the stockpile.  Exactly how the price
is determined isn't very important, as long as it is a decreasing, smooth curve.

The specific cost curve is:

```
p(x) = A / (B + x)
```

where `A` and `B` are parameters which may be set to different values for different resources.
