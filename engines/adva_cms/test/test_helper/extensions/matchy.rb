module Matchy
  module Expectations
    class Base
      # overwritten to take options, too
      def initialize(expected, test_case, options = {})
        @expected = expected
        @test_case = test_case
        @options = options
      end
    end

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

      def be_instance_of(expected)
        Matchy::Expectations::BeInstanceOf.new(expected, self)
      end

      # def be_kind_of(expected)
      #   Matchy::Expectations::BeKindOf.new(expected, self)
      # end

      def be_empty
        Matchy::Expectations::BeEmpty.new(nil, self)
      end

      def be_blank
        Matchy::Expectations::BeBlank.new(nil, self)
      end

      def be_valid
        Matchy::Expectations::BeValid.new(nil, self)
      end

      def be_file
        Matchy::Expectations::BeFile.new(nil, self)
      end

      def be_directory
        Matchy::Expectations::BeDirectory.new(nil, self)
      end

      def have_tracking_enabled
        Matchy::Expectations::HaveTrackingEnabled.new(nil, self)
      end

      # def respond_to(expected)
      #   Matchy::Expectations::RespondTo.new(expected, self)
      # end

      def validate_presence_of(attribute, options = {})
        Matchy::Expectations::ValidatePresenceOf.new(attribute, self, options)
      end

      def validate_uniqueness_of(attribute, options = {})
        Matchy::Expectations::ValidateUniquenessOf.new(attribute, self, options)
      end

      def validate_length_of(attribute, options = {})
        Matchy::Expectations::ValidateLengthOf.new(attribute, self, options)
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

      def have_tag(*args, &block)
        Matchy::Expectations::AssertSelect.new(:assert_select, self, *args, &block)
      end

      def be_child_of(parent)
        Matchy::Expectations::BeChildOf.new(parent, self)
      end

      def be_a(klass)
        Matchy::Expectations::BeA.new(klass, self)
      end
      alias be_an be_a

      def be_frozen
        Matchy::Expectations::BeFrozen.new(nil, self)
      end

      def be_new_record
        Matchy::Expectations::BeNewRecord.new(nil, self)
      end
    end

    class << self
      def matcher(name, failure_message, negative_failure_message, &block)
        matcher = Class.new(Base) do
          define_method :matches?, &block

          define_method :failure_message do
            failure_message % [@receiver.inspect, @expected.inspect, @options.inspect]
          end

          define_method :negative_failure_message do
            negative_failure_message % [@receiver.inspect, @expected.inspect, @options.inspect]
          end
        end
        const_set(name, matcher)
      end
    end

    matcher "Be",
            "Expected %s to be %s.",
            "Expected %s not to be %s." do |receiver|
      @receiver = receiver
      @expected.class === receiver
    end

    matcher "BeInstanceOf",
            "Expected %s to be an instance of %s.",
            "Expected %s not to be an instance of %s." do |receiver|
      @receiver = receiver
      receiver.instance_of? @expected
    end

    # matcher "BeKindOf",
    #         "Expected %s to be a kind of %s.",
    #         "Expected %s not to be a kind of %s." do |receiver|
    #   @receiver = receiver
    #   receiver.kind_of? @expected
    # end

    matcher "BeEmpty",
            "Expected %s to be empty.",
            "Expected %s not to be empty." do |receiver|
      @receiver = receiver
      receiver.empty?
    end

    matcher "BeBlank",
            "Expected %s to be blank.",
            "Expected %s not to be blank." do |receiver|
      @receiver = receiver
      receiver.blank?
    end

    matcher "BeValid",
            "Expected %s to be valid.",
            "Expected %s not to be valid." do |receiver|
      @receiver = receiver
      receiver.valid?
    end

    matcher "BeFile",
            "Expected the file %s to exist.",
            "Expected the file %s not to exist." do |receiver|
      @receiver = receiver
      File.file?(receiver)
    end

    matcher "BeDirectory",
            "Expected the directory %s to exist.",
            "Expected the directory %s not to exist." do |receiver|
      @receiver = receiver
      File.directory?(receiver)
    end

    matcher "HaveTrackingEnabled",
            "Expected %s to have tracking enabled.",
            "Expected %s to not have tracking enabled." do |receiver|
      @receiver = receiver
      receiver.tracking_enabled?
    end

    # matcher "RespondTo",
    #         "Expected %s to respond to %s.",
    #         "Expected %s not to respond to %s." do |receiver|
    #   @receiver = receiver
    #   receiver.respond_to? @expected
    # end

    matcher "ValidatePresenceOf",
            "Expected %s to validate the presence of %s.",
            "Expected %s not to validate the presence of %s." do |receiver|
      receiver = receiver.new if receiver.is_a?(Class)
      @receiver = receiver

      # stubs the method given as @options[:if] on the receiver
      RR.stub(receiver).__creator__.create(@options[:if]).returns(true) if @options[:if]

      receiver.send("#{@expected}=", nil)
      !receiver.valid? && receiver.errors.invalid?(@expected)
    end

    matcher "ValidateLengthOf",
            "Expected %s to validate the length of %s (with %s).",
            "Expected %s not to validate the length of %s (with %s)." do |receiver|
      receiver = receiver.new if receiver.is_a?(Class)
      @receiver = receiver

      max = @options[:within] || @options[:is]
      max = max.last if max.respond_to?(:last)

      value = receiver.send(@expected).to_s
      value = 'x' if value.blank?
      value = (value * (max  + 1))[0, max + 1]

      receiver.send("#{@expected}=", value)
      !receiver.valid? && receiver.errors.invalid?(@expected)
    end


    matcher "BeChildOf",
            "Expected %s to be a child of %s.",
            "Expected %s not to be a child of %s." do |receiver|
      @receiver = receiver
      @receiver.parent == @expected
    end

    matcher "BeA",
            "Expected %s to be a(n) %s.",
            "Expected %s not to be a(n) %s." do |receiver|
      @receiver = receiver
      @receiver.is_a?(@expected)
    end

    matcher "BeFrozen",
            "Expected %s to be frozen.",
            "Expected %s not to be frozen." do |receiver|
      @receiver = receiver
      @receiver.frozen?
    end

    matcher "BeNewRecord",
            "Expected %s to be a new record.",
            "Expected %s not to be a new record." do |receiver|
      @receiver = receiver
      @receiver.new_record?
    end

    class ValidateUniquenessOf < Base
      def matches?(model)
        RR.reset
        @receiver = model
        scopes = Array(@options[:scope])
        args = !scopes.empty? ? RR.satisfy { |args| scopes.each { |scope| args.first =~ /.#{scope} (=|IS) \?/ } } : RR.anything

        class_hierarchy = [model.class]
        while class_hierarchy.first != ActiveRecord::Base
          class_hierarchy.unshift(class_hierarchy.first.superclass)
        end
        finder_class = class_hierarchy.detect { |klass| !klass.abstract_class? }

        RR.mock(finder_class).exists?.with(args).returns true
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

      class AssertSelect < Base
        def initialize(assertion, test_case, *args, &block)
          super nil, test_case
          @assertion = assertion
          @args = args
          @block = block
        end

        def matches?(response_or_text, &block)
          if ActionController::TestResponse === response_or_text and
                   response_or_text.headers.key?('Content-Type') and
                   !response_or_text.headers['Content-Type'].blank? and
                   response_or_text.headers['Content-Type'].to_sym == :xml
            @args.unshift(HTML::Document.new(response_or_text.body, false, true).root)
          elsif String === response_or_text
            @args.unshift(HTML::Document.new(response_or_text).root)
          end
          @block = block if block
          begin
            @test_case.send(@assertion, *@args, &@block)
          rescue ::Test::Unit::AssertionFailedError => @error
          end

          @error.nil?
        end

        def failure_message; @error.message; end
        def negative_failure_message; "should not #{description}, but did"; end

        def description
          case @assertion
            when :assert_select       then "have tag#{format_args(*@args)}"
            when :assert_select_email then "send email#{format_args(*@args)}"
          end
        end

        protected
          def format_args(*args)
            return "" if args.empty?
            return "(#{arg_list(*args)})"
          end

          def arg_list(*args)
            args.collect do |arg|
              arg.respond_to?(:description) ? arg.description : arg.inspect
            end.join(", ")
          end
      end
  end
end
