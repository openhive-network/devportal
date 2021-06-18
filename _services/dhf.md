---
title: DHF
position: 5
canonical_url: dhf.html
---

#### Intro

The DHF (Decentralized Hive Fund) is an account on the Hive blockchain (currently [@hive.fund](https://hiveblocks.com/@hive.fund)) that receives 10% of the [annual new supply]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_INFLATION_NARROWING_PERIOD' | relative_url }}).  These funds are dedicated to Hive platform improvements.

Every day a portion of the HBD fund managed by the DHF is distributed to various proposals, depending on **a)** how much the proposal is asking for and **b)** how much approval the proposal has.

> The DHF was a concept proposed by [@blocktrades](https://hiveblocks.com/@blocktrades) to allow Hive users to publicly propose work they are willing to do in exchange for pay. Hive users can then vote on these proposals in almost the same way they vote for witnesses.  It uses stake-weighted votes, but voters can vote for as many proposals as they want.

The Decentralized Hive Fund (DHF) is a proposal-based DPoS financing
alternative.  The DHF places the consensus behind direct financing of
development and other ecosystem-positive projects into the hands of the
stakeholders.  The distribution of the DHF is decentralized by design.  Support
for a proposal is calculated based on the total stake in support of that
proposal. When a user opts to support a number of proposals, their stake
influences the proposals equally.  Support for a proposal may be granted or
removed but the mechanism cannot be used to negate the sum of supporting stake
with a negative vote.  This prevents one single large stakeholder from doubling
the impact of their stake and influencing the remuneration of numerous
proposals, creating a level playing field.

Proposal funding is released when the total value of that supporting stake
surpasses the stake behind a benchmark proposal.  The benchmark proposal itself
may vertically traverse the rankings as per the amount of its supporting stake.
The payments are distributed on a hourly schedule over a set period of time as
specified upon launch of each proposal.  Proposals that surpass the benchmark
proposal and unlock funding will receive the funding as remaining in the total
ask of the proposal minus the time that had passed prior to funding.  The total
amount is only released where the proposal unlocks the funds prior to its
scheduled duration.

#### Tools

* [hivedao.com/](https://hivedao.com/) - Hive Proposals UI by [@dmitrydao](https://hive.blog/@dmitrydao)
* [peakd.com/proposals](https://peakd.com/proposals) - Hive Proposals UI by [@peakd](https://peakd.com/@peakd)
* [wallet.hive.blog/proposals](https://wallet.hive.blog/proposals) - Vote for your favorite Hive proposals without leaving the safety of wallet.hive.blog.
* [joticajulian.github.io/hiveexplorer/#/proposals](https://joticajulian.github.io/hiveexplorer/#/proposals) - Check who voted what by [@jga](https://peakd.com/@jga)
* [hive.blog/@proposalalert/posts](https://hive.blog/@proposalalert/posts) - Follow this account to be notified of new proposals.

#### API

To access the proposal system by JSON-RPC request, see: [`database_api.list_proposals`]({{ '/apidefinitions/#database_api.list_proposals' | relative_url }}).  Proposal creation by broadcast operation, see: [`create_proposal`]({{ '/apidefinitions/#broadcast_ops_create_proposal' | relative_url }}).
