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

