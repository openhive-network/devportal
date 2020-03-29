require 'rubygems'
require 'bundler/setup'

Bundler.require

api = Radiator::Api.new
limit = (ARGV[0] || '10').to_i
all_tags = []

until all_tags.size >= limit
  last_tag = if all_tags.any?
    all_tags.last.name
  else
    nil
  end
  
  api.get_trending_tags(last_tag, [limit, 51].min) do |tags|
    all_tags += tags
  end
  
  all_tags = all_tags.uniq
end

all_tags.each do |tag|
  print "tag: #{tag.name.empty? ? '<empty>' : tag.name},"
  print " total_payouts: #{tag.total_payouts},"
  print " net_votes: #{tag.net_votes},"
  print " top_posts: #{tag.top_posts},"
  print " comments: #{tag.comments},"
  print " trending: #{tag.trending}\n"
end
