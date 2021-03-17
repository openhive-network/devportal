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
