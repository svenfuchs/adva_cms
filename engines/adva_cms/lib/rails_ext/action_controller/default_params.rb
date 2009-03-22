ActionController::Base.class_eval do
  class_inheritable_accessor :default_param
  self.default_param = {}
  
  class << self
    def default_param(*args, &block)
      before_filter(args.extract_options!) do |controller|
        controller.default_param(*args, &block)
      end
    end
  end

  def default_param(*keys, &value)
    key = keys.pop
    value = instance_eval(&value)
    target = keys.inject(params) { |target, k| target[k] ||= {} }
    target[key] ||= value
  end
end