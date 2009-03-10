# Simple mechanism to track calls on methods.
# 
# Include the module and call track_methods(an_array, :foo, :bar) on any object.
# This will set up the methods :foo and :bar on the object's metaclass. 
#
# When the method :foo is called for the first time this is recorded to the 
# given array and the method is removed from the metaclass (so it only records 
# the) first call. The given array will then equal [[the_object, :foo]].
module CacheReferences
  module MethodCallTracking
    def track_method_calls(tracker, *methods)
      if methods.empty?
        define_track_method(tracker, @attributes, :[], [self, nil])
      else
        methods.each do |method|
          define_track_method(tracker, self, method, [self, method])
        end
      end
    end
    
    # Sets up a method in the meta class of the target object which will save
    # a reference when the method is called first, then removes itself and
    # delegates to the regular method in the class. (Cheap method proxy pattern
    # that leverages Ruby's way of looking up a method in the meta class first
    # and then in the regular class second.)    
    def define_track_method(tracker, target, method, reference)
      meta_class = class << target; self; end
      meta_class.send :define_method, method do |*args|
        tracker << reference
        meta_class.send :remove_method, method
        super
      end
    end
    
    # Tracks method access on trackable objects. Trackables can be given as 
    #
    #   * instance variable names (when starting with an @)
    #   * method names (otherwise)
    #   * Hashes that use ivar or method names as keys and method names as values:
    #
    # So both of these:
    #
    #   MethodCallTracker.new controller, :'@foo', :bar, { :'@baz' => :buz }
    #   MethodCallTracker.new controller, :'@foo', :bar, { :'@baz' => [:buz] }
    #
    # would set up access tracking for the controller's ivar @foo, the method :bar 
    # and the method :buz on the ivar @baz.
    class MethodCallTracker
      attr_reader :references
      
      def initialize
        @references = []
      end
      
      def track(owner, *trackables)
        trackables.each do |trackable|
          trackable = { trackable => nil } unless trackable.is_a? Hash
          trackable.each do |trackable, methods|
            trackable = resolve_trackable(owner, trackable)
            track_methods(trackable, methods) unless trackable.nil?
          end
        end
      end
    
      protected
    
        # Resolves the trackable by looking it up on the owner. Trackables  will be 
        # interpreted as instance variables when they start with an @ and as method
        # names otherwise.
        def resolve_trackable(owner, trackable)
          case trackable.to_s
            when /^@/   then owner.instance_variable_get(trackable.to_sym)
            else             owner.send(trackable.to_sym)
          end
        end
      
        # Wraps the trackable into a MethodReadObserver and registers itself as an observer. 
        # Sets up tracking for the read_attribute method when the methods argument is nil. 
        # Sets up tracking for any other given methods otherwise.
        def track_methods(trackable, methods)
          if trackable.is_a? Array
            trackable.each { |trackable| track_methods trackable, methods }
          else
            trackable.track_method_calls(references, *Array(methods))
          end
        end
    end
  end
end
