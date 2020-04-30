require 'rubygems'
require 'bundler/setup'

Bundler.require

options = {
  wif: '5JrvPrQeBBvCRdjv29iDvkwn3EQYZ9jqfAHzrCyUvfbEbRkrYFC'
}
tx = Radiator::Transaction.new(options)

tags = %w(tag1)
metadata = {
  tags: tags
}

tx.operations << {
  type: :comment,
  author: 'social',
  permlink: 'test-post-reply',
  parent_author: 'social',
  parent_permlink: 'test-post',
  title: '',
  body: 'Reply',
  json_metadata: metadata.to_json
}

response = tx.process(true)

if !!response.error
  puts response.error.message
else
  puts JSON.pretty_generate response
end
