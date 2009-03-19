module HasFilter
  module Filter
  	class Text < Base
  	  self.priority = 1
  		self.scopes = [:contains, :starts_with, :ends_with, :is]
		
  		class << self
  		  def build(args)
  	      Array(args[:attributes]).map { |attribute| new(:attribute => attribute) }
  	    end
  	  end
	    
	    def matches?(name)
	      attribute == name
      end
		  
		  def selected?
        set.selected?(attribute)
	    end
  	  
  	  def to_field_set_tag(options = {})
  	    options[:id] = "filter_#{attribute}_#{set.index}"
  	    super
	    end
  		
  		def to_form_fields(options = {})
  		  [scopes_select_tag, query_input_tag]
  		end
		
  		def scope(target)
	      # FIXME assert that scope is contained in self.scopes
  	    scope, query = selected.values_at(:scope, :query)
  	    query.blank? ? target : target.send(scope, attribute, query)
  		end
  		
  		protected
  		
    		def filter_select_option
		      [I18n.t(attribute, :scope => :'has_filter.filters', :default => attribute.to_s.gsub('_', ' ')), attribute]
  	    end

  		  def scopes_select_tag
  		    options = self.class.scopes.map do |scope| 
  		      [I18n.t(scope, :scope => :'has_filter.scopes', :default => scope.to_s.gsub('_', ' ')), scope]
		      end
  		    options = "\n" + view.options_for_select(options, selected[:scope].try(:to_sym)) + "\n"
  		    view.select_tag(form_field_name(attribute, :scope), options, :id => form_field_id(attribute, :scope))
		    end
  		
  		  def query_input_tag
  		    view.text_field_tag(form_field_name(attribute, :query), selected[:query], :id => form_field_id(attribute, :query))
		    end
  	end
	end
end