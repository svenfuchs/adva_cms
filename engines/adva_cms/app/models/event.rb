class Event
  cattr_accessor :observers
  @@observers = []

  attr_reader :type        # what happened
  attr_reader :object      # the object that the event is about, e.g. payment
  attr_reader :source      # the origin or the event, e.g. payment processor
  attr_reader :options     # optional options for the event

  class << self
    def trigger(type, object, source, options = {})
      event = Event.new(type, object, source, options)
      observers.each do |observer|
        observer = observer.constantize if observer.is_a?(String)
        callback = :"handle_#{event.type}!"

        if observer.respond_to?(callback)
          observer.send(callback, event)
        elsif observer.respond_to?(:handle_event!)
          observer.handle_event!(event)
        end
      end
    end
  end

  def initialize(type, object, source, options = {})
    @type, @object, @source, @options = type, object, source, options
  end

  def method_missing(name, *args)
    return @options[name] if @options.has_key?(name)
    super
  end
end
