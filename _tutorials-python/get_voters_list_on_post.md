---
title: 'PY: Get Voters List On Post'
position: 6
description: "Voters list and detail of each vote on selected content."
layout: full
canonical_url: get_voters_list_on_post.html
---
Full, runnable src of [Get Voters List On Post](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/06_get_voters_list_on_post) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-06_get_voters_list_on_post.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/06_get_voters_list_on_post)).

Tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch list of posts and get voters info on selected post.

## Intro

The beem library has built-in functionality to get active voters information if post with author and permlink as an argument. Since we don't have predefined post or author/permlink, we will fetch post list from previous tutorial and give option to choose one post to get its active voters. The [`get_active_votes`](https://beem.readthedocs.io/en/latest/apidefinitions.html#get-active-votes) method fetches list of active voters on content. Note that [`get_discussions_by_hot`](https://beem.readthedocs.io/en/latest/apidefinitions.html#get-discussions-by-hot) filter is used for fetching 5 posts which by default contains `active_votes` of each post, but for purpose of this tutorial we will use `get_active_votes` method to fetch voters info.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_active_votes]({{ '/apidefinitions/#tags_api.get_active_votes' | relative_url }})
* [condenser_api.get_active_votes]({{ '/apidefinitions/#condenser_api.get_active_votes' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) - Library install and import
1.  [**Post list**](#post-list) - List of posts to select from created filter 
1.  [**Voters list**](#voters-list) - Get voters list for selected post
1.  [**Print output**](#print-output) - Print results in output

#### 1. App setup <a name="app-setup"></a>

In this tutorial we use 3 packages, `pick` - helps us to select filter interactively. `beem` - hive library, interaction with Blockchain. `pprint` - print results in better format.

First we import all three library and initialize Hive class

```python
import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.vote import ActiveVotes

h = Hive()
```

#### 2. Post list <a name="post-list"></a>

Next we will fetch and make list of posts and setup `pick` properly.

```python
q = {"limit": 5, "tag": "", "before_date": None}
d = Discussions()

#post list for selected query
posts = d.get_discussions('hot', q, limit=5)

title = 'Please choose post: '
options = []

#posts list
for post in posts:
	options.append(post["author"] + '/' + post["permlink"])

# get index and selected filter name
option, index = pick(options, title)
```

This will show us list of posts to select in terminal/command prompt. And after selection we will get index and post name to `index` and `option` variables.

#### 3. Voters list <a name="voters-list"></a>

Next we will fetch active votes on selected post with `get_active_votes`. By default `get_discussions_by_hot` method already contains `active_votes` list, but for this tutorial purpose we will ignore all other fields but only use `author` and `permlink` fields to fetch voters list.

```python
voters = ActiveVotes(option)
```

#### 4. Print output <a name="print-output"></a>

Next, we will print result, details of selected post.

```python
# print voters list for selected post
voters.printAsTable()
pprint.pprint("Selected: " + option)
```

The example of result returned from the service is a table with the following output:

```
+------------------+------------+---------+-------------+----------------+---------+---------+
| Voter            | Votee      | SBD/HBD | Time        | Rshares        | Percent | Weight  |
+------------------+------------+---------+-------------+----------------+---------+---------+
| themonkeyzuelans | fermionico | 0.01 $  | 0 days 0:46 | 28018792638    | 10000   | 6694    |
| heidimarie       | fermionico | 0.03 $  | 0 days 0:45 | 61161496034    | 1500    | 16568   |
| netaterra        | fermionico | 0.06 $  | 0 days 0:45 | 146151648404   | 600     | 39343   |
| therealyme       | fermionico | 0.08 $  | 0 days 0:45 | 199995975315   | 600     | 50451   |
| ctime            | fermionico | 0.11 $  | 0 days 0:45 | 266462356454   | 400     | 70849   |
+------------------+------------+---------+-------------+----------------+---------+---------+
'Selected: fermionico/ztqkjnuv'
```

From this result you have access to everything associated to the voter including reputation of voter, timestamp, voter's account name, percent and weight of vote, rshares reward shares values that you can be use in further development of applications with Python.

---

#### Try it

Click the play button below:

<iframe height="400px" width="100%" src="https://replit.com/@inertia186/py06getvoterslistonpost?embed=1&output=1" scrolling="no" frameborder="no" allowtransparency="true" allowfullscreen="true" sandbox="allow-forms allow-pointer-lock allow-popups allow-same-origin allow-scripts allow-modals"></iframe>

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/06_get_voters_list`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
