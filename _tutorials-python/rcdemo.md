---
title: titles.rc_dev
position: 36
description: descriptions.rc_dev
layout: full
canonical_url: rcdemo.html
---
Full, runnable src of [Power Up Hive](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/36_rcdemo) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-36_rcdemo.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/36_rcdemo)).

### Statelessness

First of all, a word about statelessness.  A great deal of effort has gone into carefully separating stateful from stateless computations.
The reason for this is so that UI's and client libraries can execute stateless algorithms locally.  Local computation is always to be
preferred to RPC-API for performance, stability, scalability and security.

Unfortunately, client library support for RC algorithms is lacking.  This tutorial, and its accompanying script, are intended to
provide guidance to UI and client library maintainers about how to add support for the RC system.

Also see:
* [resource credits]({{ '/search/?q=resource+credits' | relative_url }})

# The RC demo script

To get up and running, I (`theoretical`) have transcribed some key algorithms from C++ to Python.  For example, how many resources
are consumed by a vote transaction?  The `rcdemo` script allows us to find out:

```
>>> from rcdemo import *
>>> count = count_resources(vote_tx, vote_tx_size)
>>> count["resource_state_bytes"]
499232
>>> print(json.dumps(count))
{"resource_count": {"resource_history_bytes": 133, "resource_new_accounts": 0, "resource_market_bytes": 0, "resource_state_bytes": 499232, "resource_execution_time": 0}}
```

The `count_resources()` function is *stateless*.  That means all of the information needed to do the calculation is contained in the transaction itself.  It doesn't
depend on what's happening on the blockchain, or what other users are doing.  [1] [2] [3]

[1] Although it is possible that the calculation will change in future versions of `hived`, for example to correct the [bug]({{ 'https://github.com/steemit/steem/issues/2972' | archived_url }}) where execution time is always reported as zero.

[2] For convenience, some of the constants used in the calculation are exposed by the `size_info` member of `rc_api.get_resource_params()`.  Only a `hived` version upgrade can change any values returned by `rc_api.get_resource_params()`, so it is probably okay to query that API once, on startup or when first needed, and then cache the result forever.  Or even embed the result of `rc_api.get_resource_params()` in the source code of your library or application.

[3] `rcdemo.py` requires you to also input the transaction size into `count_resources()`.  This is because `rcdemo.py` was created to be a standalone script, without a dependence on any particular client library.  If you are integrating `rcdemo.py` into a client library, you might consider using your library's serializer to calculate the transaction size automatically, so the caller of `count_resources()` doesn't have to specify it.

### Resources

Let's go into details on the different kinds of resources which are limited by the RC system.

