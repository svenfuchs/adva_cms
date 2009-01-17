module Matchy
  module Expectations
    class Association < Base
      def initialize(test_case, type, expected, options = {})
        @type = type
        @options = options
        super expected, test_case
      end
      
      def matches?(model)
        @receiver = model
        model = model.class if model.is_a? ActiveRecord::Base
        !!model.reflect_on_all_associations(@type).find do |a|
          a.name == @expected and options_match?(a.options)
        end
      end
      
      def options_match?(options)
        @options.each do |key, value|
          return false if !options.has_key?(key) || options[key] != value
        end
        true
      end

      def failure_message
        "Expected #{@receiver.inspect} to #{@type} #{@expected.inspect}."
      end

      def negative_failure_message
        "Expected #{@receiver.inspect} not to #{@type} #{@expected.inspect}."
      end
    end

    class ValidatesPresenceOf < Base
      def matches?(model)
        @receiver = model
        
        model.send("#{@expected}=", nil)
        !model.valid? && model.errors.invalid?(@expected)
      end

      def failure_message
        "Expected #{@receiver.inspect} to validate the presence of #{@expected.inspect}."
      end

      def negative_failure_message
        "Expected #{@receiver.inspect} not to validate the presence of #{@expected.inspect}."
      end
    end

    module TestCaseExtensions
      def belong_to(expected, options = {})
        Matchy::Expectations::Association.new(self, :belongs_to, expected, options)
      end
      
      def have_one(expected, options = {})
        Matchy::Expectations::Association.new(self, :has_one, expected, options)
      end
      
      def have_many(expected, options = {})
        Matchy::Expectations::Association.new(self, :has_many, expected, options)
      end
      
      def validate_presence_of(attribute)
        Matchy::Expectations::ValidatesPresenceOf.new(attribute, self)
      end
    end
  end
end