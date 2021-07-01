require 'rubygems'
require 'bundler/setup'

Bundler.require

options = {
  url: 'https://testnet.openhive.network',
  wif: '5JrvPrQeBBvCRdjv29iDvkwn3EQYZ9jqfAHzrCyUvfbEbRkrYFC'
}
tx = Radiator::Transaction.new(options)

tx.operations << {
  type: :convert,
  owner: 'social',
  requestid: 1234,
  amount: '10.000 TBD' # <- Testnet: TBD; Mainnet: HBD
}

response = tx.process(true)
  
if !!response.error
  puts response.error.message
else
  puts JSON.pretty_generate response
end

