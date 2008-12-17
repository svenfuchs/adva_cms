module With
  class Group
    def it_triggers_event(type)
      expect do
        record = satisfy{|arg| type.to_s =~ /#{arg.class.name.underscore}/ }
        controller = is_a(ActionController::Base)
        options = is_a(Hash)
        mock.proxy(Event).trigger(type, record, controller, options)
      end
    end
  
    def it_does_not_trigger_any_event
      expect do
        do_not_allow(Event).trigger.with_any_args
      end
    end
  end
end