module HasFilter
  module Filter
  	class Text < Base
  		self.scopes = [:contains, :does_not_contain, :starts_with, :ends_with, :is, :is_not]
		
  		def to_form_fields
  		  [scope_tag, query_tag]
  		end
		
  		def scope(target, params)
  		  params.each do |attribute, scopes|
  		    scopes.each do |scope|
  		      scope, query = scope.values_at(:scope, :query)
  		      # FIXME assert that scope is contained in self.scopes
  		      target = target.send(scope, attribute, query)
		      end
		    end
		    target
  		end
  		
  		protected
  		
  		  def scope_tag
  		    name = form_field_name(:text, attribute, :scope)
  		    id = form_field_id(:text, attribute, :scope)
  		    select_tag(name, options_for_scope_select, :id => id)
		    end
  		
  		  def query_tag
  		    name = form_field_name(:text, attribute, :query)
  		    id = form_field_id(:text, attribute, :query)
  		    text_field_tag(name, nil, :id => id)
		    end
  	end
	end
end