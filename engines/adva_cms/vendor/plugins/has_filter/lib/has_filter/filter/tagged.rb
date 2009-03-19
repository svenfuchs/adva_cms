module HasFilter
  module Filter
  	class Tagged < Base
  	  self.priority = 2
  		self.scopes = [:tagged]
		
  		def to_form_fields(options = {})
  		  [query_tag]
  		end
		
  		def scope(target)
  		  target.tagged(selected)
  		end
		
  		protected
  		
  		  def query_tag
  		    view.text_field_tag(form_field_name(:tagged), selected, :id => form_field_id(:tagged, :query))
		    end
  	end
	end
end