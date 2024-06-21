---
title: 'PY: Account Reputation'
position: 20
description: "Would you like to know how to interpret account reputation to more human readable format, then this tutorial is for you."
layout: full
canonical_url: account_reputation.html
---
Full, runnable src of [Account Reputation](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/20_account_reputation) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-20_account_reputation.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/20_account_reputation)).

## Intro

Because blockchains don't natively store floating point, account reputation is stored on the blockchain as a long integer string which requires special function or formula to convert in more human readable format.  We can define a function that will convert this value, but beem already has the ability to interpret reputation automatically.

Also see:
* [get_account_reputations]({{ '/apidefinitions/#reputation_api.get_account_reputations' | relative_url }})

## Steps

1. [**App setup**](#app-setup) - Library install and import
1. [**Account list**](#account-list) - List of predefined accouns to select from
1. [**Print output**](#print-output) - Print results in output

#### 1. App setup <a name="app-setup"></a>

In this tutorial we will use the following packages: `pick` - helps us to select filter interactively. `beem` - hive library, interaction with Blockchain. `pprint` - print results in better format.

First we import all libraries and initialize Hive class

```python
import pprint
from pick import pick

# initialize Hive class
from beem import Hive
from beem.account import Account

hive = Hive()
```

#### 2. Account list <a name="account-list"></a>

Next we will show predefined account list to select and setup `pick` properly.

```python
title = 'Please choose account: '
options = ["hiveio","ecency","busy.org","demo"]

# get index and selected filter name
option, index = pick(options, title)

# option is printed as reference
pprint.pprint("Selected: " + option)
```

This will show us list of accounts to select in terminal/command prompt. And after selection we will fetch account details from Blockchain.

```python
user = Account(option, blockchain_instance=hive)
```

#### 3. Print output <a name="print-output"></a>

After we have fetched account details from Blockchain, all we have to do is to use the defined function to interpret account's `reputation` field into meaningful number.

```python
# print specified account's reputation
pprint.pprint(user.get_reputation())
```

Above function will internally cover all edge cases, for example, if account is new their raw reputation is `0` hence, default starting reputation will be `25`. If reputation negative that's also considered.

For reference, the following function will take a raw blockchain reputation value and convert it to the display value:

```python
import math

def rep_log10(rep):
  """Convert raw hived rep into a UI-ready value centered at 25."""
  
  def log10(string):
    leading_digits = int(string[0:4])
    log = math.log10(leading_digits) + 0.00000001
    num = len(string) - 1
    
    return num + (log - int(log))

  rep = str(rep)
  
  if rep == "0":
    return 25

sign = -1 if rep[0] == '-' else 1

if sign < 0:
  rep = rep[1:]

  out = log10(rep)
  out = max(out - 9, 0) * sign  # @ -9, $1 earned is approx magnitude 1
  out = (out * 9) + 25          # 9 points per magnitude. center at 25
  
  return round(out, 2)
```

You can use this to convert from the raw blockchain value.  This is now done internally by libraries like beem.

Final code:

```python
import pprint
from pick import pick

# initialize Hive class
from beem import Hive
from beem.account import Account

hive = Hive()

title = 'Please choose account: '
options = ["hiveio","ecency","busy.org","demo"]

# get index and selected filter name
option, index = pick(options, title)

# option is printed as reference
pprint.pprint("Selected: " + option)

user = Account(option, blockchain_instance=hive)

# print specified account's reputation
pprint.pprint(user.get_reputation())


```

---

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/20_account_reputation`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
