# Tracks read access on trackable objects. Trackables can be given as 
#
#   * instance variable names (when starting with an @)
#   * method names (otherwise)
#   * Hashes that use ivar or method names as keys and method names as values:
#
# So both of these:
#
#   ReadAccessTracker.new controller, :'@foo', :bar, { :'@baz' => :buz }
#   ReadAccessTracker.new controller, :'@foo', :bar, { :'@baz' => [:buz] }
#
# would set up access tracking for the controller's ivar @foo, the method :bar 
# and the method :buz on the ivar @baz.

module PageCacheTagging
  class ReadAccessTracker
    attr_reader :references
    
    def initialize(owner, *trackables)
      @references = []

      trackables.each do |trackable|
        trackable = { trackable => nil } unless trackable.is_a? Hash
        trackable.each do |trackable, methods|
          trackable = resolve_trackable(owner, trackable)
          track trackable, methods unless trackable.nil?
        end
      end
    end

    def notify(object, method = nil)
      @references << [object, method]
    end
    
    protected
    
      # Resolves the trackable by looking it up on the owner. Trackables  will be 
      # interpreted as instance variables when they start with an @ and as method
      # names otherwise.
      def resolve_trackable(owner, trackable)
        case trackable.to_s
          when /^@/   then owner.instance_variable_get(trackable.to_sym)
          else             owner.send trackable.to_sym
        end
      end
      
      # Wraps the trackable into an AttributesReadObserver and/or a MethodReadObserver
      # depending on the given methods.
      def track(trackable, methods)
        methods = [methods] if methods && !methods.is_a?(Array)
        if trackable.is_a? Array
          trackable.each { |trackable| track trackable, methods }
        else
          track_attributes(trackable, methods)
          track_methods(trackable, methods)
        end
      end

      # Wraps the trackable into a AttributesReadObserver when methods is either nil 
      # (observes all attributes) or an array of attribute names (observes the given 
      # attributes).
      def track_attributes(trackable, methods)
        attributes = methods ? methods.select { |method| trackable.has_attribute? method } : nil
        AttributesReadObserver.new(trackable, attributes).register(self) if methods.nil? || !attributes.empty?
      end

      # Wraps the trackable into a MethodReadObserver when methods is an array of
      # method names that are not attributes.
      def track_methods(trackable, methods)
        non_attributes = methods ? methods.select { |method| !trackable.has_attribute? method } : nil
        MethodReadObserver.new(trackable, non_attributes).register(self) if non_attributes && !non_attributes.empty?
      end
  end
end