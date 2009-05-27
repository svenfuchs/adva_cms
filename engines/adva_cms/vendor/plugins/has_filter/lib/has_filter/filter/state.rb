module HasFilter
  module Filter
  	class State < Base
  	  self.priority = 3
  		self.scopes = [:state]

  		def to_form_fields(options = {})
  			@options[:states].map { |state| state_tag(state) }
  		end

  		def scope(target)
	      # FIXME assert that state is a valid state!
  		  selected.inject(target) { |target, state| target.send(state) }
  		end

  		protected

  		  def state_tag(state)
  		    id = form_field_id(:state, state)
  		    view.check_box_tag(form_field_name(:state, nil), state, selected.include?(state), :id => id) +
  		    view.label_tag(id, I18n.t(state, :scope => :'has_filter.states', :default => state.to_s))
		    end
  	end
	end
end