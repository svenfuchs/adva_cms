module Stubby
  class Handle < Proc  
    def initialize(&block)
      super &block
    end
        
    def resolve      
      result = call
      result = result.resolve if result.respond_to? :resolve
      result
    end
      
    def inspect
      "<Stubby::Handle:#{__id__}>"
    end
  end    
end