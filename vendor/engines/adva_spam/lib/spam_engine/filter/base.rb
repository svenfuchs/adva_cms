module SpamEngine
  module Filter
    class Base
      attr_accessor :options

      def initialize(options = {})
        @options = options
      end

      def options
        @options || {}
      end

      def name
        self.class.name.demodulize
      end

      def priority
        name == 'Default' ? 0 : 1
      end

      def valid?(*args)
        raise "not implemented. implement #valid? in your filter class."
      end

      def check_comment(*args)
        raise "not implemented. implement #check_comment in your filter class."
      end

      def mark_as_ham(*args)
        raise "not implemented. implement #mark_as_ham in your filter class."
      end

      def mark_as_spam(*args)
        raise "not implemented. implement #mark_as_spam in your filter class."
      end

      def respond_to?(method)
        return true if options.has_key?(method)
        super
      end

      def method_missing(method, *args)
        return options[method] if options.has_key?(method)
        raise NotConfigured if [:key, :url].include? method
        super
      end
    end
  end
end