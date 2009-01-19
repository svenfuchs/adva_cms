module Matchy
  module Expectations
    module TestCaseExtensions
      def be_nil
        Matchy::Expectations::Be.new(nil, self)
      end

      def be_true
        Matchy::Expectations::Be.new(true, self)
      end
      
      def be_false
        Matchy::Expectations::Be.new(false, self)
      end
      
      def respond_to(expected)
        Matchy::Expectations::RespondTo.new(expected, self)
      end
      
      def belong_to(expected, options = {})
        Matchy::Expectations::Association.new(self, :belongs_to, expected, options)
      end

      def have_one(expected, options = {})
        Matchy::Expectations::Association.new(self, :has_one, expected, options)
      end

      def have_many(expected, options = {})
        Matchy::Expectations::Association.new(self, :has_many, expected, options)
      end

      def validate_presence_of(attribute, options = {})
        Matchy::Expectations::ValidatesPresenceOf.new(attribute, self)
      end

      def validate_uniqueness_of(attribute, options = {})
        Matchy::Expectations::ValidatesUniquenessOf.new(attribute, self, options)
      end
    end

    class Be < Base
      def matches?(receiver)
        @receiver = receiver
        @expected.class === receiver
      end

      def failure_message
        "Expected #{@receiver.inspect} to be #{@expected.inspect}."
      end

      def negative_failure_message
        "Expected #{@receiver.inspect} not to be #{@expected.inspect}."
      end
    end
    
    class RespondTo < Base
      def matches?(receiver)
        @receiver = receiver
        receiver.respond_to? @expected
      end

      def failure_message
        "Expected #{@receiver.inspect} to respond to #{@expected.inspect}."
      end

      def negative_failure_message
        "Expected #{@receiver.inspect} not to respond to #{@expected.inspect}."
      end
    end

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
        "Expected #{@receiver.class.name} to #{@type} #{@expected.inspect}."
      end

      def negative_failure_message
        "Expected #{@receiver.class.name} not to #{@type} #{@expected.inspect}."
      end
    end

    class ValidatesPresenceOf < Base
      def matches?(model)
        @receiver = model

        model.send("#{@expected}=", nil)
        !model.valid? && model.errors.invalid?(@expected)
      end

      def failure_message
        "Expected #{@receiver.class.name} to validate the presence of #{@expected.inspect}."
      end

      def negative_failure_message
        "Expected #{@receiver.class.name} not to validate the presence of #{@expected.inspect}."
      end
    end

    class ValidatesUniquenessOf < Base
      def initialize(expected, test_case, options = {})
        @options = options
        super expected, test_case
      end

      def matches?(model)
        RR.reset
        @receiver = model
        args = @options[:scope] ? RR.satisfy {|args| args.first =~ /.#{@options[:scope]} (=|IS) \?/ } : RR.anything
        RR.mock(model.class).exists?.with(args).returns true
        !model.valid? && model.errors.invalid?(@expected)
        RR.verify
        true
      rescue RR::Errors::RRError => e
        false
      end

      def failure_message
        "Expected #{@receiver.class.name} to validate the uniqueness of #{@expected.inspect}" +
        (@options[:scope] ? " with scope #{@options[:scope].inspect}." : '.')
      end

      def negative_failure_message
        "Expected #{@receiver.class.name} not to validate the uniqueness of #{@expected.inspect}" +
        (@options[:scope] ? " with scope #{@options[:scope].inspect}." : '.')
      end
    end
  end
end