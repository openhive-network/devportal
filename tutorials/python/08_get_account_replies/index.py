import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.account import Account

h = Hive()
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

# in this tutorial we are showing usage of reply_history of post where the author is known

# allocate variables
_author = Account(option)
_limit = 1

# get replies for specific author
replies = _author.reply_history(limit=_limit)

# print specified number of comments

for reply in replies:
  pprint.pprint(reply.body)

