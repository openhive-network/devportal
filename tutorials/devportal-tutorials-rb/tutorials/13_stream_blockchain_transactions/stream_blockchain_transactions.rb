require 'rubygems'
require 'bundler/setup'

Bundler.require

mode = (ARGV[0] || 'irreversible').to_sym
what = (ARGV[1] || 'ops').to_sym
type = (ARGV[2..-1] || ['vote']).map(&:to_sym)
stream = Radiator::Stream.new

# Set to a block number you would like to begin streaming from, or leave nil
# to stream from the latest block.
start = nil
args = [start, mode]

case what
when :blocks
  stream.blocks(*args) do |block|
    block_num = block.block_id[0..7].hex
    print "block_num: #{block_num}"
    puts "; block_id: #{block.block_id}"
    print "\ttransactions: #{block.transactions.size}"
    print "; witness: #{block.witness}"
    puts "; timestamp: #{block.timestamp}"
  end
when :transactions
  stream.transactions(*args) do |trx|
    puts JSON.pretty_generate trx
  end
when :ops
  stream.operations(type, *args) do |op|
    puts op.to_json
  end
end

