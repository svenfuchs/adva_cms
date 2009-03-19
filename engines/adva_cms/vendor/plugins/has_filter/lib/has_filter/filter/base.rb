module HasFilter
  module Filter
  	class Base
  		class_inheritable_accessor :scopes, :priority
		  attr_accessor :set, :options
		  delegate :view, :to => :set
  		
  		class << self
  		  def build(*args)
  	      [new(*args)]
  	    end
  	  end
  		
  		def initialize(options = {})
  			@options = options
  		end
  	  
  	  def attribute
  	    @options[:attribute] if @options
	    end
	    
	    def matches?(name)
	      type == name
      end
  		
  		def select(selected)
  		  @selected = selected
		  end
		  
		  def selected
		    @selected ||= {}
	    end
		  
		  def selected?
        set.selected?(type)
	    end
		
  		def type
  		  @type ||= self.class.name.demodulize.underscore.to_sym
  	  end
	    
	    def to_field_set_tag(options = {})
        view.capture do
    		  options.reverse_merge! :id => "filter_#{type}_#{set.index}", :class => "filter filter_#{attribute || type}"
  	      options[:class] += ' selected' if selected?
          view.field_set_tag(nil, options.slice(:id, :class, :label)) do
            to_form_fields(options).join("\n")
          end
        end
      end
  	  
  	  protected
  	    
    		def filter_select_option
		      [I18n.t(type, :scope => :'has_filter.filters', :default => type.to_s.gsub('_', ' ')), type]
  	    end

    		def form_field_name(*keys)
    		  "filters[]" + keys.map { |key| "[#{key}]" }.join
  		  end
		  
  		  def form_field_id(*keys)
    		  "filter" + keys.map { |key| "_#{key}" }.join + "_#{set.index}"
  	    end
  	end
	end
end