module With
  class Context
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

    # FIXME might need to refactor this so it always executes the block
    # (i.e. return after witch(:access_granted, &block))
    def it_guards_permissions(action, type, &block)
      return (block ? block.call : nil) unless With.aspect?(:access_control)

      with(:access_granted, &block) if block_given?
      
      with "(rbac)" do
        # before do
        #   @default_permission = Rbac::Context.default_permissions[:"#{action} #{type}"]
        # end
        # 
        # after do
        #   Rbac::Context.default_permissions[:"#{action} #{type}"] = @default_permission
        # end

        with "superuser_may_#{action}_#{type}" do
          before do
            Rbac::Context.default_permissions[:"#{action} #{type}"] = [:superuser]
          end

          it_denies_access :with => [:is_anonymous, :is_user, :is_moderator, :is_admin]
          it_grants_access :with => [:is_superuser]
        end

        with "admin_may_#{action}_#{type}" do
          before do
            Rbac::Context.default_permissions[:"#{action} #{type}"] = [:admin]
          end

          it_denies_access :with => [:is_anonymous, :is_user, :is_moderator]
          it_grants_access :with => [:is_admin, :is_superuser]
        end

        with "moderator_may_#{action}_#{type}" do
          before do
            Rbac::Context.default_permissions[:"#{action} #{type}"] = [:moderator]
          end

          it_denies_access :with => [:is_anonymous, :is_user]
          it_grants_access :with => [:is_admin, :is_superuser] 
          # FIXME should grant to :is_moderator, but currently require_authentication requires an :admin role
        end
      end
    end

    def it_grants_access(options = {})
      contexts = options[:with] ? with(options[:with]) : [self]
      contexts.each do |context|
        context.assertion "it grants access" do
          message = "expected to grant access but %s"
          assert !rendered_insufficient_permissions?, message % 'rendered :insufficient_permissions'
          assert !redirected_to_login?, message % 'redirected to login_path'
        end
      end
    end

    def it_denies_access(options = {})
      contexts = options[:with] ? with(options[:with]) : [self]
      contexts.each do |context|
        context.assertion "it denies access" do
          message = "expected to render :insufficient_permissions or redirect to login_path but did neither of these."
          assert rendered_insufficient_permissions? || redirected_to_login?, message
        end
      end
    end

    def it_caches_the_page_with_tracking(options = {})
      it_caches_the_page_without_tracking(options)
      
      return unless options[:track]
      assertion "it tracks cache references #{Array(options[:track]).map(&:inspect).join(' ')}" do
        Array(options[:track]).each do |expected|
          actual = @controller.class.track_options[@controller.action_name.to_sym]
          actual.should include(expected)
        end
      end
    end
    alias_method_chain :it_caches_the_page, :tracking
    
    def it_sweeps_page_cache(options)
      options = options.dup
      
      expect do
        options.each do |type, record|
          record = instance_variable_get("@#{record}")
          filters = @controller.class.filter_chain
          sweeper = filters.detect { |f| f.method.is_a?(CacheReferences::Sweeper) } 
          sweeper or raise "can not find page cache sweeper on #{@controller.class.name}"
          sweeper = sweeper.method
          
          case type
          when :by_site
            # FIXME ... why are they sometimes called multiple times?? (e.g. CommentsController#create)
            mock.proxy(sweeper).expire_cached_pages_by_site(record).any_number_of_times
          when :by_section
            mock.proxy(sweeper).expire_cached_pages_by_section(record).any_number_of_times
          when :by_reference
            mock.proxy(sweeper).expire_cached_pages_by_reference(record).any_number_of_times
          end
        end
      end
    end
    
    def it_does_not_sweep_page_cache
      expect do
        do_not_allow(@controller).expire_pages.with_any_args
      end
    end

    def it_rewrites(from, options)
      with *options[:with] || 'non-root section and non-default locale' do
        it "rewrites #{from} to: #{options[:to]}" do
          instance_eval(&from).should == options[:to]
        end
      end
    end
  end
end

class ActiveSupport::TestCase
  def has_authorized_tag(*args)
    @response.body.should have_authorized_tag(*args)
  end
  
  def has_permalink(article)
    has_tag 'h2 a[href=?]', blog_article_path(article.section, article.full_permalink), article.title
  end
  
  def without_routing_filters
    old_routing_filter_active, RoutingFilter.active = RoutingFilter.active, false
    yield
    RoutingFilter.active = old_routing_filter_active
  end
end

class ActionController::TestCase
  def default_theme?
    @controller.site.themes.active.empty?
  end
  
  def rendered_insufficient_permissions?
    !!(@response.rendered.to_s =~ /insufficient_permissions/)
  end
  
  def redirected_to_login?
    @response.redirect_url_match?(/#{login_path}/)
  end
end