module ActionController
  module EventHelper
    def trigger_event_if_valid(object, action = nil)
      return unless object.valid?
      trigger_event(object, action = nil)
    end
    
    def trigger_event(object, action = nil)
      action ||= guess_event_action(object)
      type = :"#{object.class.name.underscore}_#{action}"
      Event.trigger type, object, self
    end
    
    def guess_event_action(object)
      if object.new_record?
        :created
      elsif object.frozen?
        :deleted
      else
        :updated
      # else
      #   raise "could not determine event action for #{object.inspect}"
      end
    end
  end
end

ActionController::Base.send :include, ActionController::EventHelper