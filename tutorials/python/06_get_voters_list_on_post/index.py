import pprint
from pick import pick
# initialize Hive class
from beem import Hive
from beem.discussions import Query, Discussions
from beem.vote import ActiveVotes

h = Hive()
q = {"limit": 5, "tag": "", "before_date": None}
d = Discussions()

#post list for selected query
posts = d.get_discussions('hot', q, limit=5)

title = 'Please choose post: '
options = []

#posts list
for post in posts:
	options.append(post["author"] + '/' + post["permlink"])

# get index and selected filter name
option, index = pick(options, title)

voters = ActiveVotes(option)

# print voters list for selected post
voters.printAsTable()
pprint.pprint("Selected: " + option)

