require 'test_helper'

class TootilsTest < Test::Unit::TestCase
  should "build auth hash" do
    assert !Tootils::Tools.new('user', 'pass').options.empty?
  end
  
  should "find first degree connections" do
    assert !Tootils::Tools.new('user', 'pass').graph('brookr', 'jackdanger')[1].empty?
  end
end
