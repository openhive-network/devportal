require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new

if ARGV.size < 1
  puts "Usage:"
  puts "ruby #{__FILE__} <account> [following|followers] [limit]"
  exit
end

type = 'blog' # use 'ignore' to get mutes
account = ARGV[0]
what = ARGV[1] || 'following'
limit = (ARGV[2] || '-1').to_i
result = []
count = -1

method = "get_#{what}"
elem = what.sub(/s/, '').to_sym

until count >= result.size
  count = result.size
  response = api.send(method, account, result.last, type, [limit, 1000].max)
  abort response.error.message if !!response.error
  result += response.result.map(&elem)
  result = result.uniq
end

puts result[0..limit]
puts "#{account} #{what}: #{result.size}"
