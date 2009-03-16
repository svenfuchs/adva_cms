module HasFilter
  module Filter
  	class Tags < Base
  		self.scopes = [:tags]
		
  		def to_form_fields
  		  [query_tag]
  		end
		
  		def scope(target, params)
  		  params.each { |tags| target = target.contains_all_of(:tag_list, tags.split(' ')) }
		    target
  		end
		
  		protected
  		
  		  def query_tag
  		    text_field_tag(form_field_name(:tags, nil, :query), nil, :id => form_field_id(:tags, nil, :query))
		    end
  	end
	end
end