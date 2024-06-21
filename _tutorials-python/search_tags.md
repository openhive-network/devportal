---
title: titles.search_tags
position: 16
description: "How to pull a list of the trending tags from the blockchain using Python."
layout: full
canonical_url: search_tags.html
---
Full, runnable src of [Search Tags](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python/16_search_tags) can be downloaded as part of: [tutorials/python](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/python) (or download just this tutorial: [devportal-master-tutorials-python-16_search_tags.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/python/16_search_tags)).

Please refer to [15_search_accounts](search_accounts.html) which includes a tutorial for `trending tags` as well.

Final code:

```python
from beem import Hive
from pick import pick
from beem.blockchain import Blockchain
from beem.discussions import Query, Trending_tags

# initialize Hive class

h = Hive()

# choose list type
title = 'Please select type of list:'
options = ['Active Account names', 'Trending tags']

# get index and selected list name
option, index = pick(options, title)

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

---
