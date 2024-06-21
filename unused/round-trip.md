---
title: titles.round_trip
position: 1
description: |
  Using Hive as your personal "Hash in the Sky"
exclude: true
layout: full
canonical_url: round-trip.html
---

#### Intro

Let's say you have an application and you want to store arbitrary data on the Hive blockchain.

#### Caveats

Typically, applications store their data in a private database.  But there are times when it is desirable to store data in a censorship resistant manner.  Although it is possible to store arbitrary data on the Hive blockchain, it is recommended to only store key information that other applications besides yours might be interested in, to provide interoperability.

For example, if your application stores private details about your user, doing so in a private database would be a better fit.

On the other hand, if your application stores public details about your user, and those details are not already on the Hive blockchain, it would be a good fit for this solution.

Another example might be public game state, if your application is a game.

#### Overview 

First, you define your public model, the stuff your application wants to persist forever.

Next, you bundle your model data as JSON.

Then, you broadcast your JSON to the blockchain.

To retrieve it, you can perform a query on HiveSQL.

Keep in mind that HiveSQL is a server-side solution only.  Browsers cannot directly query HiveSQL.
