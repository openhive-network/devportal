---
title: titles.witness_listing_and_voting
position: 22
description: "How to vote for or remove a vote for a witness user using Python."
layout: full
canonical_url: witness_listing_and_voting.html
---
Full, runnable src of [Witness Listing And Voting](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/22_witness_listing_and_voting) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-22_witness_listing_and_voting.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/22_witness_listing_and_voting)).

In this tutorial we show you how to create a list of current witness votes from the **Hive** blockchain and then vote or unvote for a witness using the methods found within the [beem](https://github.com/holgern/beem) library.

## Intro

The beem library has a built-in function to transmit transactions to the blockchain.  We are using the [`approvewitness`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.approvewitness) and [`disapprovewitness`](https://beem.readthedocs.io/en/latest/beem.account.html#beem.account.Account.disapprovewitness) method found within the account instance.  We also use the [`WitnessesVotedByAccount`](https://beem.readthedocs.io/en/latest/beem.witness.html#beem.witness.WitnessesVotedByAccount) module to query the blockchain for a list of voted witnesses.

Also see:
* [condenser_api.get_witnesses_by_vote]({{ '/apidefinitions/#condenser_api.get_witnesses_by_vote' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import. Connection to testnet
1. [**User information**](#userinfo) - Input user information
1. [**Voted witness list**](#list) - Create a list of witnesse already voted for
1. [**Vote / Unvote**](#commit) - Input witness name and commite vote/unvote to blockchain

#### 1. App setup <a name="setup"></a>

In this tutorial we use 3 packages:

- `beem` - hive library and interaction with Blockchain
- `pick` - helps select the query type interactively
- `pprint` - print results in better format

```python
import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.witness import Witness, WitnessesVotedByAccount
```

Because this tutorial alters the blockchain we connect to a testnet so we don't create spam on the production server.

#### 2. User information<a name="userinfo"></a>

We require the `private active key` of the user in order for the transaction to be committed to the blockchain.  This is why we are using a testnet.  We also check if the user name provided is active on the chain.  There are some demo accounts available but we encourage you to create your own accounts on this testnet.

```python
# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Active Key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)
```

#### 3. Voted witness list <a name="list"></a>

We provide the user with a list of witnesses that have already been voted for by their account.  From this the user will know which witnesses can be removed, and which can be added to their set of approved witnesses.  We generate this list using the `Account` module and display it on the UI.

```python
# print list of currently voted for witnesses
print('\n' + 'WITNESSES CURRENTLY VOTED FOR')
vote_list = WitnessesVotedByAccount(account.name, blockchain_instance=client)
for witness in vote_list:
  pprint.pprint(witness.account.name)

input('Press enter to continue')
```

#### 4. Vote / Unvote <a name="commit"></a>

The user is given the option to `VOTE`, `UNVOTE` or `CANCEL` the process.  Depending on the choice the relevant function is executed.  Both the `VOTE` and `UNVOTE` methods use the same input - the witness being added or removed.  The different method executions are shown below.

```python
# choice of action
title = ('Please choose action')
options = ['VOTE', 'UNVOTE', 'CANCEL']
# get index and selected permission choice
option, index = pick(options, title)

if (option == 'CANCEL') :
    print('\n' + 'operation cancelled')
    exit()

if (option == 'VOTE') :
    # vote process
    witness_vote = input('Please enter the witness name you wish to vote for: ')
    witness = Witness(witness_vote, blockchain_instance=client)
    if witness_vote in vote_list :
        print('\n' + witness_vote + ' cannot be voted for more than once')
        exit()
    account.approvewitness(witness_vote)
    print('\n' + witness_vote + ' has been successfully voted for')
else :
    # unvote process
    witness_unvote = input('Please enter the witness name you wish to remove the vote from: ')
    if witness_unvote not in vote_list :
        print('\n' + witness_unvote + ' is not in your voted for list')
        exit()
    account.disapprovewitness(witness_unvote)
    print('\n' + witness_unvote + ' has been removed from your voted for list')
```

A confirmation of the transaction to the blockchain is displayed on the UI.

Final code:

```python
import pprint
from pick import pick
import getpass
from beem import Hive
from beem.account import Account
from beem.witness import Witness, WitnessesVotedByAccount

# capture user information
account = input('Enter username: ')
wif_active_key = getpass.getpass('Active Key: ')

# node_url = 'https://testnet.openhive.network' # Public Testnet
node_url = 'http://127.0.0.1:8090' # Local Testnet

# connect node and private active key
client = Hive(node_url, keys=[wif_active_key])

# check valid user
account = Account(account, blockchain_instance=client)

# print list of currently voted for witnesses
print('\n' + 'WITNESSES CURRENTLY VOTED FOR')
vote_list = WitnessesVotedByAccount(account.name, blockchain_instance=client)
for witness in vote_list:
  pprint.pprint(witness.account.name)

input('Press enter to continue')

# choice of action
title = ('Please choose action')
options = ['VOTE', 'UNVOTE', 'CANCEL']
# get index and selected permission choice
option, index = pick(options, title)

if (option == 'CANCEL') :
    print('\n' + 'operation cancelled')
    exit()

if (option == 'VOTE') :
    # vote process
    witness_vote = input('Please enter the witness name you wish to vote for: ')
    witness = Witness(witness_vote, blockchain_instance=client)
    if witness_vote in vote_list :
        print('\n' + witness_vote + ' cannot be voted for more than once')
        exit()
    account.approvewitness(witness_vote)
    print('\n' + witness_vote + ' has been successfully voted for')
else :
    # unvote process
    witness_unvote = input('Please enter the witness name you wish to remove the vote from: ')
    if witness_unvote not in vote_list :
        print('\n' + witness_unvote + ' is not in your voted for list')
        exit()
    account.disapprovewitness(witness_unvote)
    print('\n' + witness_unvote + ' has been removed from your voted for list')

```


---

### To Run the tutorial

{% include local-testnet.html %}

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/22_witness_listing_and_voting`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see a prompt for input in terminal screen.
