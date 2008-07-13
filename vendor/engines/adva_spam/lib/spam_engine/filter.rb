module SpamEngine
  module Filter  
    mattr_accessor :filters
    @@filters = []

    class << self
      def register(klass)
        @@filters << klass.name
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