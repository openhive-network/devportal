---
title: 'PY: Get Follower And Following List'
position: 19
description: "Tutorial pulls a list of the followers or authors being followed from the blockchain then displays the result."
layout: full
canonical_url: get_follower_and_following_list.html
---
Full, runnable src of [Get Follower And Following List](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/19_get_follower_and_following_list) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-19_get_follower_and_following_list.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/19_get_follower_and_following_list)).

This tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch list of authors being followed or authors that a specified user is following.

## Intro

We are using the [`get_followers`]({{ '/apidefinitions/#follow_api.get_followers' | relative_url }}) and [`get_following`]({{ '/apidefinitions/#follow_api.get_following' | relative_url }}) functions that are built into the beem library. These functions allow us to query the Hive blockchain in order to retrieve either a list of authors that are being followed or a list of authors that are currently following a specified user. There are 4 parameters required to execute these functions:

1. _account_ - The specific user for which the follower(ing) list will be retrieved
1. _start follower(ing)_ - The starting letter(s) or name for the search query. This value can be set as an empty string in order to include all authors starting from "a"
1. _follow type_ - This value is set to `blog` and includes all users following or being followed by the `user`. This is currently the only valid parameter value for this function to execute correctly.
1. _limit_ - The maximum number of lines that can be returned by the query

Also see:
* [condenser_api.get_following]({{ '/apidefinitions/#condenser_api.get_following' | relative_url }})
* [condenser_api.get_followers]({{ '/apidefinitions/#condenser_api.get_followers' | relative_url }})
* [condenser_api.get_follow_count]({{ '/apidefinitions/#condenser_api.get_follow_count' | relative_url }})

## Steps

1. [**App setup**](#setup) - Library install and import
1. [**Input variables**](#input) - Collecting the required inputs via the UI
1. [**Get followers/following**](#query) Get the followers or users being followed
1. [**Print output**](#output) - Print results in output

#### 1. App setup <a name="setup"></a>

In this tutorial we use 2 packages, `pick` - helps us to select the query type interactively. `beem` - hive library, interaction with Blockchain.

First we import both libraries and initialize Hive class

```python
from pick import pick
# initialize Hive class
from beem import Hive
from beem.account import Account

hive = Hive()
```

#### 2. Input variables <a name="input"></a>

We assign two of the variables via a simple input from the UI.

```python
# capture username
account = input("Username: ")
account = Account(account, blockchain_instance=hive)

# capture list limit
limit = input("Max number of followers(ing) to display: ")
limit = int(limit)
```

Next we make a list of the two list options available to the user, `following` or `followers` and setup `pick`.

```python
# list type
title = 'Please choose the type of list: '
options = ['Follower', 'Following']

# get index and selected list name
option, index = pick(options, title)
print("List of " + option)
```

This will show the two options as a list to select in terminal/command prompt. From there we can determine which function to execute. We also display the choice on the UI for clarity.

#### 3. Get followers/following <a name="query"></a>

Now that we know which function we will be using, we can form the query to send to the blockchain. The selection is done with a simple `if` statement.

```python
# create empty list
follows = []

# parameters for get_followers function:
# start_follower, follow_type, limit
if option=="Follower" :
  follows = account.get_followers()[:limit]
else:
  follows = account.get_following()[:limit]
```

The output is captured.

#### 4. Print output <a name="output"></a>

Next, we will print the result.

```python
# check if follower(ing) list is empty
if len(follows) == 0:
  print("No " + option + " information available")
  exit()

print(*follows, sep='\n')
```

This is a fairly simple example of how to use these functions but we encourage you to play around with the parameters to gain further understanding of possible results.

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/19_get_follower_and_following_list`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
