module Matchy
  module Expectations
    # Base class for all expectations.  Inheriting from this DRYs up a lot of the
    # constructor logic, etc.
    #
    # TODO: Implement failure messages, inluding negative failure messages.  Also,
    # need to name variables/parameters to go with testing nomenclature (expected rather
    # than just "object").
    class Base
      include Test::Unit::Assertions
      
      # Takes object to match against and the test_case we're in so we can feed it the 
      # successes/failures.
      def initialize(expected, test_case)
        @expected = expected
        @test_case = test_case
      end
    
      # Match the given objects against some logic.  This raises an error in Base because
      # each matcher (obviously) has to implement its own logic.
      def matches?(receiver)
        raise "Please provide logic to match your expectation to an object!  OR ELSE."
      end
    
      # Fail the expectation.  Calls flunk on the test case.
      def fail!(which)
        @test_case.flunk(which ? failure_message : negative_failure_message)
      end
      
      # Pass the expectations.  Calls <tt>assert true</tt>.  May want to consider something
      # different here.
      def pass!(which)
        @test_case.assert true
      end
      
      # Failure message.  Should be overriden.
      def failure_message
        "OMG FAIL."
      end
      
      # Negative failure message (i.e., for should_not).  Should be overridden.
      def negative_failure_message
        "OMG FAIL TO FAIL."
      end
    end
  end
end