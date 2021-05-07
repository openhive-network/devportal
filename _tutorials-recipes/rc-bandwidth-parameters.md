---
title: RC Bandwidth Parameters
position: 1
description: Analyze the dynamics of the resource budget pool.
exclude: true
layout: full
canonical_url: rc-bandwidth-parameters.html
---

### Parameters

Each pool has its own values of the following constants:

- `budget_time` : Time interval for budgeting.
- `budget` : How much the resource increases linearly over `budget_time`.
- `half_life` : Time until the resource would decay to 50% of its initial size with no load or budget.
- `drain_time` : Time until user RC would decrease to 0% of its capacity in the hypothetical world where all users have saved maximum RC, use all RC and RC regen on this resource, and the resource pool is empty (so the price is at its maximum value and there is budget but no drain).
- `inelasticity_threshold` : Percentage of the equilibrium value that serves as a boundary between elastic and inelastic prices.

### Computed values

Let us analyze the dynamics of the resource budget pool as outlined [here]({{ '/tutorials-recipes/rc-bandwidth-system.html' | relative_url }}) with an eye to establishing values of the parameters.

### Setting p_0

Let `p(x)` be the RC cost curve, `p(x) = A / (B + x)`.

Let's denote as `p_0` the value of `p(0)`, which is of course `p_0 = A / B`.  In other words,`p_0` is the price when there are no resources in the pool.  Let's set up a worst-case scenario:

- Suppose there are no resources in the pool
- Suppose all users have maximum RC reserves
- Suppose all users spend all RC reserves and regen on this resource
- Suppose all users run out of resources at time `t_drain`

Then we can solve for `p_0` in terms of `t_drain` and the budget:

```
global_rc_capacity + global_rc_regen * drain_time = p_0 * budget * drain_time
p_0 = (global_rc_capacity + global_rc_regen * drain_time) / (budget * drain_time)
```

Suppose `drain_time = 1 hour`.  Then the interpretation of this equation is that, in an hour, users in the aggregate can only muster RC equal to their RC capacity plus an hour's worth of RC regen, call this much RC `rc_1h`.  If we say this RC "should" be *just enough* to pay for `res_1h`, 1 hour's worth of a single resource (say, an hour's worth of history bytes).  That implies a resource price of `rc_1h / res_1h`, which is the price we set the value of `p_0` to.

If we substitute for `global_rc_capacity` and simplify, we get an alternative expression for `p_0` which may be useful for some analysis:

```
p_0 = (global_rc_capacity + global_rc_regen * drain_time) / (budget * drain_time)
    = (global_rc_regen * rc_regen_time + global_rc_regen * drain_time) / (budget * drain_time)
    = (global_rc_regen / budget) * (1 + rc_regen_time / drain_time)
```

The first multiplicative term, `global_rc_regen / budget`, is the *balanced budget price* which would cause spending to match outflow; let us say `p_bb = global_rc_regen / budget`.  This is the equilibrium price if users have no reserves and spend all RC's on this resource.  This is multiplied by a multiplier which represents the temporary level the price can rise to, which is ultimately unsustainable due to finite reserves.

### Setting B

What about the constant `B`?  When `x` is much smaller than `B`:

- The value of `p(x)` is approximately `A / B`
- Price `p(x)` is (almost) *inelastic* with respect to pool size `x`
- A small percentage change in `x` doesn't change `p(x)` much)

When `x` is much larger than `B` the opposite is true:

- The value of `p(x)` is approximately `A / x`
- Price `p(x)` is (almost) *elastic* with respect to pool size `x`
- A small percentage change in `x` causes an almost equal in magnitude percentage change in `p(x)`)

So while `p(x)` is never fully elastic or inelastic, you may think of `B` as being near the "midpoint" of the "transition" from almost perfectly inelastic (for small `x`) to almost perfectly elastic (for large `x`).  This makes sense, since a perfectly elastic price is desirable (when possible) but unstable when the pool goes to zero (a halving of the pool results in the doubling of the price, meaning the price "doubles infinite times" as the pool goes toward zero, "halving infinite times").

Where should this transition occur?  The simple answer is a small fraction of the pool's equilibrium size at no load, say `1%`, or perhaps `1/128`.

#### Inelasticity proof

A more rigorous way to say that `p(x)` is (almost) inelastic is that, for any small value `∊`, there exists some `x` small enough such that, for any small value `δ`, we have `f(x) / f((1+δ)*x) < 1+δ*∊`.  (This can be interpreted as saying the percentage change in `f(x)` in response to a percentage change in `x` dies out as `x →0⁺`.)

To prove this, set `x = B*∊`.  Then:

```
f(x) / f((1+δ)*x) = (A / (B+x)) / (A / (B+(1+δ)*x))
   = (B+x+δ*x) / (B+x)
   = 1 + δ*x / (B+x)
   < 1 + δ*x / B
   = 1 + δ*∊
```

#### Elasticity proof

TODO:  State/prove similar condition for elasticity case.

### Decay rate

Let `τ` be the [time constant](https://en.wikipedia.org/wiki/Time_constant) for the decay rate.  (The decay constant is [proportional to](https://en.wikipedia.org/wiki/Time_constant#Exponential_decay) the half-life.)  The value of `τ` is essentially how much time it takes for the system to "forget" about past non-usage, and places a "soft limit" on the possibility of a very long burst of very high activity being allowed as a result of "saving up" months or years worth of inactivity.  The value of `τ` is per-resource, and we've determined that resources should have short-term and long-term versions with different `τ` values.  For short-term `τ` value, I recommend 1 hour.  For the long-term `τ` value, I recommend 15 days.

If `Δt` time passes, then the exponential decay step of updating the pool should be `pool -= Δt * pool / τ`.

The no-load equilibrium pool size then occurs when `Δt * pool_eq / τ = Δt * budget_per_sec`, or `pool_eq = τ * budget_per_sec`.

### Discount term

Above, we set implicitly the largest (zero-stockpile) price `p_0` based on `drain_time`.  It may also be useful to set the smallest possible price `p_eq` to something other than the value implied by the above equations.  To do this, we can simply shift the curve downward by a factor of `D`, and scale the curve up so `p(0) = p_0`.

To elaborate:

First, define `p(x)` with discount term `D` such that

```
p(x) = (A / (B + x)) - D
```

Then set `B = inelasticity_threshold * pool_eq`.  For `A` and `D` we have two equations in two unknowns:

```
p_0 = (A / B) - D
p_eq = (A / (B + pool_eq)) - D
```

Solve both equations for `A`, set the two expressions equal to each other, and solve for `D`:

```
A = B*(p_0 + D) = (p_eq+D)*(B+pool_eq)
-> B*p_0 + B*D = B*p_eq + B*D + p_eq*pool_eq + D*pool_eq
-> B*(p_0 - p_eq) - p_eq*pool_eq = D*pool_eq
-> (B / pool_eq)*(p_0 - p_eq) - p_eq = D
```
