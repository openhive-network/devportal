require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new
lower_bound_name, limit = ARGV
limit = (limit || '10').to_i

api.lookup_accounts(lower_bound_name, limit) do |accounts|
  puts accounts.join(' ')
end
