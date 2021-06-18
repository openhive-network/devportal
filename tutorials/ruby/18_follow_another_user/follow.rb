require 'rubygems'
require 'bundler/setup'

Bundler.require

options = {
  url: 'https://testnet.openhive.network',
  wif: '5JrvPrQeBBvCRdjv29iDvkwn3EQYZ9jqfAHzrCyUvfbEbRkrYFC'
}
tx = Radiator::Transaction.new(options)
what = 'blog' # set this to empty string to unfollow

tx.operations << {
  type: :custom_json,
  id: 'follow',
  required_auths: [],
  required_posting_auths: ['social'],
  json: [:follow, {
    follower: 'social',
    following: 'alice',
    what: [what]
  }].to_json
}

response = tx.process(true)

if !!response.error
  puts response.error.message
else
  puts JSON.pretty_generate response
end
