module HasFilter
  module Filter
  	class State < Base
  		self.scopes = [:state]

  		def to_form_fields
  			options[:states].map { |state| state_tag(state) }
  		end
		
  		def scope(target, params)
	      # FIXME assert that state is a valid state!
  		  params.each { |state| target = target.send(state) }
		    target
  		end
		
  		protected
  		
  		  def state_tag(state)
  		    check_box_tag(form_field_name(:state), state, false, :id => form_field_id(:state))
		    end
  	end
	end
end