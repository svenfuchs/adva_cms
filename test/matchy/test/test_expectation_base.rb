require File.dirname(__FILE__) + '/test_helper.rb'

class TestExpectationBase < Test::Unit::TestCase
  def setup
    @instance = Matchy::Expectations::Base.new(true, self)
  end
  
  def test_ivars
    @instance.instance_variable_get("@expected").should eql(true)
  end
  
  def test_matches_throws_error
    lambda {
      @instance.matches?(true)
    }.should raise_error
  end
  
  def test_fail_should_raise
    lambda {
      @instance.fail!(false)
    }.should raise_error(Test::Unit::AssertionFailedError)
  end
  
  def test_pass
    @instance.pass!(true)
  end
  
  def test_failure_message
    @instance.failure_message.should eql("OMG FAIL.")
  end
  
  def test_negative_failure_message
    @instance.negative_failure_message.should eql("OMG FAIL TO FAIL.")
  end
end
