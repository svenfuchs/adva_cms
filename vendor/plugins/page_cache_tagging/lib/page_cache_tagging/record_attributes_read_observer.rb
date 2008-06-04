module PageCacheTagging
  class RecordAttributesReadObserver < Hash
    def initialize(object, names)
      @observers = []
      @attributes = object.instance_variable_get(:@attributes) || {}
      @names = names || @attributes.keys
      @object = object   
      replace @attributes
      @object.instance_variable_set(:@attributes, self)
    end
  
    def [](name)
      if @names.include? name
        uninstall
        notify
      end
      super
    end
  
    def register(observer)
      @observers << observer
    end
  
    def notify
      @observers.each {|observer| observer.notify @object }
    end
  
    def uninstall
      @object.instance_variable_set(:@attributes, @attributes)
    end
  end
end