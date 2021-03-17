---
title: 'PY: Search Accounts'
position: 15
description: "How to pull a list of the active user accounts or trending tags from the blockchain using Python."
layout: full
canonical_url: search_accounts.html
---
Full, runnable src of [Search Accounts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/15_search_accounts) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-15_search_accounts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/15_search_accounts)).

This tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch a list of active authors or trending tags, starting the search from a specified value, and displaying the results on the console.

## Intro

We are using the `get_all_accounts` and `Trending_tags` functions that are built-in in the beem library.  These functions allow us to query the Hive blockchain in order to retrieve either a list of active authors or a list of trending tags.  The option is available to either get a complete list starting from the first value on the blockchain or starting the list from any other closest match string value as provided by the user.  Both of these functions have only two parameters:

1.  _account/aftertag_ - The string value from where to start the search. If this value is left empty the search will start from the first value available
1.  _limit_ - The maximum number of names/tags that the query retrieves

## Steps

1. [**App setup**](#setup) - Library import and Hive class initialization
1. [**List selection**](#list) - Selection of the type of list
1. [**Get and display account names**](#accounts) - Get a list of account names from the blockchain
1. [**Get and display trending tags**](#tags) - Get a list of trending tags from the blockchain

#### 1. App setup<a name="setup"></a>

In this tutorial we use 2 packages, `pick` - helps us to select the query type interactively. `beem` - hive library for interaction with the Blockchain.

First we import both libraries and initialize Hive class:

```python
from beem import Hive
from pick import pick
from beem.blockchain import Blockchain
from beem.discussions import Query, Trending_tags

# initialize Hive class

h = Hive()
```

#### 2. List selection<a name="list"></a>

The user is given the option of which list to create, `active accounts` or `trending tags`. We create this option list and setup `pick`.

```python
# choose list type
title = 'Please select type of list:'
options = ['Active Account names', 'Trending tags']

# get index and selected list name
option, index = pick(options, title)
```

This will show the two options as a list to select in terminal/command prompt. From there we can determine which function to execute.

#### 3. Get and display account names<a name="accounts"></a>

Once the user selects the required list, a simple `if` statement is used to execute the relevant function. Based on the selection we then run the query. The parameters for the `get_all_accounts` function is captured in the `if` statement via the terminal/console.

```python
if option == 'Active Account names':
  context = Blockchain(blockchain_instance=h)
  # capture starting account
  account = input("Enter account name to start search from: ")
  # input list limit
  limit = input("Enter max number of accounts to display: ")
  print('\n' + "List of " + option + '\n')
  accounts = []
  for a in context.get_all_accounts(start=account, limit=int(limit)):
    print(a)
```

Once the list is generated it is displayed on the UI with line separators along with a heading of what list it is.

#### 4. Get and display trending tags<a name="tags"></a>

The query for a list of trending tags is executed in the second part of the `if` statement. Again, the parameters for the query is captured via the terminal/console.

```python
else:
  # capture starting tag
  aftertag = input("Enter tag name to start search from: ")
  # capture list limit
  limit = input("Enter max number of tags to display: ")
  print('\n' + "List of " + option + '\n')
  q = Query(limit=int(limit), start_tag=aftertag)
  for t in Trending_tags(q):
    print(t['name'])
```

The query returns an array of objects. We use the `for` loop to build a list of only the tag `names` from that array and then display the list on the UI with line separators. This creates an easy to read list of tags.

That's it!.

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/15_search_accounts`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
