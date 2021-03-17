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
posts = d.get_discussions('hot', q, limit=2)

title = 'Please choose post: '
options = []

#posts list
for post in posts:
	options.append(post["author"]+'/'+post["permlink"])

# get index and selected filter name
option, index = pick(options, title)

details = Comment(option)

# get replies for given post
replies = details.get_all_replies()

# print post details for selected post
pprint.pprint(replies)
pprint.pprint("Selected: " + option)
pprint.pprint("Number of replies: " + str(len(replies)))

