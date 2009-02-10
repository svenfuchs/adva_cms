require File.dirname(__FILE__) + '/test_helper.rb'

class TestOperatorExpectations < Test::Unit::TestCase
  # EQUALS (==)
  def test_equals
    3.should == 3
  end
  
  def test_equals_fails
    lambda {
      3.should == 5
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_equals
    3.should_not == 4
  end
  
  def test_negative_equals_fails
    lambda {
      3.should_not == 3
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  # LESS THAN (<)
  def test_less_than
    3.should < 5
  end
  
  def test_less_than_fails
    lambda {
      4.should < 3
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_less_than_equals
    3.should_not < 2
  end
  
  def test_negative_less_than_fails
    lambda {
      4.should_not < 5
    }.should raise_error(Test::Unit::AssertionFailedError)
  end 
  
  # GREATER THAN (<)
  def test_greater_than
    3.should > 2
  end
  
  def test_greater_than_fails
    lambda {
      4.should > 5
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_greater_than_equals
    3.should_not > 5
  end
  
  def test_negative_greater_than_fails
    lambda {
      4.should_not > 3
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  # LESS THAN EQUAL (<=)
  def test_less_than_equal
    3.should <= 5
  end
  
  def test_less_than_equal_equal
    3.should <= 3
  end
  
  def test_less_than_equal_fails
    lambda {
      4.should <= 3
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_less_than_equal
    3.should_not <= 2
  end
  
  def test_negative_less_than_equal_fails
    lambda {
      4.should_not <= 5
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  # GREATER THAN EQUALS (<=)
  def test_greater_than_equal
    3.should >= 2
  end
  
  def test_greater_than_equal_equals
    3.should >= 3
  end
  
  def test_greater_than_equal_fails
    lambda {
      4.should >= 5
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_greater_than_equal_equals
    3.should_not >= 5
  end
  
  def test_negative_greater_than_equal_fails
    lambda {
      4.should_not >= 3
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  # MATCHES (=~)
  def test_matches
    "hey world".should =~ /world/
  end
  
  def test_matches_fails
    lambda {
      "d00d ur 1337".should =~ /world/
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_matches
    "1337@age".should_not =~ /434/
  end
  
  def test_negative_matches_fails
    lambda {
      "it's a freak out!".should_not =~ /freak/
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_fail_message
    obj = Matchy::Expectations::OperatorExpectation.new(3, true)
    
    def obj.flunk(msg)
      msg
    end
    
    (obj == 4).should == "Expected 3 to == 4."
  end
  
  def test_negative_fail_message
    obj = Matchy::Expectations::OperatorExpectation.new(3, false)
    
    def obj.flunk(msg)
      msg
    end
    
    (obj == 3).should == "Expected 3 to not == 3."
  end
end
