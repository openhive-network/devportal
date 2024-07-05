---
title: titles.get_post_details
position: 5
description: descriptions.get_post_details
layout: full
canonical_url: get_post_details.html
---
Full, runnable src of [Get Post Details](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/05_get_post_details) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-05_get_post_details.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/05_get_post_details)).

We will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch list of posts filtered by a _filter_ and _tag_.

## Intro

Hive python library has built-in function to get details of post with author and permlink as an argument. Since we don't have predefined post or author/permlink. We will fetch post list from previous tutorial and give option to choose one option/post to get its details. `get_content` function fetches latest state of the post and delivers its details. Note that `get_discussions_by_created` filter is used for fetching 5 posts which by default contains details of each post, but for purpose of this tutorial we will showcase `get_content` function to fetch details.

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [database_api.find_comments]({{ '/apidefinitions/#database_api.find_comments' | relative_url }})
* [condenser_api.get_content]({{ '/apidefinitions/#condenser_api.get_content' | relative_url }})

## Steps

1. [**App setup**](#app-setup) - Library install and import
1. [**Post list**](#post-list) - List of posts to select from created filter 
1. [**Post details**](#post-details) - Get post details for selected post
1. [**Print output**](#print-output) - Print results in output

#### 1. App setup <a name="app-setup"></a>

In this tutorial we use 3 packages, `pick` - helps us to select filter interactively. `beem` - hive library, interaction with Blockchain. `pprint` - print results in better format.

First we import all three library and initialize Hive class

```python
import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.comment import Comment

h = Hive()
```

#### 2. Post list <a name="post-list"></a>

Next we will fetch and make list of posts and setup `pick` properly.

```python
q = Query(limit=2, tag="")
d = Discussions()

#post list for selected query
posts = d.get_discussions('created', q, limit=2)

title = 'Please choose post: '
options = []

#posts list
for post in posts:
  options.append(post["author"] + '/' + post["permlink"])

# get index and selected filter name
option, index = pick(options, title)
```

This will show us list of posts to select in terminal/command prompt. And after selection we will get index and post name to `index` and `option` variables.

#### 3. Post details <a name="post-details"></a>

Next we will fetch post details with `get_content`. By default `get_discussions_by_created` function already contains post details, but for this tutorial purpose we will ignore all other fields but only use `author` and `permlink` fields to fetch fresh post details.

```python
details = Comment(option)
```

#### 4. Print output <a name="print-output"></a>

Next, we will print result, details of selected post.

```python
# print post body for selected post
pprint.pprint('Depth: ' + str(details.depth))
pprint.pprint('Author: ' + details.author)
pprint.pprint('Category: ' + details.category)
pprint.pprint('Body: ' + details.body)
```

Also see: [beem.comment.Comment](https://beem.readthedocs.io/en/latest/beem.comment.html?highlight=comment#beem.comment.Comment)

The example of result returned from the service:

```
'Depth: 0'
'Author: hiveio'
'Category: hive'
('Body: '
 '\n'
 '\n'
.
.
.
```

From this result you have access to everything associated to the post including additional metadata which is a `JSON` string (e.g.; `json()["created"]`), `active_votes` (see: [beem.comment.Comment.get_vote_with_curation](https://beem.readthedocs.io/en/latest/beem.comment.html#beem.comment.Comment.get_vote_with_curation)) info, post title, body, etc. details that can be used in further development of applications with Python.

{% include structures/comment.html %}

Final code:

```python
import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.comment import Comment

h = Hive()

q = Query(limit=2, tag="")
d = Discussions()

#post list for selected query
posts = d.get_discussions('created', q, limit=2)

title = 'Please choose post: '
options = []

#posts list
for post in posts:
  options.append(post["author"] + '/' + post["permlink"])

# get index and selected filter name
option, index = pick(options, title)

details = Comment(option)

# print post body for selected post
# Also see: https://beem.readthedocs.io/en/latest/beem.comment.html#beem.comment.Comment
pprint.pprint('Depth: ' + str(details.depth))
pprint.pprint('Author: ' + details.author)
pprint.pprint('Category: ' + details.category)
pprint.pprint('Body: ' + details.body)

```

---

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/05_get_post_details`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
