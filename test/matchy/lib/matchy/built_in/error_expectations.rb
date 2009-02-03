module Matchy
  module Expectations
    class RaiseErrorExpectation < Base
      def initialize(expected, test_case)
        @error = nil
        super
      end

      def matches?(receiver)
        @receiver = receiver
        begin
          receiver.call
          return false
        rescue StandardError => e
          @error = e
          return false unless e.class.ancestors.include?(@expected)
        
          return true
        end
      end
      
      def failure_message
        extra = ""
        if @error
          extra = "but #{@error.class.name} was raised instead"
        else
          extra = "but none was raised"
        end
        
        "Expected #{@receiver.inspect} to raise #{@expected.name}, #{extra}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not raise #{@expected.name}."
      end
    end
    
    class ThrowSymbolExpectation < Base
      def initialize(expected, test_case)
        @thrown_symbol = nil
        super
      end

      def matches?(receiver)
        @receiver = receiver
        begin
          receiver.call
        rescue NameError => e
          raise e unless e.message =~ /uncaught throw/
          @thrown_symbol = e.name.to_sym
        ensure
          return @expected == @thrown_symbol
        end
      end
      
      def failure_message
        "Expected #{@receiver.inspect} to throw :#{@expected}, but #{@thrown_symbol ? ':' + @thrown_symbol.to_s + ' was thrown instead' : 'no symbol was thrown'}."
      end
      
      def negative_failure_message
        "Expected #{@receiver.inspect} to not throw :#{@expected}."
      end
    end

    module TestCaseExtensions
      # Expects a lambda to raise an error.  You can specify the error or leave it blank to encompass
      # any error.
      #
      # ==== Examples
      #
      #   lambda { raise "FAILURE." }.should raise_error
      #   lambda { puts i_dont_exist }.should raise_error(NameError)
      #
      def raise_error(obj = StandardError)
        Matchy::Expectations::RaiseErrorExpectation.new(obj, self)
      end
      
      # Expects a lambda to throw an error.
      #
      # ==== Examples
      #
      #   lambda { throw :thing }.should throw_symbol(:thing)
      #   lambda { "not this time" }.should_not throw_symbol(:hello)
      #
      def throw_symbol(obj)
        Matchy::Expectations::ThrowSymbolExpectation.new(obj, self)
      end      
    end
  end
end