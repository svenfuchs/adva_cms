module SpecControllerHelper  
  class << self
    def included(base)
      base.send :include, CacheableFlash::TestHelpers
      base.send :include, Stubby
      base.send :include, ResourcePathHelper
      base.send :include, SpecPageCachingHelper
      
      base.send :before do RoutingFilter.active = false end
    end
  end
  
  def should_recognize_path(path, expected, method = :get)
    result = params_from(method, path, {:host_with_port => 'test.host'})
    result.delete(:path_prefix)
    result.delete(:method)
    result.delete(:locale)
    result.should == expected
  end
  
  def should_rewrite_path(from, to)
    ActionController::Routing::Routes.should_receive(:recognize_path_without_categories).with(to, {:method => :get, :host_with_port => 'test.host'})
    params_from(:get, from, {:host_with_port => 'test.host'})
  end
    
  def should_render(template, method, path, options = {})
    request_to method, path, options
    response.should render_template(template)
  end

  def should_successfully_request(method, path, options = {})
    request_to(method, path, options)
    response.should be_success
  end

  def request_to(method, path, options = {})
    path = path.dup
    params = params_from(method, path.clone, {:host_with_port => 'test.host'}).update(options)
    send(method, params[:action], params)
  end 

  def cache_page_filters
    controller.class.filter_chain.select do |filter|
      filter.is_a?(ActionController::Filters::AfterFilter) && 
      filter.method.is_a?(Proc) &&
      filter.method.to_ruby =~ /c.cache_page/
    end
  end
  
  def cached_page_filter_for(action)
    filters = cache_page_filters.select do |filter|
      filter.options[:only] && filter.options[:only].include?(action)
    end
    puts "warning - multiple caches_page filters for #{action}" if filters.size > 1
    filters.first
  end
end

Spec::Rails::Example::ControllerExampleGroup.class_eval do
  class << self
    def with_routing_filter
      before do RoutingFilter.active = true end
      after do RoutingFilter.active = false end
    end    
    
    def it_gets_page_cached
      it "page_caches the response" do
        with_caching{ act! }.should be_cached
      end      
    end    
    
    def it_guards_permissions(*args)
      it "guards permissions #{args.inspect}" do
        controller.should_receive(:has_permission?).with(*args).and_return true
        act!
      end      
    end    
    
    def maps_to_index(path, options = {})
      maps_to_action(path, :index, options)
    end
    
    def maps_to_show(path, options = {})
      maps_to_action(path, :show, options)
    end
    
    def maps_to_action(path, action, options = {})
      method = options.delete(:method) || :get

      it_maps method, path, action, options
      it_maps method, "#{path}/", action, options unless path == '/' || path =~ /\.\w+$/
    end 
    
    def it_maps(method, path, action, options = {})
      options = options.dup
      path = "#{options.delete(:path_prefix)}#{path}"
      ignore = Array(options.delete(:ignore) || []) + [:controller, :method, :path_prefix, :name_prefix]     

      it "maps #{method.to_s.upcase} to #{path} to :#{action} with #{options.keys.map(&:to_s).to_sentence} set" do
        result = params_from method, path, {:host_with_port => 'test.host'}
        result.slice! *(result.keys - ignore)
        result.should == options.merge(:action => action.to_s)
      end      
    end   
    
    def rewrites_url(url, options)
      section, path, conditions = options.values_at(:section, :to, :on)
      conditions = Array(conditions)
      condition_message = conditions.empty? ? 'no conditions' : "conditions #{conditions.map(&:inspect).to_sentence}"

      describe "with #{condition_message}" do
        before :each do
          unless conditions.include? :root_section
            @site.sections.stub!(:root).and_return stub_section.dup
            @site.sections.root.stub!(:id).and_return 2
          end
          
          locale = conditions.include?(:default_locale) ? 'en' : 'de'
          @controller.instance_variable_set(:@locale, locale)
    
          # @current_section.should_receive(:root_section?).and_return(is_root)
        end
      
        it "generates the path #{path}" do
          instance_eval(&url).should == path
        end
      end
    end
  end
end

