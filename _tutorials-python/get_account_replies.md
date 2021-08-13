---
title: 'PY: Get Account Replies'
position: 8
description: "List of replies received by account to its content, post, comment."
layout: full
canonical_url: get_account_replies.html
---
Full, runnable src of [Get Account Replies](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/08_get_account_replies) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-08_get_account_replies.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/08_get_account_replies)).

Tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch a list of comments made on a specific accounts content.

## Intro

In Hive there are built-in functions in the library `beem` that we are going to use throughout all Python tutorials. For this one we are using the [`reply_history`]({{ '/apidefinitions/#tags_api.get_content_replies' | relative_url }}) function.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_content_replies]({{ '/apidefinitions/#tags_api.get_content_replies' | relative_url }})
* [condenser_api.get_content_replies]({{ '/apidefinitions/#condenser_api.get_content_replies' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) - Library install and import
1.  [**Post list**](#post-list) - List of filters to select from
1.  [**Comment details**](#comment-details) - Form a query
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
from beem.account import Account

h = Hive()
```

#### 2. Post list <a name="post-list"></a>

Next we will fetch and make a list of posts and setup `pick` properly.

```python
q = Query(limit=2, tag="")
d = Discussions()

#post list for selected query
#we are merely using this to display the most recent posters
#the 'author' can easily be changed to any value within the 'reply_history' function

posts = d.get_discussions('created', q, limit=2)

title = 'Please choose author: '
options = []
#posts list
for post in posts:
  options.append(post["author"])

# get index and selected filter name
option, index = pick(options, title)

# option is printed as reference
pprint.pprint("Selected: " + option)
```

This will show us list of posts to select in terminal/command prompt. And after selection we will get index and post name to `index` and `option` variables. We will also print the selection on screen for easy reference.

#### 3. Comment details <a name="comment-details"></a>

Next we will allocate variables to make the function easier to use as well as provide a limit for the number of replies that we want to print. To retreive the replies we only need the `author` object. This is then used in the `reply_history` function present in the beem library.

```python
# in this tutorial we are showing usage of reply_history of post where the author is known

# allocate variables
_author = Account(option)
_limit = 1

# get replies for specific author
replies = _author.reply_history(limit=_limit)
```

#### 4. Print output <a name="print-output"></a>

Next, we will print the details obtained from the function by iterating the array.

```python
# print specified number of comments

for reply in replies:
  pprint.pprint(reply.body)
```

---

#### Try it

Click the play button below:

<iframe height="400px" width="100%" src="https://replit.com/@inertia186/py08getaccountreplies?embed=1&output=1" scrolling="no" frameborder="no" allowtransparency="true" allowfullscreen="true" sandbox="allow-forms allow-pointer-lock allow-popups allow-same-origin allow-scripts allow-modals"></iframe>

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/08_get_account_replies`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
