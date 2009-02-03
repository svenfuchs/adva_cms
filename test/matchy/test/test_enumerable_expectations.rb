require File.dirname(__FILE__) + '/test_helper.rb'

class TestEnumerableExpectations < Test::Unit::TestCase
  def test_include
    [1,2,3,4].should include(4)
  end
  
  def test_include_fail
    lambda {
      [1,2,3,4].should include(6)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_exclude
    [1,2,3,4].should exclude(9)
  end
  
  def test_exclude_fail
    lambda {
      [1,2,3,4].should exclude(4)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_multi_include
    [1,2,3,4].should include(1,2)
  end
  
  def test_multi_include_fail
    lambda {
      [1,2,3,4].should include(6,7,8)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_multi_exclude
    [1,2,3,4].should exclude(13,14)
  end
  
  def test_multi_exclude_fail
    lambda {
      [1,2,3,4].should exclude(2,3,4)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_include
    [1,2,3,4].should_not include(9)
  end
  
  def test_negative_include_fail
    lambda {
      [1,2,3,4].should_not include(4)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_exclude
    [1,2,3,4].should_not exclude(3)
  end
  
  def test_negative_exclude_fail
    lambda {
      [1,2,3,4].should_not exclude(6,7)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_include_fail_message
    obj = include(1)
    obj.matches?([4,5,6])
    
    obj.failure_message.should be("Expected [4, 5, 6] to include [1].")
  end
  
  def test_include_negative_fail_message
    obj = include(1)
    obj.matches?([4,5,6])
    
    obj.negative_failure_message.should be("Expected [4, 5, 6] to not include [1].")
  end
  
  def test_exclude_fail_message
    obj = exclude(4)
    obj.matches?([4,5,6])
    
    obj.failure_message.should be("Expected [4, 5, 6] to exclude [4].")
  end
  
  def test_exclude_negative_fail_message
    obj = exclude(4)
    obj.matches?([4,5,6])
    
    obj.negative_failure_message.should be("Expected [4, 5, 6] to not exclude [4].")
  end
end
