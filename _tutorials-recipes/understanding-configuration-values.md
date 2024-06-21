---
title: titles.understanding_configuration_values
position: 1
description: Low level blockchain constants
exclude: true
layout: full
canonical_url: understanding-configuration-values.html
---

### Intro

These values underpin the behavior of the entire blockchain.  In a sense, each witness votes for these configuration values every time they sign a block.  Unlike many of the [Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }}), these values never change at runtime (e.g., as a witness, in order to change them, you typically must shut down your node, make the change, recompile, and run).

See: [config.hpp](https://gitlab.syncad.com/hive/hive/-/blob/master/libraries/protocol/include/hive/protocol/config.hpp)

Usually, these configuration values are universally adhered to, but there are situations where these values can and should be altered, like in the case of deploying a new blockchain (typically a testnet).  Some of the values that do not affect consensus, like [`HIVE_SOFT_MAX_COMMENT_DEPTH`](#HIVE_SOFT_MAX_COMMENT_DEPTH), are allowed to change to some extent.

### Sections

<ul>
<li>Fields</li>
<ul>
{% for sections in site.data.objects.config %}
{% assign sorted_fields = sections.fields | sort: 'name' %}
{% for field in sorted_fields %}
{% if field.purpose %}
{% unless field.removed %}
<li><a href="#{{ field.name | slug}}"><code>{{field.name}}</code></a></li>
{% endunless %}
{% endif %}
{% endfor %}
{% for field in sorted_fields %}
{% if field.purpose %}
{% if field.removed %}
<li><del><a href="#{{ field.name | slug}}"><code>{{field.name}}</code></a></del></li>
{% endif %}
{% endif %}
{% endfor %}
{% endfor %}
</ul>
<li><a href="#not-covered">Not Covered</a></li>
<li><a href="#example-method-call">Example Method Call</a></li>
<li><a href="#example-output">Example Output</a></li>
</ul>

{% for sections in site.data.objects.config %}
{% assign sorted_fields = sections.fields | sort: 'name' %}
{% for field in sorted_fields %}
{% if field.purpose %}
<h3 id="{{field.name | slug}}">
<code>{{field.name}}</code>
<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm"></i></a>
</h3>
<ul style="float: right; list-style: none;">
{% if field.deprecated %}
<li class="warning"><strong><small>Deprecated</small></strong></li>
{% elsif field.removed %}
<li class="error"><strong><small>Removed</small></strong></li>
{% endif %}
{% if field.since %}
<li class="success"><strong><small>Since: {{field.since}}</small></strong></li>
{% endif %}
{% assign keywords = field.name | keywordify | escape %}
{% assign search_url = '/search/?q=' | append: keywords | split: '_' | join: ' ' %}
<li class="info"><strong><small><a href="{{ search_url | relative_url }}">Related <i class="fas fa-search fa-xs"></i></a></small></strong></li>
</ul>
{{ field.purpose | liquify | markdownify }}
{% if field.examples.size > 0 %}
<ul>
<li>Examples:
<ul>
{% for example in field.examples %}
<li>{{example | liquify | markdownify }}</li>
{% endfor %}
</ul>
</li>
</ul>
{% endif %}
{% if field.links.size > 0 %}
{% assign links = field.links | join: ', ' | liquify %}
See: {{ links }}
{% endif %}
<br />
<br />
<hr />
{% endif %}
{% endfor %}
{% endfor %}

### `Not Covered`<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

Fields not covered in this recipe are:

<ul>
{% for sections in site.data.objects.config %}
{% assign sorted_fields = sections.fields | sort: 'name' %}
{% for field in sorted_fields %}
{% unless field.purpose %}
<li><code>{{field.name}}</code></li>
{% endunless %}
{% endfor %}
{% endfor %}
</ul>

### Example Method Call<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

```bash
curl -s --data '{"jsonrpc":"2.0", "method":"condenser_api.get_config", "params":[], "id":1}' https://api.hive.blog
```

### Example Output<a style="float: right" href="#sections"><i class="fas fa-chevron-up fa-sm" /></a>

```json
{
   "jsonrpc":"2.0",
   "result":{
      "IS_TEST_NET":true,
      "TESTNET_BLOCK_LIMIT":3000000,
      "SMT_MAX_VOTABLE_ASSETS":2,
      "SMT_VESTING_WITHDRAW_INTERVAL_SECONDS":604800,
      "SMT_UPVOTE_LOCKOUT":43200,
      "SMT_EMISSION_MIN_INTERVAL_SECONDS":21600,
      "SMT_EMIT_INDEFINITELY":4294967295,
      "SMT_MAX_NOMINAL_VOTES_PER_DAY":1000,
      "SMT_MAX_VOTES_PER_REGENERATION":7000,
      "SMT_DEFAULT_VOTES_PER_REGEN_PERIOD":50,
      "SMT_DEFAULT_PERCENT_CURATION_REWARDS":2500,
      "SMT_INITIAL_VESTING_PER_UNIT":1000000,
      "SMT_BALLAST_SUPPLY_PERCENT":10,
      "HBD_SYMBOL":{"nai":"@@000000013", "precision":3},
      "HIVE_INITIAL_VOTE_POWER_RATE":40,
      "HIVE_REDUCED_VOTE_POWER_RATE":10,
      "HIVE_100_PERCENT":10000,
      "HIVE_1_PERCENT":100,
      "HIVE_ACCOUNT_RECOVERY_REQUEST_EXPIRATION_PERIOD":12000000,
      "HIVE_ACTIVE_CHALLENGE_COOLDOWN":"86400000000",
      "HIVE_ACTIVE_CHALLENGE_FEE":{"amount":"2000", "precision":3, "nai":"@@000000021"},
      "HIVE_ADDRESS_PREFIX":"TST",
      "HIVE_APR_PERCENT_MULTIPLY_PER_BLOCK":"102035135585887",
      "HIVE_APR_PERCENT_MULTIPLY_PER_HOUR":"119577151364285",
      "HIVE_APR_PERCENT_MULTIPLY_PER_ROUND":"133921203762304",
      "HIVE_APR_PERCENT_SHIFT_PER_BLOCK":87,
      "HIVE_APR_PERCENT_SHIFT_PER_HOUR":77,
      "HIVE_APR_PERCENT_SHIFT_PER_ROUND":83,
      "HIVE_BANDWIDTH_AVERAGE_WINDOW_SECONDS":604800,
      "HIVE_BANDWIDTH_PRECISION":1000000,
      "HIVE_BENEFICIARY_LIMIT":128,
      "HIVE_BLOCKCHAIN_PRECISION":1000,
      "HIVE_BLOCKCHAIN_PRECISION_DIGITS":3,
      "HIVE_BLOCKCHAIN_HARDFORK_VERSION":"0.23.0",
      "HIVE_BLOCKCHAIN_VERSION":"0.23.0",
      "HIVE_BLOCK_INTERVAL":3,
      "HIVE_BLOCKS_PER_DAY":28800,
      "HIVE_BLOCKS_PER_HOUR":1200,
      "HIVE_BLOCKS_PER_YEAR":10512000,
      "HIVE_CASHOUT_WINDOW_SECONDS":3600,
      "HIVE_CASHOUT_WINDOW_SECONDS_PRE_HF12":3600,
      "HIVE_CASHOUT_WINDOW_SECONDS_PRE_HF17":3600,
      "HIVE_CHAIN_ID":"18dcf0a285365fc58b71f18b3d3fec954aa0c141c44e4e5cb4cf777b9eab274e",
      "HIVE_COMMENT_REWARD_FUND_NAME":"comment",
      "HIVE_COMMENT_TITLE_LIMIT":256,
      "HIVE_CONTENT_APR_PERCENT":3875,
      "HIVE_CONTENT_CONSTANT_HF0":"2000000000000",
      "HIVE_CONTENT_CONSTANT_HF21":"2000000000000",
      "HIVE_CONTENT_REWARD_PERCENT_HF16":7500,
      "HIVE_CONTENT_REWARD_PERCENT_HF21":6500,
      "HIVE_CONVERSION_DELAY":"302400000000",
      "HIVE_CONVERSION_DELAY_PRE_HF_16":"604800000000",
      "HIVE_CREATE_ACCOUNT_DELEGATION_RATIO":5,
      "HIVE_CREATE_ACCOUNT_DELEGATION_TIME":"2592000000000",
      "HIVE_CREATE_ACCOUNT_WITH_HIVE_MODIFIER":30,
      "HIVE_CURATE_APR_PERCENT":3875,
      "HIVE_CUSTOM_OP_DATA_MAX_LENGTH":8192,
      "HIVE_CUSTOM_OP_ID_MAX_LENGTH":32,
      "HIVE_DEFAULT_HBD_INTEREST_RATE":1000,
      "HIVE_DOWNVOTE_POOL_PERCENT_HF21":2500,
      "HIVE_EQUIHASH_K":6,
      "HIVE_EQUIHASH_N":140,
      "HIVE_FEED_HISTORY_WINDOW":84,
      "HIVE_FEED_HISTORY_WINDOW_PRE_HF_16":168,
      "HIVE_FEED_INTERVAL_BLOCKS":1200,
      "HIVE_GENESIS_TIME":"2016-01-01T00:00:00",
      "HIVE_HARDFORK_REQUIRED_WITNESSES":17,
      "HIVE_HF21_CONVERGENT_LINEAR_RECENT_CLAIMS":"503600561838938636",
      "HIVE_INFLATION_NARROWING_PERIOD":250000,
      "HIVE_INFLATION_RATE_START_PERCENT":978,
      "HIVE_INFLATION_RATE_STOP_PERCENT":95,
      "HIVE_INIT_MINER_NAME":"initminer",
      "HIVE_INIT_PUBLIC_KEY_STR":"TST6LLegbAgLAy28EHrffBVuANFWcFgmqRMW13wBmTExqFE9SCkg4",
      "HIVE_INIT_SUPPLY":"250000000000",
      "HIVE_HBD_INIT_SUPPLY":"7000000000",
      "HIVE_INIT_TIME":"1970-01-01T00:00:00",
      "HIVE_IRREVERSIBLE_THRESHOLD":7500,
      "HIVE_LIQUIDITY_APR_PERCENT":750,
      "HIVE_LIQUIDITY_REWARD_BLOCKS":1200,
      "HIVE_LIQUIDITY_REWARD_PERIOD_SEC":3600,
      "HIVE_LIQUIDITY_TIMEOUT_SEC":"604800000000",
      "HIVE_MAX_ACCOUNT_CREATION_FEE":1000000000,
      "HIVE_MAX_ACCOUNT_NAME_LENGTH":16,
      "HIVE_MAX_ACCOUNT_WITNESS_VOTES":30,
      "HIVE_MAX_ASSET_WHITELIST_AUTHORITIES":10,
      "HIVE_MAX_AUTHORITY_MEMBERSHIP":40,
      "HIVE_MAX_BLOCK_SIZE":393216000,
      "HIVE_SOFT_MAX_BLOCK_SIZE":2097152,
      "HIVE_MAX_CASHOUT_WINDOW_SECONDS":86400,
      "HIVE_MAX_COMMENT_DEPTH":65535,
      "HIVE_MAX_COMMENT_DEPTH_PRE_HF17":6,
      "HIVE_MAX_FEED_AGE_SECONDS":604800,
      "HIVE_MAX_INSTANCE_ID":"281474976710655",
      "HIVE_MAX_MEMO_SIZE":2048,
      "HIVE_MAX_WITNESSES":21,
      "HIVE_MAX_MINER_WITNESSES_HF0":1,
      "HIVE_MAX_MINER_WITNESSES_HF17":0,
      "HIVE_MAX_PERMLINK_LENGTH":256,
      "HIVE_MAX_PROXY_RECURSION_DEPTH":4,
      "HIVE_MAX_RATION_DECAY_RATE":1000000,
      "HIVE_MAX_RESERVE_RATIO":20000,
      "HIVE_MAX_RUNNER_WITNESSES_HF0":1,
      "HIVE_MAX_RUNNER_WITNESSES_HF17":1,
      "HIVE_MAX_SATOSHIS":"4611686018427387903",
      "HIVE_MAX_SHARE_SUPPLY":"1000000000000000",
      "HIVE_MAX_SIG_CHECK_DEPTH":2,
      "HIVE_MAX_SIG_CHECK_ACCOUNTS":125,
      "HIVE_MAX_TIME_UNTIL_EXPIRATION":3600,
      "HIVE_MAX_TRANSACTION_SIZE":65536,
      "HIVE_MAX_UNDO_HISTORY":10000,
      "HIVE_MAX_URL_LENGTH":127,
      "HIVE_MAX_VOTE_CHANGES":5,
      "HIVE_MAX_VOTED_WITNESSES_HF0":19,
      "HIVE_MAX_VOTED_WITNESSES_HF17":20,
      "HIVE_MAX_WITHDRAW_ROUTES":10,
      "HIVE_MAX_WITNESS_URL_LENGTH":2048,
      "HIVE_MIN_ACCOUNT_CREATION_FEE":0,
      "HIVE_MIN_ACCOUNT_NAME_LENGTH":3,
      "HIVE_MIN_BLOCK_SIZE_LIMIT":65536,
      "HIVE_MIN_BLOCK_SIZE":115,
      "HIVE_MIN_CONTENT_REWARD":{"amount":"1000", "precision":3, "nai":"@@000000021"},
      "HIVE_MIN_CURATE_REWARD":{"amount":"1000", "precision":3, "nai":"@@000000021"},
      "HIVE_MIN_PERMLINK_LENGTH":0,
      "HIVE_MIN_REPLY_INTERVAL":20000000,
      "HIVE_MIN_REPLY_INTERVAL_HF20":3000000,
      "HIVE_MIN_ROOT_COMMENT_INTERVAL":300000000,
      "HIVE_MIN_COMMENT_EDIT_INTERVAL":3000000,
      "HIVE_MIN_VOTE_INTERVAL_SEC":3,
      "HIVE_MINER_ACCOUNT":"miners",
      "HIVE_MINER_PAY_PERCENT":100,
      "HIVE_MIN_FEEDS":7,
      "HIVE_MINING_REWARD":{"amount":"1000", "precision":3, "nai":"@@000000021"},
      "HIVE_MINING_TIME":"2016-01-01T00:00:00",
      "HIVE_MIN_LIQUIDITY_REWARD":{"amount":"1200000", "precision":3, "nai":"@@000000021"},
      "HIVE_MIN_LIQUIDITY_REWARD_PERIOD_SEC":60000000,
      "HIVE_MIN_PAYOUT_HBD":{"amount":"20", "precision":3, "nai":"@@000000013"},
      "HIVE_MIN_POW_REWARD":{"amount":"1000", "precision":3, "nai":"@@000000021"},
      "HIVE_MIN_PRODUCER_REWARD":{"amount":"1000", "precision":3, "nai":"@@000000021"},
      "HIVE_MIN_TRANSACTION_EXPIRATION_LIMIT":15,
      "HIVE_MIN_TRANSACTION_SIZE_LIMIT":1024,
      "HIVE_MIN_UNDO_HISTORY":10,
      "HIVE_NULL_ACCOUNT":"null",
      "HIVE_NUM_INIT_MINERS":1,
      "HIVE_OWNER_AUTH_HISTORY_TRACKING_START_BLOCK_NUM":1,
      "HIVE_OWNER_AUTH_RECOVERY_PERIOD":60000000,
      "HIVE_OWNER_CHALLENGE_COOLDOWN":"86400000000",
      "HIVE_OWNER_CHALLENGE_FEE":{"amount":"30000", "precision":3, "nai":"@@000000021"},
      "HIVE_OWNER_UPDATE_LIMIT":0,
      "HIVE_POST_AVERAGE_WINDOW":86400,
      "HIVE_POST_REWARD_FUND_NAME":"post",
      "HIVE_POST_WEIGHT_CONSTANT":1600000000,
      "HIVE_POW_APR_PERCENT":750,
      "HIVE_PRODUCER_APR_PERCENT":750,
      "HIVE_PROXY_TO_SELF_ACCOUNT":"",
      "HIVE_HBD_INTEREST_COMPOUND_INTERVAL_SEC":2592000,
      "HIVE_SECONDS_PER_YEAR":31536000,
      "HIVE_PROPOSAL_FUND_PERCENT_HF0":0,
      "HIVE_PROPOSAL_FUND_PERCENT_HF21":1000,
      "HIVE_RECENT_RSHARES_DECAY_TIME_HF19":"1296000000000",
      "HIVE_RECENT_RSHARES_DECAY_TIME_HF17":"2592000000000",
      "HIVE_REVERSE_AUCTION_WINDOW_SECONDS_HF6":1800,
      "HIVE_REVERSE_AUCTION_WINDOW_SECONDS_HF20":900,
      "HIVE_REVERSE_AUCTION_WINDOW_SECONDS_HF21":300,
      "HIVE_ROOT_POST_PARENT":"",
      "HIVE_SAVINGS_WITHDRAW_REQUEST_LIMIT":100,
      "HIVE_SAVINGS_WITHDRAW_TIME":"259200000000",
      "HIVE_HBD_START_PERCENT_HF14":200,
      "HIVE_HBD_START_PERCENT_HF20":900,
      "HIVE_HBD_STOP_PERCENT_HF14":500,
      "HIVE_HBD_STOP_PERCENT_HF20":1000,
      "HIVE_SECOND_CASHOUT_WINDOW":259200,
      "HIVE_SOFT_MAX_COMMENT_DEPTH":255,
      "HIVE_START_MINER_VOTING_BLOCK":864000,
      "HIVE_START_VESTING_BLOCK":201600,
      "HIVE_TEMP_ACCOUNT":"temp",
      "HIVE_UPVOTE_LOCKOUT_HF7":60000000,
      "HIVE_UPVOTE_LOCKOUT_HF17":300000000,
      "HIVE_UPVOTE_LOCKOUT_SECONDS":300,
      "HIVE_VESTING_FUND_PERCENT_HF16":1500,
      "HIVE_VESTING_WITHDRAW_INTERVALS":13,
      "HIVE_VESTING_WITHDRAW_INTERVALS_PRE_HF_16":104,
      "HIVE_VESTING_WITHDRAW_INTERVAL_SECONDS":604800,
      "HIVE_VOTE_DUST_THRESHOLD":50000000,
      "HIVE_VOTING_MANA_REGENERATION_SECONDS":432000,
      "HIVE_SYMBOL":{"nai":"@@000000021", "precision":3},
      "VESTS_SYMBOL":{"nai":"@@000000037", "precision":6},
      "HIVE_VIRTUAL_SCHEDULE_LAP_LENGTH":"18446744073709551615",
      "HIVE_VIRTUAL_SCHEDULE_LAP_LENGTH2":"340282366920938463463374607431768211455",
      "HIVE_VOTES_PER_PERIOD_SMT_HF":50,
      "HIVE_MAX_LIMIT_ORDER_EXPIRATION":2419200,
      "HIVE_DELEGATION_RETURN_PERIOD_HF0":3600,
      "HIVE_DELEGATION_RETURN_PERIOD_HF20":432000,
      "HIVE_RD_MIN_DECAY_BITS":6,
      "HIVE_RD_MAX_DECAY_BITS":32,
      "HIVE_RD_DECAY_DENOM_SHIFT":36,
      "HIVE_RD_MAX_POOL_BITS":64,
      "HIVE_RD_MAX_BUDGET_1":"17179869183",
      "HIVE_RD_MAX_BUDGET_2":268435455,
      "HIVE_RD_MAX_BUDGET_3":2147483647,
      "HIVE_RD_MAX_BUDGET":268435455,
      "HIVE_RD_MIN_DECAY":64,
      "HIVE_RD_MIN_BUDGET":1,
      "HIVE_RD_MAX_DECAY":4294967295,
      "HIVE_ACCOUNT_SUBSIDY_PRECISION":10000,
      "HIVE_WITNESS_SUBSIDY_BUDGET_PERCENT":12500,
      "HIVE_WITNESS_SUBSIDY_DECAY_PERCENT":210000,
      "HIVE_DEFAULT_ACCOUNT_SUBSIDY_DECAY":347321,
      "HIVE_DEFAULT_ACCOUNT_SUBSIDY_BUDGET":797,
      "HIVE_DECAY_BACKSTOP_PERCENT":9000,
      "HIVE_BLOCK_GENERATION_POSTPONED_TX_LIMIT":5,
      "HIVE_PENDING_TRANSACTION_EXECUTION_LIMIT":200000,
      "HIVE_TREASURY_ACCOUNT":"hive.fund",
      "HIVE_TREASURY_FEE":10000,
      "HIVE_PROPOSAL_MAINTENANCE_PERIOD":3600,
      "HIVE_PROPOSAL_MAINTENANCE_CLEANUP":86400,
      "HIVE_PROPOSAL_SUBJECT_MAX_LENGTH":80,
      "HIVE_PROPOSAL_MAX_IDS_NUMBER":5,
      "HIVE_NETWORK_TYPE":"testnet",
      "HIVE_DB_FORMAT_VERSION":"1"
   },
   "id":1
}
```
