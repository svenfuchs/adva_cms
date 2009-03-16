module HasFilter
  module Filter
    class Chain < Array
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::CaptureHelper

      def scope(target, params)
        params.each do |type, params|
          filter = find_filter(type)
          target = filter.scope(target, params) if filter
        end
		    target
      end
    
      def find_filter(type)
        detect { |filter| filter.type == type }
      end
		  
		  attr_accessor :output_buffer
  		def to_form_fields
  		  @output_buffer = ''
        field_set_tag :class => 'filters' do
          filter_select_tag + "\n" + map do |filter| 
    		    field_set_tag(field_set_options(filter)) { filter.to_form_fields.join("\n") }
    		  end.join("\n")
  		  end
  		end
  		
  		protected
  		
    		def filter_select_tag
  		    options = map(&:type).map do |type| 
  		      [I18n.t(type, :scope => :'has_filter.filters', :default => type.to_s.gsub('_', ' ')), type]
  	      end
  		    select_tag :selected_filter, "\n" + options_for_select(options) + "\n"
  	    end
  		
    		def field_set_tag(options = {}, &block)
    		  options = options.map { |key, value| %( #{key}="#{value}") }
    		  "<fieldset#{options}>\n#{block.call}\n</fieldset>"
  		  end
		  
  		  def field_set_options(filter)
  		    { :id => "filter_#{filter.type}", :class => 'filter' + (filter == first ? ' first' : '') }
  	    end
    end
  end
end