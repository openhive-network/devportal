require 'rubygems'
require 'bundler/setup'

Bundler.require

url = ARGV[0]
slug = url.split('@').last
author = slug.split('/')[0]
permlink = slug.split('/')[1..-1].join('/')
reblogger = 'social'
posting_wif = '5JrvPrQeBBvCRdjv29iDvkwn3EQYZ9jqfAHzrCyUvfbEbRkrYFC'
options = {wif: posting_wif}

tx = Radiator::Transaction.new(options)

data = [
  :reblog, {
    account: reblogger,
    author: author,
    permlink: permlink
  }
]

tx.operations << {
  type: :custom_json,
  id: 'follow',
  required_auths: [],
  required_posting_auths: [reblogger],
  json: data.to_json
}

puts JSON.pretty_generate tx.process(true)
