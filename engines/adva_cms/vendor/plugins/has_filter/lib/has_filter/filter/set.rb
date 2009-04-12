module HasFilter
  module Filter
    class Set < Array
      attr_accessor :chain, :index, :selected
      delegate :view, :to => :chain
      
      class << self
        def build(filters)
          new filters.map { |filter|
            case filter
            when Hash
              filter.map { |type, args| Filter.build(type, args) }
            when Symbol
              Filter.build(filter)
            end
          }.flatten
        end
      end
      
      def initialize(filters)
        concat filters.each { |f| f.set = self }
        sort!
      end
  	  
  	  def initialize_copy(orig)
  	    super
  	    replace orig.map { |f| f.dup }.each { |f| f.set = self }
	    end
  		
  		def sort!
        head = self.reject { |f| !f.is_a?(Text) }
        replace head + (self - head).sort { |a, b| a.priority <=> b.priority }
		  end
	    
      def select(params)
        params ||= { :selected => first.attribute || first.type }
        @selected = params[:selected].to_sym
        find_filter(selected).select(params[selected]) if @selected
      end
      
      def selected?(name)
        selected == name
      end
      
      def first?
        index == 0
      end

      def scope(target)
        selected ? find_filter(selected).scope(target) : target
      end
		  
  		def to_field_set_tag(options = {})
        view.capture do
          view.field_set_tag(nil, :class => 'set') do
            tag = filter_select_tag(view) + "\n"
            tag << map { |filter| filter.to_field_set_tag(options.dup) }.join("\n")
            tag << view.content_tag(:span, :class => 'controls') do
              view.content_tag(:a, '+', :href => '#', :class => 'filter_add') + 
              view.content_tag(:a, '-', :href => '#', :class => 'filter_remove')
            end
            tag
    		  end
  		  end
  		end
  		
  		protected
    
        def find_filter(type)
          # FIXME ask the filter instead: filter.matches?(type) or something
          detect { |filter| filter.matches?(type) }
        end
  		
    		def filter_select_tag(view)
  	      options = view.options_for_select(map(&:filter_select_option), selected)
  		    view.select_tag :'filters[][selected]', options, :id => "selected_filter_#{index}", :class => 'selected_filter'
  	    end
    end
  end
end