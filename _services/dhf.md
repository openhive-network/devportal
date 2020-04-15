---
title: DHF
position: 5
---

#### Intro

The DHF (Decentralized Hive Fund) is an account on the Hive blockchain (currently [@steem.dao](https://hiveblocks.com/@steem.dao)) that receives 10% of the [annual new supply]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_INFLATION_NARROWING_PERIOD' | relative_url }}).  These funds are dedicated to Hive platform improvements.

Every day a portion of the HBD fund managed by the DHF is distributed to various proposals, depending on **a)** how much the proposal is asking for and **b)** how much approval the proposal has.

> The DHF was a concept proposed by [@blocktrades](https://hiveblocks.com/@blocktrades) to allow Hive users to publicly propose work they are willing to do in exchange for pay. Hive users can then vote on these proposals in almost the same way they vote for witnesses.  It uses stake-weighted votes, but voters can vote for as many proposals as they want.

<sup>See original announcement, when it was called "SPS" on Steem: [https://hive.blog/steem/@steemitblog/hf21-sps-and-eip-explained](https://hive.blog/steem/@steemitblog/hf21-sps-and-eip-explained)</sup>

#### Tools

* [https://hivedao.com/](https://hivedao.com/) - Hive Proposals UI by [@dmitrydao](https://hive.blog/@dmitrydao)
* [https://peakd.com/proposals](https://peakd.com/proposals) - Hive Proposals UI by [@peakd](https://peakd.com/@peakd)
* [https://wallet.hive.blog/proposals](https://wallet.hive.blog/proposals) - Vote for your favorite Hive proposals without leaving the safety of wallet.hive.blog.
<!-- * [https://joticajulian.github.io/steemexplorer/#/proposals](https://joticajulian.github.io/steemexplorer/#/proposals) - Check who voted what. -->
<!-- * [https://steemit.com/@proposalalert](https://steemit.com/@proposalalert) - Follow this account to be notified of new proposals. -->

#### API

To access the proposal system by JSON-RPC request, see: [`database_api.list_proposals`]({{ '/apidefinitions/#database_api.list_proposals' | relative_url }}).  Proposal creation by broadcast operation, see: [`create_proposal`]({{ '/apidefinitions/#broadcast_ops_create_proposal' | relative_url }}).
