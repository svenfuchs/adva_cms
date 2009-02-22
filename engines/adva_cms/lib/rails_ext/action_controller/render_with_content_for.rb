# FIXME Instead of hooking into :render it would make more sense to hook into
# the content_for/yield mechanism and only evaluate the registered blocks when
# they are accessed.

ActionController::Base.class_eval do
  class_inheritable_accessor :registered_contents
  self.registered_contents = []
  
  class << self
    def content_for(name, *args, &block)
      self.registered_contents << RegisteredContent.new(name, *args, &block)
    end
  end
end

ActionView::Base.class_eval do
  def render_with_content_for(options = nil, extra_options = {}, &block)
    unless @registered_contents_rendered or !@controller.respond_to?(:registered_contents)
      @registered_contents_rendered = true
      @controller.registered_contents.each { |c| c.render(controller, self) }
      @_rendered.delete(:template) if @_rendered # FIXME ... used in action_view/test_case
    end
    render_without_content_for(options, extra_options, &block)
  end
  alias_method_chain :render, :content_for
end

class RegisteredContent
  attr_reader :name, :content, :options
  
  def initialize(name, *args, &block)
    @name = name
    @options = args.extract_options!
    @content = block_given? ? block : args.first
  end

  def render(controller, view)
    view.content_for(name, eval_content(view)) if applies?(controller, view)
  end

  def applies?(controller, view)
    included = options[:only] ? condition_applies?(:only, controller, view) : true
    excluded = options[:except] ? condition_applies?(:except, controller, view) : false
    included and not excluded
  end

  private
  
    def eval_content(view)
      content.is_a?(Proc) ? view.instance_eval(&content) : content
    end
    
    def condition_applies?(type, controller, view = nil)
      proc = lambda do |condition, value|
        condition = options[type][condition]
        condition.is_a?(Proc) ? condition.call(controller) : value.in?(condition)
      end
      proc.call(:controller, controller.controller_path) or 
      proc.call(:action, controller.action_name) or
      proc.call(:format, view.template_format)
    end
end