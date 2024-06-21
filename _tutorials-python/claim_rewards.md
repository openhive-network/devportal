---
title: 'PY: Claim Rewards'
position: 23
description: "How to claim rewards using Python."
layout: full
canonical_url: claim_rewards.html
---
Full, runnable src of [Claim Rewards](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/23_claim_rewards) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-23_claim_rewards.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/23_claim_rewards)).

In this tutorial we show you how to check the HIVE, HBD and HIVE POWER (VESTS) rewards balances of an account on the **Hive** blockchain, and how to claim either a portion or all of the rewards for an account using the functionality found within the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`claim_reward_balance`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.claim_reward_balance) method found within the account instance.  Before we transmit a claim, we use the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) module to check the current rewards balance of the account to see what is available to claim.  The `claim` method has 3 parameters:

1.  _reward hive_ - The amount of HIVE to claim
1.  _reward hbd_ - The amount of HBD to claim
1.  _reward vests_ - The amount of VESTS (HIVE POWER) to claim

Also see:
* [claim_reward_balance_operation]({{ '/apidefinitions/#broadcast_ops_claim_reward_balance' | relative_url }})

## Steps

1.  [**App setup**](#setup) - Library install and import. Connection to testnet
1.  [**User information and Hive node**](#userinfo) - Input user information and connection to Hive node
1.  [**Check reward balance**](#balance) - Check current rewards balances of user account
1.  [**Claim**](#broadcast) - Input amount of rewards to claim
1.  [**Balance update**](#update) - Check new rewards balances after completed claim

#### 1. App setup <a name="setup"></a>

In this tutorial we use 2 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively

We import the libraries and connect to the `testnet`.

```python
import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
```

Because this tutorial alters the blockchain we connect to a testnet so we don't create spam on the production server.

#### 2. User information and Hive node <a name="userinfo"></a>

We require the `private posting key` of the user in order for the claim to be broadcasted to the blockchain.  This is why we are using a testnet.  The values are supplied via the terminal/console before we initialize the beem class.

```python
# capture user information
account = input('Enter username: ')
wif_posting_key = getpass.getpass('Enter private POSTING key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node
client = Hive(node_url, keys=[wif_posting_key])
```

#### 3. Check reward balance <a name="balance"></a>

We send a query to the blockchain using the [`Account`](https://beem.readthedocs.io/en/latest/beem.account.html) module to check if the username exists on the blockchain.  We also use this to get a clear picture of the available rewards that can be claimed and display this on the console/terminal.

```python
# get account reward balances
account = Account(account, blockchain_instance=client)

reward_hive = account['reward_hive_balance']
reward_hbd = account['reward_hbd_balance']
reward_vests = account['reward_vesting_balance']

print('Reward Balances:' + '\n' +
  '\t' + str(reward_hive) + '\n' +
  '\t' + str(reward_hbd) + '\n' +
  '\t' + str(reward_vests)
)

if reward_hive.amount + reward_hbd.amount + reward_vests.amount == 0:
  print('\n' + 'No rewards to claim')
  exit()

input('\n' + 'Press enter to continue to claim selection')
```

#### 4. Claim<a name="broadcast"></a>

An option is provided to either claim all rewards at once or to specify specific amounts to be claimed for each individual reward balance.

```python
# choice of claim
title = 'Please choose claim type: '
options = ['ALL', 'SELECTED', 'CANCEL']
# get index and selected claim type
option, index = pick(options, title)

if option == 'CANCEL':
  print('\n' + 'Operation cancelled')
  exit()
```

When the option to claim all rewards is selected, the claim parameters are automatically assigned from the `Account` query.  We also check that there are in fact outstanding rewards balances before we broadcast the claim.

```python
# commit claim based on selection
if option == 'ALL':
  account.claim_reward_balance
  print('\n' + 'All reward balances have been claimed. New reward balances are:' + '\n')
else:
  claim_hive = float(input('\n' + 'Please enter the amount of HIVE to claim: ') or '0')
  claim_hbd = float(input('Please enter the amount of HBD to claim: ') or '0')
  claim_vests = float(input('Please enter the amount of VESTS to claim: ') or '0')

  if claim_hive + claim_hbd + claim_vests == 0:
    print('\n' + 'Zero values entered, no claim to submit')
    exit()

  if claim_hive > reward_hive or claim_hbd > reward_hbd or claim_vests > reward_vests:
    print('\n' + 'Requested claim value higher than available rewards')
    exit()

  account.claim_reward_balance(reward_hive=claim_hive, reward_hbd=claim_hbd, reward_vests=claim_vests)
  print('\n' + 'Claim has been processed. New reward balances are:' + '\n')
```

When doing only a selected claim of available rewards, the values are captured in the console/terminal.  The inputs cannot be negative, must be less than or equal to the available reward and at least ONE of the inputs needs to be greater than zero for the claim to be able to transmit.  The result of the selected option is printed on the UI.

#### 5. Balance update <a name="update"></a>

As a final check we run the account query again to get updated values for the available rewards balances.

```python
# get updated account reward balances
input("Press enter for new account balances")

account.refresh()

reward_hive = account['reward_hive_balance']
reward_hbd = account['reward_hbd_balance']
reward_vests = account['reward_vesting_balance']

print('\t' + str(reward_hive) + '\n' +
  '\t' + str(reward_hbd) + '\n' +
  '\t' + str(reward_vests)
)
```

Final code:

```python
import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account

# capture user information
account = input('Enter username: ')
wif_posting_key = getpass.getpass('Enter private POSTING key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node
client = Hive(node_url, keys=[wif_posting_key])

# get account reward balances
account = Account(account, blockchain_instance=client)

reward_hive = account['reward_hive_balance']
reward_hbd = account['reward_hbd_balance']
reward_vests = account['reward_vesting_balance']

print('Reward Balances:' + '\n' + 
  '\t' + str(reward_hive) + '\n' + 
  '\t' + str(reward_hbd) + '\n' + 
  '\t' + str(reward_vests)
)

if reward_hive.amount + reward_hbd.amount + reward_vests.amount == 0:
  print('\n' + 'No rewards to claim')
  exit()

input('\n' + 'Press enter to continue to claim selection')

# choice of claim
title = 'Please choose claim type: '
options = ['ALL', 'SELECTED', 'CANCEL']
# get index and selected claim type
option, index = pick(options, title)

if option == 'CANCEL':
  print('\n' + 'Operation cancelled')
  exit()
  
# commit claim based on selection
if option == 'ALL':
  account.claim_reward_balance
  print('\n' + 'All reward balances have been claimed. New reward balances are:' + '\n')
else:
  claim_hive = float(input('\n' + 'Please enter the amount of HIVE to claim: ') or '0')
  claim_hbd = float(input('Please enter the amount of HBD to claim: ') or '0')
  claim_vests = float(input('Please enter the amount of VESTS to claim: ') or '0')

  if claim_hive + claim_hbd + claim_vests == 0:
    print('\n' + 'Zero values entered, no claim to submit')
    exit()
  
  if claim_hive > reward_hive or claim_hbd > reward_hbd or claim_vests > reward_vests:
    print('\n' + 'Requested claim value higher than available rewards')
    exit()
  
  account.claim_reward_balance(reward_hive=claim_hive, reward_hbd=claim_hbd, reward_vests=claim_vests)
  print('\n' + 'Claim has been processed. New reward balances are:' + '\n')

# get updated account reward balances
input("Press enter for new account balances")

account.refresh()

reward_hive = account['reward_hive_balance']
reward_hbd = account['reward_hbd_balance']
reward_vests = account['reward_vesting_balance']

print('\t' + str(reward_hive) + '\n' + 
  '\t' + str(reward_hbd) + '\n' + 
  '\t' + str(reward_vests)
)

```

---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/23_claim_rewards`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
