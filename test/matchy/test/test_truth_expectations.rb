require File.dirname(__FILE__) + '/test_helper.rb'

class Exister
  def initialize(what)
    @what = what
  end
  
  def exist?
    @what
  end
end

class TestTruthExpectations < Test::Unit::TestCase
  def test_equal
    3.should equal(3)
  end

  def test_negative_equal
    instance = String.new
    
    instance.should_not equal(String.new)
  end
  
  def test_equal_fail
    lambda {
      3.should equal(4)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_equal_fail
    lambda {
      3.should_not equal(3)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end

  def test_eql
    3.should eql(3)
  end
  
  def test_negative_eql
    3.should_not eql(9)
  end
  
  def test_eql_fail
    lambda {
      3.should eql(13)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_eql_fail
    lambda {
      3.should_not eql(3)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_exists
    thing = Exister.new(true)
    thing.should exist
  end
  
  def test_negative_exists
    thing = Exister.new(false)
    thing.should_not exist
  end
  
  def test_exists_fail
    lambda {
      thing = Exister.new(false)
      thing.should exist
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_exists_fail
    lambda {
      thing = Exister.new(true)
      thing.should_not exist
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_be
    true.should be(true)
  end
  
  def test_negative_be
    true.should_not be(false)
  end
  
  def test_be_fail
    lambda {
      true.should be(false)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_be_close
    (5.0 - 2.0).should be_close(3.0)
  end
  
  def test_be_close_with_delta
    (5.0 - 2.0).should be_close(3.0, 0.2)
  end
  
  def test_be_close_fail
    lambda {
      (19.0 - 13.0).should be_close(33.04)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_be_close_with_delta_fail
    lambda {
      (19.0 - 13.0).should be_close(6.0, 0.0)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_satisfy
    13.should satisfy(lambda {|i| i < 15})
  end
  
  def test_negative_satisfy
    13.should_not satisfy(lambda {|i| i < 10})
  end
  
  def test_satisfy_fail
    lambda {
      13.should satisfy(lambda {|i| i > 15})
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_satisfy_fail
    lambda {
      13.should_not satisfy(lambda {|i| i < 15})
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_equal_fail_message
    obj = equal(4)
    obj.matches?(5)
    
    obj.failure_message.should be("Expected 5 to equal 4.")
  end
  
  def test_equal_negative_fail_message
    obj = equal(5)
    obj.matches?(5)
    
    obj.negative_failure_message.should be("Expected 5 to not equal 5.")
  end
  
  def test_eql_fail_message
    obj = eql(4)
    obj.matches?(5)
    
    obj.failure_message.should be("Expected 5 to eql 4.")
  end
  
  def test_eql_negative_fail_message_for_eql
    obj = eql(5)
    obj.matches?(5)
    
    obj.negative_failure_message.should be("Expected 5 to not eql 5.")
  end
  
  def test_exist_fail_message
    obj = exist
    obj.matches?(Exister.new(false))
    
    obj.failure_message.should =~ /Expected #<(.*)> to exist./
  end
  
  def test_exist_negative_fail_message
    obj = exist
    obj.matches?(Exister.new(true))
    
    obj.negative_failure_message.should =~ /Expected #<(.*)> to not exist./
  end
  
  def test_be_close_fail_message
    obj = be_close(3.0)
    obj.matches?(6.0)
    
    obj.failure_message.should be("Expected 6.0 to be close to 3.0 (delta: 0.3).")
  end
  
  def test_be_close_negative_fail_message
    obj = be_close(5.0)
    obj.matches?(5.0)
    
    obj.negative_failure_message.should be("Expected 5.0 to not be close to 5.0 (delta: 0.3).")
  end
  
  def test_be_fail_message
    obj = be(4)
    obj.matches?(5)
    
    obj.failure_message.should be("Expected 5 to be 4.")
  end
  
  def test_be_negative_fail_message
    obj = be(5)
    obj.matches?(5)
    
    obj.negative_failure_message.should be("Expected 5 to not be 5.")
  end
  
  def test_satisfy_fail_message
    obj = satisfy(lambda {|x| x == 4})
    obj.matches?(6)
    
    obj.failure_message.should be("Expected 6 to satisfy given block.")
  end
  
  def test_eql_negative_fail_message_for_matches
    obj = satisfy(lambda {|x| x == 4})
    obj.matches?(4)
    
    obj.negative_failure_message.should be("Expected 4 to not satisfy given block.")
  end
  
  def test_kind_of
    3.should be_kind_of(Fixnum)
  end
  
  def test_kind_of_fail
    lambda {
      3.should be_kind_of(Hash)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_kind_of
    3.should_not be_kind_of(Hash)
  end
  
  def test_negative_kind_of_fail
    lambda {
      3.should_not be_kind_of(Fixnum)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end

  def test_respond_to
    "foo".should respond_to(:length)
  end
  
  def test_respond_to_fail
    lambda {
      "foo".should respond_to(:nonexistant_method)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_negative_respond_to
    "foo".should_not respond_to(:nonexistant_method)
  end
  
  def test_negative_respond_to_fail
    lambda {
      "foo".should_not respond_to(:length)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end

end
