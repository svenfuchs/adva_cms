# A filter chain is a collection of filter sets. A filter set hold individual 
# filters of which only one can be active/selected at a time.

module HasFilter
  module Filter
    class Chain < Array
      class << self
        def build(owner, *args)
          new owner, Set.build(*args)
        end
      end
      
      attr_reader :owner, :view
      
      def initialize(owner, *sets)
        @owner = owner
        concat sets.each { |set| set.chain = self }
      end
      
      def select(params)
        params ||= []
        adjust_size(params)
        each { |set| set.select(params[set.index]) }
        self
      end
      
      def scope(target = nil)
        inject(target || owner) { |target, set| set.scope(target) }
      end
		  
  		def to_form_fields(view, options = {})
  		  @view = view
        map { |set| set.to_field_set_tag(options) }
  		end
  		
  		protected
  		  
  		  def adjust_size(params)
  		    size = [params.size, 1].max
  		    replace (1..size).map { first.dup }
  		    each_with_index { |set, index| set.index = index }
        end
    end
  end
end