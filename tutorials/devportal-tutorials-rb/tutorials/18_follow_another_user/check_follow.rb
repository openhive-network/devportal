require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new
account_name = 'social'
follow_name = 'alice'
what = 'blog' # use `blog` to find follows, `ignore` to find mutes
follows = []
following = false
limit = 10 # how many follows to read per api call (limit 1000)
count = 0

loop do
  follows += api.get_following(account_name, follows.last, what, limit) do |follows|
    follows.map(&:following)
  end
  
  follows = follows.uniq

  break unless count < follows.size
  count = follows.size
end

if follows.include? follow_name
  puts "#{account_name} is following #{follow_name}"
else
  puts "#{account_name} is *not* following #{follow_name}"
end
