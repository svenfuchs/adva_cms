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

      # FIXME not sure what this is good for. the priority of the default filter is 
      # always 0. the priority of other filters always 1?
      def priority
        name == 'Default' ? 0 : 1
      end
      
      # FIXME doesn't seem to be used ...
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