- `resource_history_bytes` : Number of bytes consumed by the transaction.
- `resource_new_accounts` : Number of accounts created by the transaction.
- `resource_market_bytes` : Number of bytes consumed by the transaction if it contains market operations.
- `resource_state_bytes` : Number of bytes of chain state needed to support the transaction.
- `resource_execution_time` : An estimate of how long the transaction will take to execute.  Zero for now due to [#2972]({{ 'https://github.com/steemit/steem/issues/2972' | archived_url }}).

The resources have different scales.  The resources use fixed-point arithmetic where one "tick" of the resource value is a "fractional" value of the resource.  Right now, the resource scales are scattered in different places.  The `count_resources()` result has the following scale:

- `resource_history_bytes` :  One byte is equal to `1`.
- `resource_new_accounts` :   One account is equal to `1`.
- `resource_market_bytes` :   One byte is equal to `1`.
- `resource_state_bytes` :    One byte which must be stored forever is equal to the `hived` compile-time constant `STATE_BYTES_SCALE`, which is `10000`.  Bytes which must be stored for a bounded amount of time are worth less than `10000`, depending on how long they need to be stored.  The specific constants used in various cases are specified in the `resource_params["size_info"]["resource_state_bytes"]` fields.
- `resource_execution_time` : One nanosecond of CPU time is equal to `1`.  The values are based on benchmark measurements made on a machine similar to `hive.blog` servers.  Some rounding was performed, and a few operations' timings were adjusted to account for additional processing of the virtual operations they cause.

### Resource pool levels

Each resource has a global *pool* which is the number of resources remaining.  The pool code supports fractional resources, the denominator is represented by the `resource_unit` parameter.  So for example, since `resource_params["resource_params"]["resource_market_bytes"]["resource_dynamics_params"]["resource_unit"]` is `10`, a pool level of `15,000,000,000` actually represents `1,500,000,000` bytes.

### Resource credits

The RC cost of each resource depends on the following information:

- How many resources are in the corresponding resource pool
- The global RC regeneration rate, which may be calculated as `total_vesting_shares` / ([`HIVE_RC_REGEN_TIME`](https://gitlab.syncad.com/hive/hive/-/blob/master/libraries/plugins/rc/rc_plugin.cpp#L20) / [`HIVE_BLOCK_INTERVAL`]({{ '/tutorials-recipes/understanding-configuration-values.html#HIVE_BLOCK_INTERVAL' | relative_url }}))`
- The price curve parameters in the corresponding `price_curve_params` object

For convenience, `rcdemo.py` contains an `RCModel` class with all of this information in its fields.

```
>>> print(json.dumps(model.get_transaction_rc_cost( vote_tx, vote_tx_size )))
{"usage": {"resource_count": {"resource_history_bytes": 133, "resource_new_accounts": 0, "resource_market_bytes": 0, "resource_state_bytes": 499232, "resource_execution_time": 0}}, "cost": {"resource_history_bytes": 42136181, "resource_new_accounts": 0, "resource_market_bytes": 0, "resource_state_bytes": 238436287, "resource_execution_time": 0}}
>>> sum(model.get_transaction_rc_cost( vote_tx, vote_tx_size )["cost"].values())
280572468
```

The `model` object created in `rcdemo.py` is an instance of `RCModel` which uses hardcoded values for its pool levels and global RC regeneration rate.  These values were taken from the live network and hardcoded in the `rcdemo.py` source code in late September 2018.  So the RC cost calculation provided out-of-the-box by `rcdemo.py` are approximately correct as of late September 2018, but will become inaccurate as the "live" values drift away from the hardcoded values.  When integrating the `rcdemo.py` code into an application, client library, or another situation where RPC access is feasible, you should understand how your code will query a `hived` RPC endpoint for current values.  (Some libraries will probably choose to do this RPC automagically, other libraries may want to leave this plumbing to user code.)

### Transaction limits

Suppose an account has 15 Hive Power.  How much can it vote?

```
>>> vote_cost = sum(model.get_transaction_rc_cost( vote_tx, vote_tx_size )["cost"].values())
>>> vote_cost
280572468
>>> vote_cost * total_vesting_fund_hive / total_vesting_shares
138.88697555075086
```

This is the amount of Hive Power (in satoshis) that would be needed by an account to transact once per 5 days ([`HIVE_RC_REGEN_TIME`](https://gitlab.syncad.com/hive/hive/-/blob/master/libraries/plugins/rc/rc_plugin.cpp#L20)).
Our 15 HP account has 15000 HP, so it would be able to do `15000 / 138`, or about `108`, such transactions per 5 days.

You can regard the number `138` (or `0.138`) as the "cost" of a "standardized" vote transaction.  It plays an analogous role to a
transaction fee in Bitcoin, but it is not exactly a fee.  Because the word "fee" implies giving up a permanent token with a limited,
controlled emission rate.  It is the amount of HP which will allow a user an additional vote transaction every 5 days (but it might
be slightly more or less, if your vote transactions use a slightly different amount of resources.)

### Integrating the demo script

The `rcdemo.py` script is a standalone Python script with no dependencies, no network access, and no transaction serializer.  It is a port
of the algorithms, and a few example transactions for demo purposes.

Eventually, client library maintainers should integrate `rcdemo.py` or equivalent functionality into each Hive client library.  Such integration
depends on the idioms and conventions of each particular client library, for example:

- A client library with a minimalist, "explicit is better than implicit" philosophy may simply rename `rcdemo`,
delete the example code, add a tiny bit of glue code, and give it to clients largely as-is.
- A client library with an automagic, "invisible RPC" philosophy might provide a transaction may make substantial modifications to `rcdemo`
or expose an interface like `get_rc_cost(tx)` which would conveniently return the RC cost of a transaction.  Since the RC cost depends on
chain state, this `get_rc_cost()` function would call `hived` RPC's (or use cached values) to get additional inputs needed by stateless
algorithms, such as resource pools, `total_vesting_shares`, etc.
- A client library which has a general policy of hard-coding constants from the `hived` C++ source code might distribute
`rc_api.get_resource_parameters()` as part of its source code, as `rc_api.get_resource_parameters()` results can only change in a new
version of `hived`.  (Perhaps this kind of thing is somehow automated in the library's build scripts.)
- A client library whose maintainers don't want to be obligated to make new releases when values in `hived` change as part of a new release,
might instead choose to call `rc_api.get_resource_parameters()`.  Adding extra performance and security overhead in exchange for the
convenience of asking `hived` to report these values.
- A client library with its own `Transaction` class might choose to implement class methods instead of standalone functions.
- A client library in JavaScript, Ruby or Go might transcribe the algorithms in `rcdemo.py` into a different language.

As you can see, integrating support for the RC system into a Hive client library involves a number of architectural and
technical decisions.

Final code:

```python
#!/usr/bin/env python3

import collections

class CountOperationVisitor(object):

    def __init__(self, size_info, exec_info):
        self.market_op_count = 0
        self.new_account_op_count = 0
        self.state_bytes_count = 0
        self.execution_time_count = 0
        self.size_info = size_info
        self.exec_info = exec_info

    def get_authority_byte_count( self, auth ):
        return (self.size_info.authority_base_size
              + self.size_info.authority_account_member_size * len(auth["account_auths"])
              + self.size_info.authority_key_member_size * len(auth["key_auths"])
               )

    def visit_account_create_operation( self, op ):
        self.state_bytes_count += (
           self.size_info.account_object_base_size
         + self.size_info.account_authority_object_base_size
         + self.get_authority_byte_count( op["owner"] )
         + self.get_authority_byte_count( op["active"] )
         + self.get_authority_byte_count( op["posting"] )
         )
        self.execution_time_count += self.exec_info.account_create_operation_exec_time

    def visit_account_create_with_delegation_operation( self, op ):
         self.state_bytes_count += (
           self.size_info.account_object_base_size
         + self.size_info.account_authority_object_base_size
         + self.get_authority_byte_count( op["owner"] )
         + self.get_authority_byte_count( op["active"] )
         + self.get_authority_byte_count( op["posting"] )
         + self.size_info.vesting_delegation_object_base_size
         )
         self.execution_time_count += self.exec_info.account_create_with_delegation_operation_exec_time

    def visit_account_witness_vote_operation( self, op ):
        self.state_bytes_count += self.size_info.witness_vote_object_base_size
        self.execution_time_count += self.exec_info.account_witness_vote_operation_exec_time

    def visit_comment_operation( self, op ):
        self.state_bytes_count += (
             self.size_info.comment_object_base_size
           + self.size_info.comment_object_permlink_char_size * len(op["permlink"].encode("utf8"))
           + self.size_info.comment_object_parent_permlink_char_size * len(op["parent_permlink"].encode("utf8"))
           )
        self.execution_time_count += self.exec_info.comment_operation_exec_time

    def visit_comment_payout_beneficiaries( self, bens ):
        self.state_bytes_count += self.size_info.comment_object_beneficiaries_member_size * len(bens["beneficiaries"])

    def visit_comment_options_operation( self, op ):
        for e in op["extensions"]:
            getattr(self, "visit_"+e["type"])(e["value"])
        self.execution_time_count += self.exec_info.comment_options_operation_exec_time

    def visit_convert_operation( self, op ):
        self.state_bytes_count += self.size_info.convert_request_object_base_size
        self.execution_time_count += self.exec_info.convert_operation_exec_time

    def visit_create_claimed_account_operation( self, op ):
        self.state_bytes_count += (
             self.size_info.account_object_base_size
           + self.size_info.account_authority_object_base_size
           + self.get_authority_byte_count( op["owner"] )
           + self.get_authority_byte_count( op["active"] )
           + self.get_authority_byte_count( op["posting"] )
           )
        self.execution_time_count += self.exec_info.create_claimed_account_operation_exec_time

    def visit_decline_voting_rights_operation( self, op ):
        self.state_bytes_count += self.size_info.decline_voting_rights_request_object_base_size
        self.execution_time_count += self.exec_info.decline_voting_rights_operation_exec_time

    def visit_delegate_vesting_shares_operation( self, op ):
        self.state_bytes_count += max(
           self.size_info.vesting_delegation_object_base_size,
           self.size_info.vesting_delegation_expiration_object_base_size
           )
        self.execution_time_count += self.exec_info.delegate_vesting_shares_operation_exec_time

    def visit_escrow_transfer_operation( self, op ):
        self.state_bytes_count += self.size_info.escrow_object_base_size
        self.execution_time_count += self.exec_info.escrow_transfer_operation_exec_time

    def visit_limit_order_create_operation( self, op ):
        self.state_bytes_count += 0 if op["fill_or_kill"] else self.size_info.limit_order_object_base_size
        self.execution_time_count += self.exec_info.limit_order_create_operation_exec_time
        self.market_op_count += 1

    def visit_limit_order_create2_operation( self, op ):
        self.state_bytes_count += 0 if op["fill_or_kill"] else self.size_info.limit_order_object_base_size
        self.execution_time_count += self.exec_info.limit_order_create2_operation_exec_time
        self.market_op_count += 1

    def visit_request_account_recovery_operation( self, op ):
        self.state_bytes_count += self.size_info.account_recovery_request_object_base_size
        self.execution_time_count += self.exec_info.request_account_recovery_operation_exec_time

    def visit_set_withdraw_vesting_route_operation( self, op ):
        self.state_bytes_count += self.size_info.withdraw_vesting_route_object_base_size
        self.execution_time_count += self.exec_info.set_withdraw_vesting_route_operation_exec_time

    def visit_vote_operation( self, op ):
        self.state_bytes_count += self.size_info.comment_vote_object_base_size
        self.execution_time_count += self.exec_info.vote_operation_exec_time

    def visit_witness_update_operation( self, op ):
        self.state_bytes_count += (
             self.size_info.witness_object_base_size
           + self.size_info.witness_object_url_char_size * len(op["url"].encode("utf8"))
           )
        self.execution_time_count += self.exec_info.witness_update_operation_exec_time

    def visit_transfer_operation( self, op ):
        self.execution_time_count += self.exec_info.transfer_operation_exec_time
        self.market_op_count += 1

    def visit_transfer_to_vesting_operation( self, op ):
        self.execution_time_count += self.exec_info.transfer_to_vesting_operation_exec_time
        self.market_op_count += 1

    def visit_transfer_to_savings_operation( self, op ):
        self.execution_time_count += self.exec_info.transfer_to_savings_operation_exec_time

    def visit_transfer_from_savings_operation( self, op ):
        self.state_bytes_count += self.size_info.savings_withdraw_object_byte_size
        self.execution_time_count += self.exec_info.transfer_from_savings_operation_exec_time

    def visit_claim_reward_balance_operation( self, op ):
        self.execution_time_count += self.exec_info.claim_reward_balance_operation_exec_time

    def visit_withdraw_vesting_operation( self, op ):
        self.execution_time_count += self.exec_info.withdraw_vesting_operation_exec_time

    def visit_account_update_operation( self, op ):
        self.execution_time_count += self.exec_info.account_update_operation_exec_time

    def visit_account_witness_proxy_operation( self, op ):
        self.execution_time_count += self.exec_info.account_witness_proxy_operation_exec_time

    def visit_cancel_transfer_from_savings_operation( self, op ):
        self.execution_time_count += self.exec_info.cancel_transfer_from_savings_operation_exec_time

    def visit_change_recovery_account_operation( self, op ):
        self.execution_time_count += self.exec_info.change_recovery_account_operation_exec_time

    def visit_claim_account_operation( self, op ):
        self.execution_time_count += self.exec_info.claim_account_operation_exec_time

        if int(op["fee"]["amount"]) == 0:
           self.new_account_op_count += 1

    def visit_custom_operation( self, op ):
        self.execution_time_count += self.exec_info.custom_operation_exec_time

    def visit_custom_json_operation( self, op ):
        self.execution_time_count += self.exec_info.custom_json_operation_exec_time

    def visit_custom_binary_operation( self, op ):
        self.execution_time_count += self.exec_info.custom_binary_operation_exec_time

    def visit_delete_comment_operation( self, op ):
        self.execution_time_count += self.exec_info.delete_comment_operation_exec_time

    def visit_escrow_approve_operation( self, op ):
        self.execution_time_count += self.exec_info.escrow_approve_operation_exec_time

    def visit_escrow_dispute_operation( self, op ):
        self.execution_time_count += self.exec_info.escrow_dispute_operation_exec_time

    def visit_escrow_release_operation( self, op ):
        self.execution_time_count += self.exec_info.escrow_release_operation_exec_time

    def visit_feed_publish_operation( self, op ):
        self.execution_time_count += self.exec_info.feed_publish_operation_exec_time

    def visit_limit_order_cancel_operation( self, op ):
        self.execution_time_count += self.exec_info.limit_order_cancel_operation_exec_time

    def visit_witness_set_properties_operation( self, op ):
        self.execution_time_count += self.exec_info.witness_set_properties_operation_exec_time

    def visit_claim_reward_balance2_operation( self, op ):
        self.execution_time_count += self.exec_info.claim_reward_balance2_operation_exec_time

    def visit_smt_setup_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_setup_operation_exec_time

    def visit_smt_cap_reveal_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_cap_reveal_operation_exec_time

    def visit_smt_refund_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_refund_operation_exec_time

    def visit_smt_setup_emissions_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_setup_emissions_operation_exec_time

    def visit_smt_set_setup_parameters_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_set_setup_parameters_operation_exec_time

    def visit_smt_set_runtime_parameters_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_set_runtime_parameters_operation_exec_time

    def visit_smt_create_operation( self, op ):
        self.execution_time_count += self.exec_info.smt_create_operation_exec_time

    def visit_allowed_vote_assets( self, op ):
        pass

    def visit_recover_account_operation( self, op ): pass
    def visit_pow_operation( self, op ): pass
    def visit_pow2_operation( self, op ): pass
    def visit_report_over_production_operation( self, op ): pass
    def visit_reset_account_operation( self, op ): pass
    def visit_set_reset_account_operation( self, op ): pass

    # Virtual ops
    def visit_fill_convert_request_operation( self, op ): pass
    def visit_author_reward_operation( self, op ): pass
    def visit_curation_reward_operation( self, op ): pass
    def visit_comment_reward_operation( self, op ): pass
    def visit_liquidity_reward_operation( self, op ): pass
    def visit_interest_operation( self, op ): pass
    def visit_fill_vesting_withdraw_operation( self, op ): pass
    def visit_fill_order_operation( self, op ): pass
    def visit_shutdown_witness_operation( self, op ): pass
    def visit_fill_transfer_from_savings_operation( self, op ): pass
    def visit_hardfork_operation( self, op ): pass
    def visit_comment_payout_update_operation( self, op ): pass
    def visit_return_vesting_delegation_operation( self, op ): pass
    def visit_comment_benefactor_reward_operation( self, op ): pass
    def visit_producer_reward_operation( self, op ): pass
    def visit_clear_null_account_balance_operation( self, op ): pass

class SizeInfo(object):
    pass

class ExecInfo(object):
    pass

class ResourceCounter(object):
    def __init__(self, resource_params):
        self.resource_params = resource_params
        self.resource_name_to_index = {}
        self._size_info = None
        self._exec_info = None

        self.resource_names = self.resource_params["resource_names"]
        self.STEEM_NUM_RESOURCE_TYPES = len(self.resource_names)
        for i, resource_name in enumerate(self.resource_names):
            self.resource_name_to_index[ resource_name ] = i
        self._size_info = SizeInfo()
        for k, v in self.resource_params["size_info"]["resource_state_bytes"].items():
            setattr(self._size_info, k, v)
        self._exec_info = ExecInfo()
        for k, v in self.resource_params["size_info"]["resource_execution_time"].items():
            setattr(self._exec_info, k, v)
        return

    def __call__( self, tx=None, tx_size=-1 ):
        if tx_size < 0:
            ser = Serializer()
            ser.signed_transaction(tx)
            tx_size = len(ser.flush())
        result = collections.OrderedDict(
            (("resource_count", collections.OrderedDict((
             ("resource_history_bytes", 0),
             ("resource_new_accounts", 0),
             ("resource_market_bytes", 0),
             ("resource_state_bytes", 0),
             ("resource_execution_time", 0),
            ))),)
            )

        resource_count = result["resource_count"]
        resource_count["resource_history_bytes"] += tx_size

        vtor = CountOperationVisitor(self._size_info, self._exec_info)
        for op in tx["operations"]:
            getattr(vtor, "visit_"+op["type"])(op["value"])
        resource_count["resource_new_accounts"] += vtor.new_account_op_count

        if vtor.market_op_count > 0:
           resource_count["resource_market_bytes"] += tx_size

        resource_count["resource_state_bytes"] += (
             self._size_info.transaction_object_base_size
           + self._size_info.transaction_object_byte_size * tx_size
           + vtor.state_bytes_count )

        # resource_count["resource_execution_time"] += vtor.execution_time_count
        return result

def compute_rc_cost_of_resource( curve_params=None, current_pool=0, resource_count=0, rc_regen=0 ):
    if resource_count <= 0:
        if resource_count < 0:
            return -compute_rc_cost_of_resource( curve_params, current_pool, -resource_count, rc_regen )
        return 0
    num = rc_regen
    num *= int(curve_params["coeff_a"])
    num >>= int(curve_params["shift"])
    num += 1
    num *= resource_count

    denom = int(curve_params["coeff_b"])
    denom += max(current_pool, 0)

    num_denom = num // denom
    return num_denom+1

def rd_compute_pool_decay(
   decay_params,
   current_pool,
   dt,
   ):
    if current_pool < 0:
        return -rd_compute_pool_decay( decay_params, -current_pool, dt )
    decay_amount = int(decay_params["decay_per_time_unit"]) * dt
    decay_amount *= current_pool
    decay_amount >>= int(decay_params["decay_per_time_unit_denom_shift"])
    result = decay_amount
    return min(result, current_pool)

class RCModel(object):
    def __init__(self, resource_params=None, resource_pool=None, rc_regen=0 ):
        self.resource_params = resource_params
        self.resource_pool = resource_pool
        self.rc_regen = rc_regen
        self.count_resources = ResourceCounter(resource_params)
        self.resource_names = self.resource_params["resource_names"]

    def get_transaction_rc_cost(self, tx=None, tx_size=-1):
        usage = self.count_resources( tx, tx_size )

        total_cost = 0

        cost = collections.OrderedDict()

        for resource_name in self.resource_params["resource_names"]:
            params = self.resource_params["resource_params"][resource_name]
            pool = int(self.resource_pool[resource_name]["pool"])

            usage["resource_count"][resource_name] *= params["resource_dynamics_params"]["resource_unit"]
            cost[resource_name] = compute_rc_cost_of_resource( params["price_curve_params"], pool, usage["resource_count"][resource_name], self.rc_regen)
            total_cost += cost[resource_name]
        # TODO: Port get_resource_user()
        return collections.OrderedDict( (("usage", usage), ("cost", cost)) )

    def apply_rc_pool_dynamics(self, count):
        block_info = collections.OrderedDict((
           ("dt", collections.OrderedDict()),
           ("decay", collections.OrderedDict()),
           ("budget", collections.OrderedDict()),
           ("usage", collections.OrderedDict()),
           ("adjustment", collections.OrderedDict()),
           ("pool", collections.OrderedDict()),
           ("new_pool", collections.OrderedDict()),
           ))

        for resource_name in self.resource_params["resource_names"]:
            params = self.resource_params["resource_params"][resource_name]["resource_dynamics_params"]
            pool = int(self.resource_pool[resource_name]["pool"])
            dt = 1

            block_info["pool"][resource_name] = pool
            block_info["dt"][resource_name] = dt
            block_info["budget"][resource_name] = int(params["budget_per_time_unit"]) * dt
            block_info["usage"][resource_name] = count[resource_name] * params["resource_unit"]
            block_info["decay"][resource_name] = rd_compute_pool_decay( params["decay_params"], pool - block_info["usage"][resource_name], dt )

            block_info["new_pool"][resource_name] = pool - block_info["decay"][resource_name] + block_info["budget"][resource_name] - block_info["usage"][resource_name]
        return block_info

# These are constants #define in the code
STEEM_RC_REGEN_TIME = 60*60*24*5
STEEM_BLOCK_INTERVAL = 3

# This is the result of rc_api.get_resource_params()
resource_params = {
    "resource_names": [
      "resource_history_bytes",
      "resource_new_accounts",
      "resource_market_bytes",
      "resource_state_bytes",
      "resource_execution_time"
    ],
    "resource_params": {
      "resource_history_bytes": {
        "resource_dynamics_params": {
          "resource_unit": 1,
          "budget_per_time_unit": 347222,
          "pool_eq": "216404314004",
          "max_pool_size": "432808628007",
          "decay_params": {
            "decay_per_time_unit": 3613026481,
            "decay_per_time_unit_denom_shift": 51
          },
          "min_decay": 0
        },
        "price_curve_params": {
          "coeff_a": "12981647055416481792",
          "coeff_b": 1690658703,
          "shift": 49
        }
      },
      "resource_new_accounts": {
        "resource_dynamics_params": {
          "resource_unit": 10000,
          "budget_per_time_unit": 797,
          "pool_eq": 157691079,
          "max_pool_size": 157691079,
          "decay_params": {
            "decay_per_time_unit": 347321,
            "decay_per_time_unit_denom_shift": 36
          },
          "min_decay": 0
        },
        "price_curve_params": {
          "coeff_a": "16484671763857882971",
          "coeff_b": 1231961,
          "shift": 51
        }
      },
      "resource_market_bytes": {
        "resource_dynamics_params": {
          "resource_unit": 10,
          "budget_per_time_unit": 578704,
          "pool_eq": "16030041350",
          "max_pool_size": "32060082699",
          "decay_params": {
            "decay_per_time_unit": 2540365427,
            "decay_per_time_unit_denom_shift": 46
          },
          "min_decay": 0
        },
        "price_curve_params": {
          "coeff_a": "9231393461629499392",
          "coeff_b": 125234698,
          "shift": 53
        }
      },
      "resource_state_bytes": {
        "resource_dynamics_params": {
          "resource_unit": 1,
          "budget_per_time_unit": 231481481,
          "pool_eq": "144269542669147",
          "max_pool_size": "288539085338293",
          "decay_params": {
            "decay_per_time_unit": 3613026481,
            "decay_per_time_unit_denom_shift": 51
          },
          "min_decay": 0
        },
        "price_curve_params": {
          "coeff_a": "12981647055416481792",
          "coeff_b": "1127105802103",
          "shift": 49
        }
      },
      "resource_execution_time": {
        "resource_dynamics_params": {
          "resource_unit": 1,
          "budget_per_time_unit": 82191781,
          "pool_eq": "51225569123068",
          "max_pool_size": "102451138246135",
          "decay_params": {
            "decay_per_time_unit": 3613026481,
            "decay_per_time_unit_denom_shift": 51
          },
          "min_decay": 0
        },
        "price_curve_params": {
          "coeff_a": "12981647055416481792",
          "coeff_b": "400199758774",
          "shift": 49
        }
      }
    },
    "size_info": {
      "resource_state_bytes": {
        "authority_base_size": 40000,
        "authority_account_member_size": 180000,
        "authority_key_member_size": 350000,
        "account_object_base_size": 4800000,
        "account_authority_object_base_size": 400000,
        "account_recovery_request_object_base_size": 320000,
        "comment_object_base_size": 2010000,
        "comment_object_permlink_char_size": 10000,
        "comment_object_parent_permlink_char_size": 20000,
        "comment_object_beneficiaries_member_size": 180000,
        "comment_vote_object_base_size": 470000,
        "convert_request_object_base_size": 480000,
        "decline_voting_rights_request_object_base_size": 280000,
        "escrow_object_base_size": 1190000,
        "limit_order_object_base_size": 147440,
        "savings_withdraw_object_byte_size": 14656,
        "transaction_object_base_size": 6090,
        "transaction_object_byte_size": 174,
        "vesting_delegation_object_base_size": 600000,
        "vesting_delegation_expiration_object_base_size": 440000,
        "withdraw_vesting_route_object_base_size": 430000,
        "witness_object_base_size": 2660000,
        "witness_object_url_char_size": 10000,
        "witness_vote_object_base_size": 400000,
        "STATE_BYTES_SCALE": 10000
      },
      "resource_execution_time": {
        "account_create_operation_exec_time": 57700,
        "account_create_with_delegation_operation_exec_time": 57700,
        "account_update_operation_exec_time": 14000,
        "account_witness_proxy_operation_exec_time": 117000,
        "account_witness_vote_operation_exec_time": 23000,
        "cancel_transfer_from_savings_operation_exec_time": 11500,
        "change_recovery_account_operation_exec_time": 12000,
        "claim_account_operation_exec_time": 10000,
        "claim_reward_balance_operation_exec_time": 50300,
        "comment_operation_exec_time": 114100,
        "comment_options_operation_exec_time": 13200,
        "convert_operation_exec_time": 15700,
        "create_claimed_account_operation_exec_time": 57700,
        "custom_operation_exec_time": 228000,
        "custom_json_operation_exec_time": 228000,
        "custom_binary_operation_exec_time": 228000,
        "decline_voting_rights_operation_exec_time": 5300,
        "delegate_vesting_shares_operation_exec_time": 19900,
        "delete_comment_operation_exec_time": 51100,
        "escrow_approve_operation_exec_time": 9900,
        "escrow_dispute_operation_exec_time": 11500,
        "escrow_release_operation_exec_time": 17200,
        "escrow_transfer_operation_exec_time": 19100,
        "feed_publish_operation_exec_time": 6200,
        "limit_order_cancel_operation_exec_time": 9600,
        "limit_order_create_operation_exec_time": 31700,
        "limit_order_create2_operation_exec_time": 31700,
        "request_account_recovery_operation_exec_time": 54400,
        "set_withdraw_vesting_route_operation_exec_time": 17900,
        "transfer_from_savings_operation_exec_time": 17500,
        "transfer_operation_exec_time": 9600,
        "transfer_to_savings_operation_exec_time": 6400,
        "transfer_to_vesting_operation_exec_time": 44400,
        "vote_operation_exec_time": 26500,
        "withdraw_vesting_operation_exec_time": 10400,
        "witness_set_properties_operation_exec_time": 9500,
        "witness_update_operation_exec_time": 9500
      }
    }
}

# This is the result of get_resource_pool
resource_pool = {
      "resource_history_bytes": {
        "pool": "199290410749"
      },
      "resource_new_accounts": {
        "pool": 24573481
      },
      "resource_market_bytes": {
        "pool": "15970580402"
      },
      "resource_state_bytes": {
        "pool": "132161364601521"
      },
      "resource_execution_time": {
        "pool": "47263115029450"
      }
}

# The value of total_vesting_shares is available from get_dynamic_global_properties()
total_vesting_shares = 397114288290855167
total_vesting_fund_hive = 196576920519

example_transactions = {
   "vote" : {"tx" : {
          "ref_block_num": 12345,
          "ref_block_prefix": 31415926,
          "expiration": "2018-09-28T01:02:03",
          "operations": [
            {
              "type": "vote_operation",
              "value": {
                "voter": "alice1234567890",
                "author": "bobob9876543210",
                "permlink": "hello-world-its-bob",
                "weight": 10000
              }
            }
          ],
          "extensions": [],
          "signatures": [
            "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40"
          ]
        }, "tx_size" : 133},

    "transfer" : {"tx" : {
          "ref_block_num": 12345,
          "ref_block_prefix": 31415926,
          "expiration": "2018-09-28T01:02:03",
          "operations": [
            {
              "type": "transfer_operation",
              "value": {
                "from": "alice1234567890",
                "to": "bobob9876543210",
                "amount" : {"amount":"50000111","precision":3,"nai":"@@000000013"},
                "memo" : "#"+152*"x",
                "permlink": "hello-world-its-bob",
                "weight": 10000
              }
            }
          ],
          "extensions": [],
          "signatures": [
            "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40"
          ]
        }, "tx_size" : 282},

    "long_post" : {"tx" : {
          "ref_block_num": 12345,
          "ref_block_prefix": 31415926,
          "expiration": "2018-09-28T01:02:03",
          "operations":[{"type":"comment_operation","value":{
              "parent_author":"alice1234567890",
              "parent_permlink":"itsover9000",
              "author":"bobob9876543210",
              "permlink":40*"p",
              "title":40*"t",
              "body":7000*"x",
              "json_metadata":2000*"m"
           }},
           {"type":"comment_options_operation",
            "value":{"author":"bobob9876543210",
            "permlink":40*"p",
            "max_accepted_payout":{"amount":"1000000000","precision":3,"nai":"@@000000013"},
            "percent_hive_dollars":10000,
            "allow_votes":True,
            "allow_curation_rewards":True,
            "extensions":[{"type":"comment_payout_beneficiaries","value":{"beneficiaries":[{"account":"coolui1997","weight":1000}]}}]
           }}],
           "extensions":[],
           "signatures":["1f3de3651752238dcaa8ecfbc3a5c49bca50769b0f1af7d01def32578cf33184eb3258572754eefd036cb62adf797d6e3950fb943b5301fc6d6add64adcbe85f94"]
        }, "tx_size" : 9303},

    "short_post" : {"tx":{
          "ref_block_num": 12345,
          "ref_block_prefix": 31415926,
          "expiration": "2018-09-28T01:02:03",
          "operations":[{"type":"comment_operation","value":{
              "parent_author":"alice1234567890",
              "parent_permlink":10*"p",
              "author":"bobob9876543210",
              "permlink":40*"p",
              "title":40*"t",
              "body":500*"x",
              "json_metadata":150*"m"
           }},
           {"type":"comment_options_operation",
            "value":{"author":"bobob9876543210",
            "permlink":40*"p",
            "max_accepted_payout":{"amount":"1000000000","precision":3,"nai":"@@000000013"},
            "percent_hive_dollars":10000,
            "allow_votes":True,
            "allow_curation_rewards":True,
            "extensions":[{"type":"comment_payout_beneficiaries","value":{"beneficiaries":[{"account":"coolui1997","weight":1000}]}}]
           }}],
           "extensions":[],
           "signatures":["1f3de3651752238dcaa8ecfbc3a5c49bca50769b0f1af7d01def32578cf33184eb3258572754eefd036cb62adf797d6e3950fb943b5301fc6d6add64adcbe85f94"]},
        "tx_size" : 952}
   }

vote_tx = example_transactions["vote"]["tx"]
vote_tx_size = example_transactions["vote"]["tx_size"]

import json

count_resources = ResourceCounter(resource_params)

rc_regen = total_vesting_shares // (STEEM_RC_REGEN_TIME // STEEM_BLOCK_INTERVAL)
model = RCModel( resource_params=resource_params, resource_pool=resource_pool, rc_regen=rc_regen )

if __name__ == "__main__":
    for example_name, etx in sorted(example_transactions.items()):
        tx = etx["tx"]
        tx_size = etx["tx_size"]
        tx_cost = model.get_transaction_rc_cost(tx, tx_size)
        total_cost = sum(tx_cost["cost"].values())
        print("{:20}   {:6.3f}".format(example_name, total_cost * total_vesting_fund_hive / (1000.0 * total_vesting_shares)))

```

---

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/36_rcdemo`
1. `python rcdemo.py`
