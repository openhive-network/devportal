require 'rubygems'
require 'bundler/setup'

Bundler.require

url, weight = ARGV
slug = url.split('@').last
author = slug.split('/')[0]
permlink = slug.split('/')[1..-1].join('/')
voter = 'social'
posting_wif = '5JrvPrQeBBvCRdjv29iDvkwn3EQYZ9jqfAHzrCyUvfbEbRkrYFC'
weight = ((weight || '100.0').to_f * 100).to_i
options = {
  url: 'https://testnet.openhive.network',
  wif: posting_wif
}

tx = Radiator::Transaction.new(options)

tx.operations << {
  type: :vote,
  voter: voter,
  author: author,
  permlink: permlink,
  weight: weight
}

puts JSON.pretty_generate tx.process(true)
