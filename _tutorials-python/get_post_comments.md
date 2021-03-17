---
title: 'PY: Get Post Comments'
position: 7
description: "Fetch comments made on each content or post using Python."
layout: full
canonical_url: get_post_comments.html
---
Full, runnable src of [Get Post Comments](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/07_get_post_comments) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-07_get_post_comments.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/07_get_post_comments)).

This tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch list of posts and get replies info on selected post.

## Intro

Hive python library has built-in function to get active voters information if post with author and permlink as an argument. Since we don't have predefined post or author/permlink. We will fetch post list from previous tutorial and give option to choose one post to get its active voters. [`get_content_replies`]({{ '/apidefinitions/#tags_api.get_content_replies' | relative_url }}) function fetches list of replies on content. Note that [`get_discussions_by_hot`]({{ '/apidefinitions/#tags_api.get_discussions_by_hot' | relative_url }}) filter is used for fetching 5 posts and after selection of post tutorial uses `author` and `permlink` of the post to fetch replies. 

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})
* [database_api.find_comments]({{ '/apidefinitions/#database_api.find_comments' | relative_url }})
* [condenser_api.get_content]({{ '/apidefinitions/#condenser_api.get_content' | relative_url }})
* [tags_api.get_content_replies]({{ '/apidefinitions/#tags_api.get_content_replies' | relative_url }})
* [condenser_api.get_content_replies]({{ '/apidefinitions/#condenser_api.get_content_replies' | relative_url }})

## Steps

1.  [**App setup**](#app-setup) - Library install and import
1.  [**Post list**](#post-list) - List of posts to select from created filter 
1.  [**Replies list**](#replies-list) - Get replies list for selected post
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
from beem.comment import Comment

h = Hive()
```

#### 2. Post list <a name="post-list"></a>

Next we will fetch and make list of posts and setup `pick` properly.

```python
q = Query(limit=2, tag="")
d = Discussions()

#post list for selected query
posts = d.get_discussions('hot', q, limit=2)

title = 'Please choose post: '
options = []

#posts list
for post in posts:
	options.append(post["author"]+'/'+post["permlink"])

# get index and selected filter name
option, index = pick(options, title)
```

This will show us list of posts to select in terminal/command prompt. And after selection we will get index and post name to `index` and `option` variables.

#### 3. Replies list <a name="replies-list"></a>

Next we will replies on selected post with `get_content_replies`. 

```python
details = Comment(option)

# get replies for given post
replies = details.get_all_replies()
```

#### 4. Print output <a name="print-output"></a>

Next, we will print result, replies on selected post, selected post details and number of replies.

```python
# print post details for selected post
pprint.pprint(replies)
pprint.pprint("Selected: " + option)
pprint.pprint("Number of replies: " + str(len(replies)))
```

The example of results returned from the service:

```
[<Comment @abh12345/re-meesterboom-qp3p8c>,
 <Comment @monica-ene/re-meesterboom-qp3qnk>,
 <Comment @tarazkp/qp3qse>,
 <Comment @slobberchops/re-meesterboom-qp3s1w>,
 <Comment @meesterboom/qp3pal>,
 <Comment @abh12345/re-meesterboom-qp3pj9>,
 <Comment @meesterboom/qp3pp5>,
 <Comment @abh12345/re-meesterboom-qp3qku>,
 <Comment @meesterboom/qp3rhn>,
 <Comment @meesterboom/qp3rkz>,
 <Comment @meesterboom/qp3rax>]
'Selected: meesterboom/to-try-again'
'Number of replies: 11'
```

From this result you have access to everything associated to the replies including content of reply, author, timestamp, etc., so that you can be use in further development of applications with Python.

That's it!

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/07_get_post_comments`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
