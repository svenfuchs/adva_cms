module PageCacheTagging
  class MethodReadObserver < Hash
    def initialize(object, methods)
      @observers = []
      @object = object
      methods.each do |name|
        @object.instance_eval <<-eoc, __FILE__, __LINE__
          class << self
            def #{name} #_with_tracking(*args)
              @method_read_observer.notify(:#{name})
              class << self
                remove_method :#{name}
              end
              @method_read_observer = nil
              super
            end
          end
        eoc
      end
      @object.instance_variable_set(:@method_read_observer, self)
    end
  
    def register(observer)
      @observers << observer
    end
  
    def notify(method)
      @observers.each {|observer| observer.notify @object, method }
    end
  
    def uninstall
      @object.instance_variable_set(:@attributes, @attributes)
    end
  end
end