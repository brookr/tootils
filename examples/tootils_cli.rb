#!/usr/bin/ruby
#
#
# Here are some examples:
# If this file is executable, it can be run as a command line script.
# If it has no arguments, it will show available API hits.
# With one twitter username as an argument, it will show internal Twitter
# id, and how many people that user is following, as well as API hits remaining.
# With two twitter usernames as args, it will show following count for the first
# user, API hits remaining, and a graph of connections between the first and the 
# second user.
# 
# For Example:
# ./tootils.rb
# => Start Limit: 90, End Limit: 90, Cost: 0
# 
# ./tootils.rb brookr
# => "User brookr (id: 11136022) has 143 friends."
# => Start Limit: 90, End Limit: 90, Cost: 0
#
# ./tootils.rb brookr jackdanger
# => "User brookr (id: 11136022) has 143 friends."
# => Start Limit: 90, End Limit: 90, Cost: 0
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tootils'

config = YAML::load(File.read(File.join(ENV['HOME'], '.twitter')))

tools = Tootils::Tools.new(config['email'], config['password'])
start_limit = Tootils::Tools.remaining_hits
pp "User #{ARGV[0]} (id: #{tools.info(ARGV[0])['id']}) has #{tools.friends(ARGV[0]).length} friends." unless ARGV[0].nil?

unless( ARGV[0].nil? or ARGV[1].nil? )
  pp tools.graph(ARGV[0], ARGV[1])
  for deg, links in tools.graph(ARGV[0], ARGV[1])
    for link in links
      puts link.map{ |id| tools.info(id)['screen_name'] }.join(' -> ')
    end
    if links.empty?
      puts "No connection in the #{deg} Degree"
    else
      puts "Found #{links.length} connections in the #{deg} Degree"
      break
    end
  end
end
end_limit = Tootils.remaining_hits

# The limit count seems to have very strange results. not sure what is up.
puts "Start Limit: " + start_limit.to_s + ", End Limit: " + end_limit.to_s + ", Cost: " + (start_limit - end_limit).to_s