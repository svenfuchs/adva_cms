module Menu
  class Builder
    attr_reader :object, :scope

    def initialize(object, scope = nil, definitions = nil)
      @object = object
      @scope = scope
      
      assign_ivars!(scope) if scope

      Array(definitions).each do |block, options|
        self.options(options) if options
        instance_eval(&block)
      end
    end

    def assign_ivars!(scope)
      scope.assigns.each { |key, value| instance_variable_set("@#{key}", value) }
      vars = scope.controller.instance_variable_names
      vars.each { |name| instance_variable_set(name, scope.controller.instance_variable_get(name)) unless name == '@scope' }
    end
  
    def id(key)
      object.key = key
    end
  
    def options(options)
      object.options ||= {}
      object.options.update(options)
    end
    
    def parent(parent)
      parent.children << object
    end
    
    def activates(activates)
      object.activates = activates
    end
    
    def menu(key, options = {}, &block)
      type = options.delete(:type) || Menu
      menu = type.new(key, options)
      object.children << menu
      Builder.new(menu, scope, block || type.definitions).object
    end

    def item(key, options = {})
      action, resource = *options.values_at(:action, :resource)
      namespace = options.delete(:namespace) || object.namespace
      if action && resource
        url = resource_url(action, resource, :namespace => namespace, :only_path => true)
        type, resource = *resource.reverse if resource.is_a?(Array)
        type = normalize_resource_type(action, type, resource)
        options.update :id => :"#{action}_#{type}", :url => url
      end
      type = options.delete(:type) || Item
      object.children << item = type.new(key, options)
    end
    
    def namespace(namespace)
      object.namespace = namespace
    end

    def breadcrumb(key, options = {})
      type = options.delete(:type) || Item
      object.instance_variable_get(:@breadcrumbs) << type.new(key, options)
    end
    
    def method_missing(method, *args, &block)
      return scope.send(method, *args, &block) if scope.respond_to?(method)
      super
    end
  end
end
