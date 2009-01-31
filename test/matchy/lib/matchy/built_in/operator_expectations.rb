module Matchy
  module Expectations
    # Class to handle operator expectations.
    #
    # ==== Examples
    #   
    #   13.should == 13
    #   "hello".length.should_not == 2
    #
    class OperatorExpectation < Base      
      def initialize(receiver, match)
        @receiver = receiver
        @match = match
      end

      def ==(expected)
        @expected = expected
        if @receiver.send(:==, expected) == @match
          pass!
        else
          fail!("==")
        end
      end
      
      def ===(expected)
        @expected = expected
        if @receiver.send(:===, expected) == @match
          pass!
        else
          fail!("===")
        end
      end
      
      def =~(expected)
        @expected = expected
        if @receiver.send(:=~, expected).nil? != @match
          pass!
        else
          fail!("=~")
        end
      end
      
      def >(expected)
        @expected = expected
        if @receiver.send(:>, expected) == @match
          pass!
        else
          fail!(">")
        end
      end
      
      def <(expected)
        @expected = expected
        if @receiver.send(:<, expected) == @match
          pass!
        else
          fail!("<")
        end
      end
      
      def >=(expected)
        @expected = expected
        if @receiver.send(:>=, expected) == @match
          pass!
        else
          fail!(">=")
        end
      end
      
      def <=(expected)
        @expected = expected
        if @receiver.send(:<=, expected) == @match
          pass!
        else
          fail!("<=")
        end
      end
      
      protected
      def pass!
        assert true
      end
      
      def fail!(operator)
        flunk @match ? failure_message(operator) : negative_failure_message(operator)
      end
      
      def failure_message(operator)
        "Expected #{@receiver.inspect} to #{operator} #{@expected.inspect}."
      end
      
      def negative_failure_message(operator)
        "Expected #{@receiver.inspect} to not #{operator} #{@expected.inspect}."
      end
    end
  end
end