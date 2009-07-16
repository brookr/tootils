#!/usr/bin/ruby
#
# See README for version history and usage
#

require 'rubygems'
require 'httparty'
require 'pp'
config = YAML::load(File.read(File.join(ENV['HOME'], '.twitter')))

class Tootils
  include HTTParty
  base_uri 'twitter.com'
  format :json
  
  def initialize(user, pass)
    @auth = {:username => user, :password => pass}
  end
  
  def options
    options = { :basic_auth => @auth }
  end
  
  def self.remaining_hits
    options = { :basic_auth => @auth }
    get("/account/rate_limit_status.json", options)['remaining_hits']
  end
  
  def check_limit
    if self.class.remaining_hits > 1
      true
    else
      raise 'Over API rate limit!'
      exit 2
    end
  end
  
  
  def friends(user)
    friends = self.class.get("/friends/ids/#{user.to_s}.json", options)
    if friends["error"] 
      pp friends
      return []
    end  unless friends.class == Array
    friends
  end
  
  def followers(user)
    followers = self.class.get("/followers/ids/#{user.to_s}.json", options)
    if followers["error"] 
      pp followers
      return []
    end unless followers.class == Array
    followers
  end
  
  def info(user)
    info = self.class.get("/users/show/#{user.to_s}.json", options)
    if info["error"]
      pp info
      return {}
    end
    info
  end
  
  # Check two lists to see if there is a common ID in both, and return it
  def common_ids(list1, list2)
    list1.each do |friend|
      return friend if list2.include?(friend)
    end
    false # if no one in list1 is in list2
  end
  
  # Our first twitter tool: Graphing connections from the first user to the second.
  # This will check the first 3 degrees for links, and return a hash of connections
  # found in each degree.
  # Once any degree has a connection in it, additional degrees are not checked.
  def graph(twit1, twit2)
    twit1_id = info(twit1)['id']
    twit1_friends = friends(twit1)
    twit2_id = info(twit2)['id']
    twit2_followers = followers(twit2)
    # Start assuming there are no connections
    graph = { 1 => [], 2 => [], 3 => [] }
    
    if twit2_followers.include?(twit1_id)
      graph[1] = [[twit1_id, twit2_id]]
    end
    
    return graph unless graph[1].empty?
    
    # Check second degree: Are there friends of twit1 who follow twit2? 
    # Get an array of all connections.
    for friend in (twit1_friends & twit2_followers)
      graph[2] << [twit1_id, friend, twit2_id]
    end
    return graph unless graph[2].empty?
    
    # Check the 3rd degree: This is the real API hit.
    # We need to check friends of friends, or the followers of followers,
    # which ever is fewer
    if twit1_friends.length < twit2_followers.length
      for friend in twit1_friends
        friends_of_friend = friends(friend)
        deg3 = friends_of_friend & twit2_followers
        # Add a connection for each friend of a friend who is a follower of twit2
        for fof in deg3
          graph[3] << [twit1_id, friend, fof, twit2_id]
        end
      end
    else
      for follower in twit2_followers
        followers_of_follower = followers(follower)
        deg3 = twit1_friends & followers_of_follower
        # Add a connection for each follower of a follower who is a friend of twit1
        for fof in deg3
          graph[3] << [twit1_id, fof, follower, twit2_id]
        end rescue pp "Can't get followers for #{follower}: #{info(follower)}"
      end
    end
    return graph
  end
    
  
end



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

tools = Tootils.new(config['email'], config['password'])
start_limit = Tootils.remaining_hits
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
      puts "Found connection in the #{deg} Degree"
      break
    end
  end
end
end_limit = Tootils.remaining_hits

# The limit count seems to have very strange results. not sure what is up.
puts "Start Limit: " + start_limit.to_s + ", End Limit: " + end_limit.to_s + ", Cost: " + (start_limit - end_limit).to_s