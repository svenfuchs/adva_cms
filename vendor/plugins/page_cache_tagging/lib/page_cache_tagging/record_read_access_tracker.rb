module PageCacheTagging
  class RecordReadAccessTracker
    attr_reader :references
  
    def initialize(owner, options)
      @references = []

      Array(options).each do |trackable|
        trackable = {trackable => nil} unless trackable.is_a? Hash
        trackable.each do |trackable, methods|
          trackable = resolve_trackable(owner, trackable)
          track trackable, methods unless trackable.nil?
        end
      end
    end
  
    def resolve_trackable(owner, trackable)
      case trackable
        when Symbol then owner.send trackable
        when /^@/   then owner.instance_variable_get(trackable)
      end
    end
  
    def track(trackable, methods)
      methods = [methods] if methods && !methods.is_a?(Array)
      if trackable.is_a? Array
        trackable.each{|trackable| track trackable, methods }
      else
        track_attributes(trackable, methods)
        track_methods(trackable, methods)
      end
    end
  
    def track_attributes(trackable, methods)
      attributes = methods ? methods.select{|method| trackable.has_attribute? method } : nil    
      RecordAttributesReadObserver.new(trackable, attributes).register(self) if methods.nil? || attributes
    end
  
    def track_methods(trackable, methods)
      non_attributes = methods ? methods.select{|method| !trackable.has_attribute? method } : nil
      MethodReadObserver.new(trackable, non_attributes).register(self) if non_attributes && !non_attributes.empty?
    end
  
    def notify(object, method = nil)
      @references << [object, method]
    end
  end
end