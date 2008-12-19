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
    
    def it_guards_permissions(action, type)
      with :admin_may_edit_articles do
        # it_requires_login :with => [:is_anonymous]
        it_denies_access  :with => [:is_user]
        # it_grants_access  :with => [:is_admin]
        # it_denies_access :with => [:is_anonymous, :is_user]
        # it_denies_access, :with => [:is_anonymous, :is_user, :is_moderator]
      end
      # 
      # with :moderators_may_edit_articles do
      #   it_grants_access, :with => [:is_moderator, :is_admin]
      #   it_denies_access, :with => [:is_anonymous, :is_user]
      # end
    end

    def it_grants_access(options = {})
      group = options[:with] ? with(*options[:with]) : self
      group.expect do
        do_not_allow(@controller).rescue_action(is_a(ActionController::RoleRequired))
      end
      group.it "grants access" do end
    end

    def it_denies_access(options = {})
      group = options[:with] ? with(*options[:with]) : self
      group.expect do
        mock.proxy(@controller).rescue_action.with_any_args #(is_a(ActionController::RoleRequired))
      end
      group.it "denies access" do end
    end

    def it_requires_login(options = {})
      group = options[:with] ? with(*options[:with]) : self
      group.assertion do
        assert_redirected_to login_path(:return_to => @request.url)
      end
      group.it "requires login" do end
    end
    
    def it_sweeps_page_cache(options)
      options = options.dup
      sweeper = options.delete :sweeper
      
      expect do
        options.each do |type, name|
          record = instance_variable_get("@#{name}")
          # TODO how to make this less brittle?
          sweeper ||= "#{record.class.name}Sweeper".constantize.instance
          case type
          when :by_reference
            mock.proxy(sweeper).expire_cached_pages_by_reference(record)
          end
        end
      end
    end
    
    def it_does_not_sweep_page_cache
      expect do
        do_not_allow(@controller).expire_pages.with_any_args
      end
    end
  end
end

class ActionController::TestCase
end