module SpamEngine
  class FilterChain < Array
    class << self
      def assemble(options)
        self.new options.map{|type, filter| SpamEngine::Filter.create(type, filter) }
      end
    end
    
    def initialize(filters)
      super 
      sort_by_priority!
    end
    
    def check_comment(comment, context = {}) 
      run :check_comment, comment, context
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