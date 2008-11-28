module ActionController
  module EventHelper
    def trigger_events(object, *changes)
      options = changes.extract_options!
      changes += object.state_changes
      changes.uniq.each do |change|
        trigger_event(object, change, options)
      end
    end
    
    def trigger_event(object, change = nil, options = {})
      type = :"#{object.class.name.underscore}_#{change}"
      Event.trigger type, object, self, options
    end
  end
end

ActionController::Base.send :include, ActionController::EventHelper
