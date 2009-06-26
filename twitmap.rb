#!/usr/bin/ruby
#
# See README for version history and usage
#

require 'rubygems'
require 'HTTParty'

API_USER = 'your_user_name_here'
API_PASS = 'your_pass_here'

class Twitmap
  include HTTParty
  base_uri 'twitter.com'
  format :json
  
  @max_friends_checked = 50
  
  def initialize(user, pass)
    self.class.basic_auth user, pass
  end
  
  def self.remaining_hits
    get('/account/rate_limit_status.json')['remaining_hits']
  end
  
  def check_limit
    if self.class.remaining_hits > 1
      return true
    else
      raise 'Over API rate limit!'
      exit 2
    end
  end
  
  
  def friends(user)
    self.class.get('/friends/ids/'+user.to_s+'.json') if check_limit
  end
  
  def followers(user)
    self.class.get('/followers/ids/'+user.to_s+'.json') if check_limit
  end
  
  def get_info(user)
    self.class.get('/users/show/'+user.to_s+'.json') if check_limit
  end
  
  # Check two lists to see if there is a common ID in both, and return it
  def common_id?(list1, list2)
    list1.each do |friend|
      return friend if list2.include?(friend)
    end
    false # if no one in list1 is in list2
  end
  
  def links_between(twit1, twit2)
    twit1_friends = friends(twit1)
    twit2_followers = followers(twit2)
    
    if twit2_followers.include?(get_info(twit1)['id'])
        return [twit1, twit2].join(' -> ')
    end
    
    # Check second degree: Is there a friend of twit1 who follows twit2? 
    # Return the first found link
    if link = common_id?(twit1_friends, twit2_followers)
      return [twit1, get_info(link)['screen_name'], twit2].join(' -> ')
    end
    
    # Check the 3rd degree: This is the real API hit.
    # We need to check friends of friends, or the followers of followers,
    # which ever is fewer
    if twit1_friends.length < twit2_followers.length
      twit1_friends.each do |friend|
        if link = common_id?(friends(friend), twit2_followers)
          return [twit1 , get_info(friend)['screen_name'],
            get_info(link)['screen_name'], twit2].join(' -> ')
        end
      end
    else
      twit2_followers.each do |follower|
        if link = common_id?(twit1_friends, followers(follower))
          return [twit1, get_info(link)['screen_name'], 
            get_info(follower)['screen_name'], twit2].join(' -> ')
        end
      end
    end
    
    return 'sorry, no connections in 3 degrees.';
  end
    
  
end

if( ARGV[0].nil? or ARGV[1].nil? )
  raise "Invalid arguments: 2 non-empty strings needed"
  exit 1
end

#
# The code below is processed sequentially, the main script execution steps:
#
start_limit = Twitmap.remaining_hits

puts Twitmap.new(API_USER,API_PASS).links_between(ARGV[0], ARGV[1])

end_limit = Twitmap.remaining_hits

# The limit count seems to have very strange results. not sure what is up.
puts "Start Limit: " + start_limit.to_s + ", End Limit: " + end_limit.to_s + ", Cost: " + (start_limit - end_limit).to_s