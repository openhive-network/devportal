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
