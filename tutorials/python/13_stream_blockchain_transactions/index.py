from beem.blockchain import Blockchain
from beem import Hive

h = Hive()
blockchain = Blockchain(blockchain_instance=h)
stream = blockchain.stream()

for op in stream:
  if op["type"] == 'comment':
    if len(op["parent_author"]) == 0:
      print(op["author"] + " authored a post: " + op["title"])
    else:
      print(op["author"] + " replied to " + op["parent_author"])
    
