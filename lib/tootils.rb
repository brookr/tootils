# See README for version history and usage
#

require 'rubygems'
require 'httparty'
require 'pp'
config = YAML::load(File.read(File.join(ENV['HOME'], '.twitter')))

module Tootils
  class Tools
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
    
      # Check second degree: Are there friends of twit1 who are followers of twit2? 
      # Get an array of all connections.
      for friend in (twit1_friends & twit2_followers)
        graph[2] << [twit1_id, friend, twit2_id]
      end
      return graph unless graph[2].empty?
    
      # Check the 3rd degree: This is where we really burn through API calls.
      # We need to check friends of friends, or the followers of followers,
      # which ever is fewer to save API hits
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
end
