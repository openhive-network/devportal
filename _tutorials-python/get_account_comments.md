---
title: 'PY: Get Account Comments'
position: 9
description: "Fetch list of comments made by account on posts or comments."
layout: full
canonical_url: get_account_comments.html
---
Full, runnable src of [Get Account Comments](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/09_get_account_comments) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-09_get_account_comments.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/09_get_account_comments)).

In this tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch list of posts to randomize account list and get replies of selected account.

## Intro

The beem library has built-in function to get comments list made by specific account. Since we don't have predefined account list, we will fetch newly created posts and show their authors for selection and give option to choose one account to get its comments. The [`get_discussions_by_comments`](https://beem.readthedocs.io/en/latest/beem.discussions.html#beem.discussions.Discussions_by_comments) function fetches list of comments made by account. Note that [`get_discussions_by_created`](https://beem.readthedocs.io/en/latest/beem.discussions.html#beem.discussions.Discussions_by_created) filter is used for fetching 5 posts and after selection of its author tutorial uses [`author`](https://beem.readthedocs.io/en/latest/beem.comment.html#beem.comment.Comment.author) of the post to fetch that account's comments. 

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [tags_api.get_discussions_by_comments]({{ '/apidefinitions/#tags_api.get_discussions_by_comments' | relative_url }})
* [condenser_api.get_discussions_by_comments]({{ '/apidefinitions/#condenser_api.get_discussions_by_comments' | relative_url }})
* [tags_api.get_discussions_by_created]({{ '/apidefinitions/#tags_api.get_discussions_by_created' | relative_url }})
* [condenser_api.get_discussions_by_created]({{ '/apidefinitions/#condenser_api.get_discussions_by_created' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) - Library install and import
1.  [**Post list**](#post-list) - List of posts to select from created filter 
1.  [**Comments list**](#comments-list) - Get comments list made by selected account
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

h = Hive()
```

#### 2. Post list <a name="post-list"></a>

Next we will fetch and make list of accounts and setup `pick` properly.

```python
q = Query(limit=2, tag="")
d = Discussions()

#author list from created post list to randomize account list
posts = d.get_discussions('created', q, limit=2)

title = 'Please choose account: '
options = []
#accounts list
for post in posts:
  options.append(post["author"])

# get index and selected account name
option, index = pick(options, title)
```

This will show us list of accounts to select in terminal/command prompt. And after selection we will get account name as a `option` variable.

#### 3. Comments list <a name="comments-list"></a>

Next we will form another query to get comments list of account

```python
# 5 comments from selected author
q = Query(limit=5, start_author=option)

# get comments of selected account
comments = d.get_discussions('comments', q, limit=5)
```

Note that `start_author` variable in query should be account name so that `get_discussions_by_comments` can provide us current information.

#### 4. Print output <a name="print-output"></a>

Next, we will print result, comments of selected account and details of each comment.

```python
# print comment details for selected account
for comment in comments:
  pprint.pprint(comment)
pprint.pprint("Selected: " + option)
```

The example of result returned from the service is a `JSON` object with the following properties:

```
<Comment @happyme/qp4kl6>
<Comment @happyme/qp4fiv>
<Comment @happyme/qp4f2s>
<Comment @happyme/qp461s>
<Comment @happyme/qp40tt>
'Selected: happyme'
```

From this result you have access to everything associated to the [comments](https://beem.readthedocs.io/en/latest/beem.comment.html#beem.comment.Comment) of account including content of comment, timestamp, active_votes, etc., so that you can use in further development of your applications with Python.

Final code:

```python
import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions

h = Hive()
q = Query(limit=2, tag="")
d = Discussions()

#author list from created post list to randomize account list
posts = d.get_discussions('created', q, limit=2)

title = 'Please choose account: '
options = []
#accounts list
for post in posts:
  options.append(post["author"])

# get index and selected account name
option, index = pick(options, title)

# 5 comments from selected author
q = Query(limit=5, start_author=option) 

# get comments of selected account
comments = d.get_discussions('comments', q, limit=5)

# print comment details for selected account
for comment in comments:
  pprint.pprint(comment)
pprint.pprint("Selected: " + option)


```

---

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/09_get_account_comments`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
