module HasFilter
  module Filter
  	class Categorized < Base
  	  self.priority = 4
  		self.scopes = [:categories]
		
  		def to_form_fields(options = {})
  		  options[:categories].blank? ? [] : [categories_select_tag(options)]
  		end
		
  		def scope(target)
  		  target.categorized(*selected)
  		end
		
  		protected
  		
  		  def categories_select_tag(options = {})
  		    categories = options[:categories].map { |c| [c.title, c.id] }
  		    options = view.options_for_select(categories, selected)
  		    view.select_tag(form_field_name(:categorized, nil), options, :id => form_field_id(:categorized, :id))
		    end
  	end
	end
end