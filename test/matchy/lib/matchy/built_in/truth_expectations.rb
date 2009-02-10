module Matchy
  module Expectations
    class BeExpectation < Base
      def matches?(receiver)
        @receiver = receiver
        
        @expected == receiver
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to be #{@expected.inspect}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not be #{@expected.inspect}."
      end
    end
    
    class BeKindOfExpectation < Base
      def matches?(receiver)
        @receiver = receiver
        @receiver.kind_of?(@expected)
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to be kind of #{@expected.inspect}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not be kind of #{@expected.inspect}."
      end
    end
    
    class BeCloseExpectation < Base
      def initialize(expected, delta, test_case)
        @expected = expected
        @test_case = test_case
        @delta = delta
      end
      
      def matches?(receiver)
        @receiver = receiver
        
        (receiver - @expected).abs < @delta
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to be close to #{@expected.inspect} (delta: #{@delta})."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not be close to #{@expected.inspect} (delta: #{@delta})."
      end
    end
    
    class ExistExpectation < Base
      def initialize(test_case)
        @test_case = test_case
      end
      
      def matches?(receiver)
        @receiver = receiver
        receiver.exist?
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to exist."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not exist."
      end
    end
    
    class EqlExpectation < Base
      def matches?(receiver)
        @receiver = receiver
        @expected.eql?(receiver)
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to eql #{@expected.inspect}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not eql #{@expected.inspect}."
      end
    end
    
    class EqualExpectation < Base
      def matches?(receiver)
        @receiver = receiver
        @expected.equal?(receiver)
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to equal #{@expected.inspect}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not equal #{@expected.inspect}."
      end
    end
    
    class SatisfyExpectation < Base
      def matches?(receiver)
        @receiver = receiver
        @expected.call(receiver) == true
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to satisfy given block."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not satisfy given block."
      end
    end

    class RespondToExpectation < Base
      def matches?(receiver)
        @receiver = receiver
        @receiver.respond_to?(@expected)
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to respond to #{@expected.inspect}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not respond to #{@expected.inspect}."
      end
    end
    
    module TestCaseExtensions
      # Simply checks if the receiver matches the expected object.
      # TODO: Fill this out to implement much of the RSpec functionality (and then some)
      #
      # ==== Examples
      #
      #   "hello".should be("hello")
      #   (13 < 20).should be(true)
      #
      def be(obj)
        Matchy::Expectations::BeExpectation.new(obj, self)
      end
      
      # Checks if the given object is kind_of? the expected class
      #
      # ==== Examples
      # 
      #   "hello".should be_kind_of(String)
      #   3.should be_kind_of(Fixnum)
      def be_kind_of(klass)
        Matchy::Expectations::BeKindOfExpectation.new(klass, self)
      end
      
      # Checks if the given object is within a given object and delta.
      #
      # ==== Examples
      #
      #   (20.0 - 2.0).should be_close(18.0)
      #   (13.0 - 4.0).should be_close(9.0, 0.5)
      #
      def be_close(obj, delta = 0.3)
        Matchy::Expectations::BeCloseExpectation.new(obj, delta, self)
      end
      
      # Calls +exist?+ on the given object.
      #
      # ==== Examples
      #
      #   # found_user.exist?
      #   found_user.should exist
      #
      def exist
        Matchy::Expectations::ExistExpectation.new(self)
      end   
      
      # Calls +eql?+ on the given object (i.e., are the objects the same value?)
      #
      # ==== Examples
      #   
      #    1.should_not eql(1.0)
      #    (12 / 6).should eql(6)
      #
      def eql(obj)
        Matchy::Expectations::EqlExpectation.new(obj, self)
      end
      
      # Calls +equal?+ on the given object (i.e., do the two objects have the same +object_id+?)
      #
      # ==== Examples
      # 
      #   x = [1,2,3]
      #   y = [1,2,3]
      #
      #   # Different object_id's...
      #   x.should_not equal(y)
      #
      #   # The same object_id
      #   x[0].should equal(y[0])
      #
      def equal(obj)
        Matchy::Expectations::EqualExpectation.new(obj, self)
      end
      
      # A last ditch way to implement your testing logic.  You probably shouldn't use this unless you
      # have to.
      #
      # ==== Examples
      #
      #   (13 - 4).should satisfy(lambda {|i| i < 20})
      #   "hello".should_not satisfy(lambda {|s| s =~ /hi/})
      #
      def satisfy(obj)
        Matchy::Expectations::SatisfyExpectation.new(obj, self)
      end
      
      # Checks if the given object responds to the given method
      #
      # ==== Examples
      #
      #   "foo".should respond_to(:length)
      #   {}.should respond_to(:has_key?)
      def respond_to(meth)
        Matchy::Expectations::RespondToExpectation.new(meth, self)
      end   
    end
  end
end