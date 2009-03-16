module HasFilter
  module Filter
  	class Base
  	  include ActionView::Helpers::TagHelper
  	  include ActionView::Helpers::FormTagHelper
  	  include ActionView::Helpers::FormOptionsHelper

  		class_inheritable_accessor :scopes
		  attr_accessor :model, :attribute, :options

  		def initialize(attribute = nil, options = {})
  			@attribute = attribute
  			@options = options
  		end
		
  		def type
  		  @type ||= self.class.name.demodulize.underscore.to_sym
  	  end
  	  
  	  protected
  		
    		def form_field_name(type, attribute = nil, key = nil)
    		  "filters[#{type}]" + (attribute ? "[#{attribute}]" : '') + "[]" + (key ? "[#{key}]" : '')
  		  end
		  
  		  def form_field_id(type, attribute = nil, key = nil)
  		    "filter_#{type}" + (attribute ? "_#{attribute}" : '') + (key ? "_#{key}" : '')
  	    end
  		
  		  def options_for_scope_select
  		    options = self.class.scopes.map do |scope| 
  		      [I18n.t(scope, :scope => :'has_filter.scopes', :default => scope.to_s.gsub('_', ' ')), scope]
		      end
  		    "\n" + options_for_select(options) + "\n"
		    end
  	end
	end
end