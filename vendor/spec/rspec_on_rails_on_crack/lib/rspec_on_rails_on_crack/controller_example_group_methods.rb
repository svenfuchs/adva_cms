module Spec::Extensions::Main
  def describe_access_for(controller, &block)
    RspecOnRailsOnCrack::ControllerAccessProxy.new(self, controller).instance_eval(&block)
  end
end

module RspecOnRailsOnCrack
  class ControllerAccessProxy
    def initialize(example_group, controller)
      @example_group, @controller = example_group, controller
      @blocks  = []
      @filters = []
    end
    
    def as(*users, &block)
      blocks, filters = @blocks, @filters
      users.each do |user|
        describe @controller, "access for #{user.inspect}", :type => :controller do
          ControllerAccessGroup.new(self, blocks, filters).instance_eval(&block)
          before do
            controller.stub!(:current_user).and_return(user == :anon ? :false : users(user))
          end
        end
      end
    end
    
    def skip_filters(*filters)
      @filters.push *filters
    end
    
    def all(&block)
      @blocks << block
    end

  protected
    def method_missing(m, *args, &block)
      args.unshift m
      args << block
      @methods << args
    end
  end
  
  class ControllerAccessGroup
    def initialize(example_group, blocks = [], filters = [])
      @example_group = example_group
      blocks.each do |b|
        @example_group.instance_eval &b
      end
      @example_group.before do
        filters.each { |f| controller.stub!(f) }
      end
    end
    
    def it_performs(description, method, actions, params = {}, &block)
      Array(actions).each do |action|
        param_desc = (params.respond_to?(:call) && params.respond_to?(:to_ruby)) ?
          params.to_ruby.gsub(/(^proc \{)|(\}$)/, '').strip :
          params.inspect
        it "#{description} #{method.to_s.upcase} #{action} #{param_desc}".strip do
          do_stubbed_action method, action, params.respond_to?(:call) ? instance_eval(&params) : params
          instance_eval &block
        end
      end
    end
    
    def it_allows(method, actions, params = {}, &block_params)
      it_performs :allows, method, actions, block_params || params do
        response.should be_success
      end
    end

    def it_restricts(method, actions, params = {}, &block_params)
      it_performs :restricts, method, actions, block_params || params do
        response.should redirect_to(new_session_path)
      end
    end

  protected
    def method_missing(m, *args, &block)
      @example_group.send(m, *args, &block)
    end
  end
  
  module ControllerExampleGroupMethods
    @@variable_types = {:headers => :to_s, :flash => nil, :session => nil, :flash_cookie => nil}

    def self.extended(base)
      base.send :include, InstanceMethods
    end
    
    module InstanceMethods
      def acting(&block)
        act!
        block.call(response) if block
        response
      end
      
      def act!
        instance_eval &self.class.acting_block
      end
      
      def do_stubbed_action(method, action, params = {})
        controller.stub!(action)
        send method, action, params
      end
      
    protected
      def asserts_content_type(type = :html)
        mime = Mime::Type.lookup_by_extension((type || :html).to_s)
        violated "Renders with Content-Type of #{mime}" unless response.content_type == mime
      end
      
      def asserts_status(status)
        case status
        when String, Fixnum
          code = ActionController::StatusCodes::STATUS_CODES[status.to_i]
          violated "Renders with status of #{response.code.inspect}" unless response.code == status.to_s
        when Symbol
          code_value = ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[status]
          code       = ActionController::StatusCodes::STATUS_CODES[code_value]
          violated "Renders with status of #{response.code.inspect}" unless response.code == code_value.to_s
        else
          violated "Is not successful" unless response.success?
        end
      end
    end

    def acting_block
      @acting_block || parent.acting_block
    end

    def act!(&block)
      @acting_block = block
    end

    # Checks that the action redirected:
    #
    #   it_redirects_to { foo_path(@foo) }
    # 
    # Provide a better hint than Proc#inspect
    #
    #   it_redirects_to("foo_path(@foo)") { foo_path(@foo) }
    #
    def it_redirects_to(hint = nil, &route)
      if hint.nil? && route.respond_to?(:to_ruby)
        hint = route.to_ruby.gsub(/(^proc \{)|(\}$)/, '').strip
      end
      it "redirects to #{(hint || route).inspect}" do
        acting.should redirect_to(instance_eval(&route))
      end
    end

    # Check that an instance variable was set to the instance variable of the same name 
    # in the Spec Example:
    #
    #   it_assigns :foo # => assigns[:foo].should == @foo
    #
    # If there is no instance variable @foo, it will just check to see if its not nil:
    #
    #   it_assigns :foo # => assigns[:foo].should_not be_nil (if @foo is not defined in spec)
    #
    # Check multiple instance variables
    # 
    #   it_assigns :foo, :bar
    #
    # Check the instance variable was set to something more specific
    #
    #   it_assigns :foo => 'bar'
    #
    # Check both instance variables:
    #
    #   it_assigns :foo, :bar => 'bar'
    #
    # Check the instance variable is not nil:
    #
    #   it_assigns :foo => :not_nil # assigns[:foo].should_not be_nil
    #
    # Check the instance variable is nil
    #
    #   it_assigns :foo => nil # => assigns[:foo].should be_nil
    #
    # Check the instance variable was not set at all
    #
    #   it_assigns :foo => :undefined # => controller.send(:instance_variables).should_not include("@foo")
    #
    # Instance variables for :headers/:flash/:session are special and use the assigns_* methods.
    #
    #   it_assigns :foo => 'bar', 
    #     :headers => { :Location => '...'    }, # it.assigns_headers :Location => ...
    #     :flash   => { :notice   => :not_nil }, # it.assigns_flash :notice => ...
    #     :session => { :user     => 1        }, # it.assigns_session :user => ...
    #
    def it_assigns(*names)
      names.each do |name|
        if name.is_a?(Symbol)
          it_assigns name => name # go forth and recurse!
        elsif name.is_a?(Hash)
          name.each do |key, value|
            if @@variable_types.key?(key) then send("it_assigns_#{key}", value)
            else it_assigns_example_values(key, value) end
          end
        end
      end
    end
  
    # See protected #render_blank, #render_template, and #render_xml for details.
    #
    #   it_renders :blank
    #   it_renders :template, :new
    #   it_renders :xml, :foo
    #
    def it_renders(render_method, *args, &block)
      send("it_renders_#{render_method}", *args, &block)
    end
  
    # Check that the flash variable(s) were assigned
    #
    #   it_assigns_flash :notice => 'foo',
    #     :this_is_nil => nil,
    #     :this_is_undefined => :undefined,
    #     :this_is_set => :not_nil
    #
    def it_assigns_flash(flash)
      raise NotImplementedError
    end
    
    # Check that the session variable(s) were assigned
    #
    #   it_assigns_session :notice => 'foo',
    #     :this_is_nil => nil,
    #     :this_is_undefined => :undefined,
    #     :this_is_set => :not_nil
    #
    def it_assigns_session(session)
      raise NotImplementedError
    end
    
    # Check that the HTTP header(s) were assigned
    #
    #   it.assigns_headers :Location => 'foo',
    #     :this_is_nil => nil,
    #     :this_is_undefined => :undefined,
    #     :this_is_set => :not_nil
    #
    def it_assigns_headers(headers)
      raise NotImplementedError
    end
    
    @@variable_types.each do |collection_type, collection_op|
      public
      define_method "it_assigns_#{collection_type}" do |values|
        values.each do |key, value|
          send("it_assigns_#{collection_type}_values", key, value)
        end
      end
      
      protected
      define_method "it_assigns_#{collection_type}_values" do |key, value|
        key = key.send(collection_op) if collection_op
        it "assigns #{collection_type}[#{key.inspect}]" do
          acting do |resp|
            collection = resp.send(collection_type)
            case value
              when nil
                collection[key].should be_nil
              when :not_nil
                collection[key].should_not be_nil
              when :undefined
                collection.should_not include(key)
              when Proc
                collection[key].should == instance_eval(&value)
              else
                collection[key].should == value
            end
          end
        end
      end
    end
    
    public

    def it_assigns_example_values(name, value)
      it "assigns @#{name}" do
        act!
        value = 
          case value
          when :not_nil
            assigns[name].should_not be_nil
          when :undefined
            controller.send(:instance_variables).should_not include("@#{name}")
          when Symbol
            if (instance_variable = instance_variable_get("@#{value}")).nil?
              assigns[name].should_not be_nil
            else
              assigns[name].should == instance_variable
            end
          end
      end
    end

    # Creates 2 examples:  One to check that the body is blank,
    # and the other to check the status.  It looks for one option:
    # :status.  If unset, it checks that that the response was a success.
    # Otherwise it takes an integer or a symbol and matches the status code.
    #
    #   it_renders :blank
    #   it_renders :blank, :status => :not_found
    #
    def it_renders_blank(options = {})
      it "renders a blank response" do
        acting do |response|
          asserts_status options[:status]
          response.body.strip.should be_blank
        end
      end
    end
    
    # Creates 3 examples: One to check that the given template was rendered.
    # It looks for two options: :status and :format.
    #
    #   it_renders :template, :index
    #   it_renders :template, :index, :status => :not_found
    #   it_renders :template, :index, :format => :xml
    #
    # If :status is unset, it checks that that the response was a success.
    # Otherwise it takes an integer or a symbol and matches the status code.
    #
    # If :format is unset, it checks that the action is Mime:HTML.  Otherwise
    # it attempts to match the mime type using Mime::Type.lookup_by_extension.
    #
    def it_renders_template(template_name, options = {})
      it "renders #{template_name}" do
        acting do |response|
          asserts_status options[:status]
          asserts_content_type options[:format]
          response.should render_template(template_name.to_s)
        end
      end
    end
    
    # Creates 3 examples: One to check that the given XML was returned.
    # It looks for two options: :status and :format.
    #
    # Checks that the xml matches a given string
    #
    #   it_renders(:xml) { "<foo />" }
    #
    # Checks that the xml matches @foo.to_xml
    #
    #   it_renders :xml, :foo
    #
    # Checks that the xml matches @foo.errors.to_xml
    #
    #   it_renders :xml, "foo.errors"
    #
    #   it_renders :xml, :index, :status => :not_found
    #   it_renders :xml, :index, :format => :xml
    #
    # If :status is unset, it checks that that the response was a success.
    # Otherwise it takes an integer or a symbol and matches the status code.
    #
    # If :format is unset, it checks that the action is Mime:HTML.  Otherwise
    # it attempts to match the mime type using Mime::Type.lookup_by_extension.
    #
    def it_renders_xml(record = nil, options = {}, &block)
      it_renders_xml_or_json :xml, record, options, &block
    end
    
    # Creates 3 examples: One to check that the given JSON was returned.
    # It looks for two options: :status and :format.
    #
    # Checks that the json matches a given string
    #
    #   it_renders(:json) { "{}" }
    #
    # Checks that the json matches @foo.to_json
    #
    #   it_renders :json, :foo
    #
    # Checks that the json matches @foo.errors.to_json
    #
    #   it_renders :json, "foo.errors"
    #
    #   it_renders :json, :index, :status => :not_found
    #   it_renders :json, :index, :format => :json
    #
    # If :status is unset, it checks that that the response was a success.
    # Otherwise it takes an integer or a symbol and matches the status code.
    #
    # If :format is unset, it checks that the action is Mime:HTML.  Otherwise
    # it attempts to match the mime type using Mime::Type.lookup_by_extension.
    #
    def it_renders_json(record = nil, options = {}, &block)
      it_renders_xml_or_json :json, record, options, &block
    end
    
    def it_renders_xml_or_json(format, record = nil, options = {}, &block)
      if record.is_a?(Hash)
        options = record
        record  = nil
      end
      it "renders #{format}" do
        if record
          pieces = record.to_s.split(".")
          record = instance_variable_get("@#{pieces.shift}")
          record = record.send(pieces.shift) until pieces.empty?
        end
        block ||= lambda { record.send("to_#{format}") }
        acting do |response|
          asserts_status options[:status]
          asserts_content_type options[:format] || format
          response.should have_text(block.call)
        end
      end
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
  end
end