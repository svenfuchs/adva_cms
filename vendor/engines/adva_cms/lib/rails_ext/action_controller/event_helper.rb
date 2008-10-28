module ActionController
  module EventHelper
    def trigger_events(object, *changes)
      changes += object.state_changes
      changes.uniq.each do |change|
        trigger_event(object, change)
      end
    end
    
    def trigger_event(object, change = nil)
      type = :"#{object.class.name.underscore}_#{change}"
      Event.trigger type, object, self
    end
  end
end

ActionController::Base.send :include, ActionController::EventHelper