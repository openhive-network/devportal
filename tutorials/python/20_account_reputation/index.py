import pprint
from pick import pick

# initialize Hive class
from beem import Hive
from beem.account import Account

hive = Hive()

title = 'Please choose account: '
options = ["hiveio","ecency","busy.org","demo"]

# get index and selected filter name
option, index = pick(options, title)

# option is printed as reference
pprint.pprint("Selected: " + option)

user = Account(option, blockchain_instance=hive)

# print specified account's reputation
pprint.pprint(user.get_reputation())

