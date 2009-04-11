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
      vars.each { |name| instance_variable_set(name, scope.controller.instance_variable_get(name)) }
    end
  
    def id(id)
      object.id = id
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
    
    def menu(id, options = {}, &block)
      type = options.delete(:type) || Menu
      menu = type.new(id, options)
      object.children << menu
      Builder.new(menu, scope, block || type.definitions).object
    end

    def item(id, options = {})
      type = options.delete(:type) || Item
      object.children << type.new(id, options)
    end

    def breadcrumb(id, options = {})
      type = options.delete(:type) || Item
      object.instance_variable_get(:@breadcrumbs) << type.new(id, options)
    end
    
    def method_missing(method, *args, &block)
      scope.send(method, *args, &block)
    end
  end
end