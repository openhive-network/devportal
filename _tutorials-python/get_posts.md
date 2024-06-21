---
title: 'PY: Get Posts'
position: 4
description: "Tutorial pulls a list of the posts from the blockchain with selected filter and tag then displays output."
layout: full
canonical_url: get_posts.html
---
Full, runnable src of [Get Posts](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/04_get_posts) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-04_get_posts.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/04_get_posts)).

This tutorial will explain and show you how to access the **Hive** blockchain using the [beem](https://github.com/holgern/beem) library to fetch list of posts filtered by a _filter_ and _tag_.

## Intro

In Hive there are built-in filters `trending`, `hot`, `created`, `active`, `promoted` etc. which helps us to get list of posts. `get_discussions_by_trending(query)`, `get_discussions_by_hot(query)`, `get_discussions_by_created(query)`, etc. functions are built-in into `beem` that we are going to use throughout all Python tutorials. 

Also see:
* [get discussions]({{ '/search/?q=get discussions' | relative_url }})

## Steps

1. [**App setup**](#app-setup) - Library install and import
1. [**Filters list**](#filters-list) - List of filters to select from
1. [**Query details**](#query-details) - Form a query
1. [**Print output**](#print-output) - Print results in output

#### 1. App setup <a name="app-setup"></a>

In this tutorial we use 3 packages, `pick` - helps us to select filter interactively. `beem` - hive library, interaction with Blockchain. `pprint` - print results in better format.

First we import all three library and initialize Hive class

```python
import pprint
from pick import pick
# initialize Hive class
from beem import Hive

h = Hive()
```

#### 2. Filters list <a name="filters-list"></a>

Next we will make list of filters and setup `pick` properly.

```python
title = 'Please choose filter: '
#filters list
options = ['trending', 'hot', 'active', 'created', 'promoted']
# get index and selected filter name
option, index = pick(options, title)
```

This will show us list of filters to select in terminal/command prompt. And after selection we will get index and filter name to `index` and `option` variables.

#### 3. Query details <a name="query-details"></a>

Next we will form a query. In Hive, 

*   You can add a tag to filter the posts that you receive from the server
*   You can also limit the amount of results you would like to receive from the query

```python
q = Query(limit=2, tag="")
.
.
.
posts = {
  0: d.get_discussions('trending', q, limit=2),
  1: d.get_discussions('hot', q, limit=2),
  2: d.get_discussions('active', q, limit=2),
  3: d.get_discussions('created', q, limit=2),
  4: d.get_discussions('promoted', q, limit=2)
}
```

Above code shows example of query and simple list of function that will fetch post list with user selected filter.

#### 4. Print output <a name="print-output"></a>

Next, we will print result, post list and selected filter name.

```python
  # print post list for selected filter
  pprint.pprint(posts[index])
  pprint.pprint("Selected: "+option)
```

The example of result returned from the service as objects:

```
1. <Comment @lukewearechange/unbelievable-how-are-they-getting-away-with-this>
2. <Comment @jennyzer/iniciativa-juegos-de-mi-infancia-or-or-games-of-my-childhood-initiative>
'Selected: hot'
```

From this result you have access to everything associated to the posts including additional metadata which is a `JSON` string (that must be decoded to use), `active_votes` info, post title, body, etc. details that can be used in further development of application with Python.

Final code:

```python
import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions

h = Hive()

title = 'Please choose filter: '
#filters list
options = ['trending', 'hot', 'active', 'created', 'promoted']
# get index and selected filter name
option, index = pick(options, title)

q = Query(limit=2, tag="")
d = Discussions()
count = 0

#post list for selected query
posts = {
  0: d.get_discussions('trending', q, limit=2),
  1: d.get_discussions('hot', q, limit=2),
  2: d.get_discussions('active', q, limit=2),
  3: d.get_discussions('created', q, limit=2),
  4: d.get_discussions('promoted', q, limit=2)
}

# print post list for selected filter
for p in posts[index]:
  print(("%d. " % (count + 1)) + str(p))
  count += 1

pprint.pprint("Selected: " + option)

```

---

### To Run the tutorial

1. [review dev requirements](getting_started.html)
1. `git clone https://gitlab.syncad.com/hive/devportal.git`
1. `cd devportal/tutorials/python/04_get_posts`
1. `pip install -r requirements.txt`
1. `python index.py`
1. After a few moments, you should see output in terminal/command prompt screen.
