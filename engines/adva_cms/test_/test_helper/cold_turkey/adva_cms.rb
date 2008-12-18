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
    
    def it_sweeps_page_cache(options)
      expect do
        old_perform_caching, @controller.perform_caching = @controller.perform_caching, true
        
        options.each do |type, name|
          record = instance_variable_get("@#{name}")
          # TODO how to make this less brittle?
          sweeper = "#{record.class.name}Sweeper".constantize.instance
          case type
          when :by_reference
            mock.proxy(sweeper).expire_cached_pages_by_reference(record)
          end
        end
        
        # @controller.perform_caching = old_perform_caching
      end
    end
  end
end