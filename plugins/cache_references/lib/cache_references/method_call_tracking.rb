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
      meta_class = (class << self; self; end)
      methods.each do |method|
        meta_class.send :define_method, method do |*args|
          tracker << [self, method]
          meta_class.send :remove_method, method
          super
        end
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
    class Tracker
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
          methods ||= :read_attribute
          methods = [methods] if methods && !methods.is_a?(Array)

          if trackable.is_a? Array
            trackable.each { |trackable| track_methods trackable, methods }
          else
            trackable.track_method_calls(references, *methods) unless methods.empty?
          end
        end
    end
  end
end

ActiveRecord::Base.send :include, CacheReferences::MethodCallTracking