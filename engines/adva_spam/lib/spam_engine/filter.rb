module SpamEngine
  module Filter
    @@filters = []
    @@default_filters = []

    class << self
      def register_default(klass)
        @@default_filters << klass.name unless @@default_filters.include?(klass.name)
      end

      def register(klass)
        @@filters << klass.name unless @@filters.include?(klass.name)
      end
      
      def filters
        @@filters = @@default_filters if @@filters.empty?
        @@filters
      end
      
      def filters=(filters)
        @@filters = filters
      end

      def names
        filters.map &:demodulize
      end

      def create(type, options)
        "SpamEngine::Filter::#{type.to_s.classify}".constantize.new options
      end
    end
  end
end