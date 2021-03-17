from pick import pick
# initialize Hive class
from beem import Hive
from beem.account import Account

hive = Hive()

# capture username
account = input("Username: ")
account = Account(account, blockchain_instance=hive)

# capture list limit
limit = input("Max number of followers(ing) to display: ")
limit = int(limit)

# list type
title = 'Please choose the type of list: '
options = ['Follower', 'Following']

# get index and selected list name
option, index = pick(options, title)
print("List of " + option)

# create empty list
follows = []

# parameters for get_followers function:
# start_follower, follow_type, limit
if option=="Follower" :
  follows = account.get_followers()[:limit]
else:
  follows = account.get_following()[:limit]

# check if follower(ing) list is empty
if len(follows) == 0:
  print("No " + option + " information available")
  exit()

print(*follows, sep='\n')

