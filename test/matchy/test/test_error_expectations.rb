require File.dirname(__FILE__) + '/test_helper.rb'

class TestErrorExpectations < Test::Unit::TestCase
  def test_raises_error
    lambda { raise "FAIL" }.should raise_error
  end
  
  def test_raises_error_fail
    lambda {
      lambda { "WIN" }.should raise_error
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_raises_error
    lambda { "WIN" }.should_not raise_error
  end
  
  def test_negative_raises_error_fail
    lambda {
      lambda { raise "FAIL" }.should_not raise_error
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_raises_specific_error
    lambda { raise TypeError }.should raise_error(TypeError)
  end
  
  def test_raises_specific_error_fail_with_no_error
    lambda {
      lambda { "WIN" }.should raise_error(TypeError)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_raises_specific_error_fail_with_different_error
    lambda {
      lambda { raise StandardError }.should raise_error(TypeError)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_throws_symbol
    lambda {
      throw :win
    }.should throw_symbol(:win)
  end
  
  def test_throws_symbol_fails_with_different_symbol
    lambda {
      lambda {
        throw :fail
      }.should throw_symbol(:win)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_throws_symbol
    lambda {
      "not this time!"
    }.should_not throw_symbol(:win)
  end
  
  def test_negative_throws_symbol_fails_with_different_symbol
    lambda{
      lambda {
        throw :fail
      }.should_not throw_symbol(:fail)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_error_fail_message
    obj = raise_error(TypeError)
    obj.matches?(lambda { raise NameError })
    
    obj.failure_message.should =~ /Expected #<(.*)> to raise TypeError, but NameError was raised instead./
  end
  
  def test_error_fail_message_when_no_error
    obj = raise_error(TypeError)
    obj.matches?(lambda { "moop" })
    
    obj.failure_message.should =~ /Expected #<(.*)> to raise TypeError, but none was raised./
  end
  
  def test_error_negative_fail_message
    obj = raise_error(TypeError)
    obj.matches?(lambda { raise TypeError })
    
    obj.negative_failure_message.should =~ /Expected #<(.*)> to not raise TypeError./
  end
  
  def test_throw_fail_message
    obj = throw_symbol(:fail)
    obj.matches?(lambda { throw :lame })
    
    obj.failure_message.should =~ /Expected #<(.*)> to throw :fail, but :lame was thrown instead./
  end
  
  def test_throw_fail_message_when_no_symbol
    obj = throw_symbol(:fail)
    obj.matches?(lambda { "moop" })
    
    obj.failure_message.should =~ /Expected #<(.*)> to throw :fail, but no symbol was thrown./
  end
  
  def test_throw_negative_fail_message
    obj = throw_symbol(:fail)
    obj.matches?(lambda { throw :fail })
    
    obj.negative_failure_message.should =~ /Expected #<(.*)> to not throw :fail./
  end
end
