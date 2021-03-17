# initialize Hive class
from beem import Hive
from beem.account import Account

# defining private keys inside source code is not secure way but possible
h = Hive(keys=['<private_posting_key>', '<private_active_key>'])
a = Account('demo', blockchain_instance=h)

# above will allow accessing Commit methods such as
# demo account sending 0.001 HIVE to demo1 account

a.transfer('demo1', '0.001', 'HIVE', memo='memo text')

# if private keys are not defined
# accessing Wallet methods are also possible and secure way
h.wallet.getActiveKeyForAccount('demo')
