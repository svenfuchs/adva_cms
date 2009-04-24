module SpamEngine
  class FilterChain < Array
    class << self
      def assemble(options)
        filters = (options[:filters] || []).map(&:to_s).map(&:downcase).map(&:to_sym)
        filters.unshift :default
        filters.uniq!
        filters.map!{|filter| SpamEngine::Filter.create(filter, options[filter]) if filters.include? filter }
        self.new filters
      end
    end

    def initialize(filters)
      super
      sort_by_priority!
    end

    def check_comment(comment, context = {})
      run :check_comment, comment, context
    end
    
    def mark_spaminess(spaminess, comment, context = {})
      run :"mark_as_#{spaminess}", comment, context
    end

    protected

      def run(method, *args)
        each {|filter| return unless filter.send(method, *args)}
      end

      def sort_by_priority!
        self.sort!{|left, right| left.priority <=> right.priority }
      end
  end
end