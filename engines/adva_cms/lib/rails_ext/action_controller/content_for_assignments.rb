# FIXME Suggest a core patch for splitting render like this:
module ActionView
  module Renderable #:nodoc:
    def render(view, local_assigns = {})
      compile(local_assigns)

      view.with_template self do
        view.send(:_evaluate_assigns_and_ivars)
        view.send(:_set_controller_content_type, mime_type) if respond_to?(:mime_type)

        view.send(method_name(local_assigns), local_assigns, &content_assignments_proc(view))
      end
    end

    def content_assignments_proc(view)
      Proc.new do |*names|
        ivar = :@_proc_for_layout
        if !view.instance_variable_defined?(:"@content_for_#{names.first}") && view.instance_variable_defined?(ivar) && (proc = view.instance_variable_get(ivar))
          view.capture(*names, &proc)
        elsif view.instance_variable_defined?(ivar = :"@content_for_#{names.first || :layout}")
          view.instance_variable_get(ivar)
        end
      end
    end
  end
end

ActionView::Renderable.module_eval do
  def content_assignments_proc_with_content_for_filters(view)
    Proc.new do |*names|
      contents = view.controller.registered_contents.select { |id, content| content.target == names.first }
      contents.each do |id, content|
        # content_for always appends the new content. we might want to have
        # more finegrained control over that.
        view.content_for(names.first, content.render(view))
      end
      content_assignments_proc_without_content_for_filters(view).call(*names)
    end
  end
  alias_method_chain :content_assignments_proc, :content_for_filters
end


ActionController::Base.class_eval do
  class_inheritable_accessor :registered_contents
  self.registered_contents = ActiveSupport::OrderedHash.new

  class << self
    def content_for(target, id, *args, &block)
      self.registered_contents[id] = RegisteredContent.new(id, target, *args, &block)
    end
  end
end

class RegisteredContent
  attr_reader :id, :target, :content, :options

  def initialize(id, target, *args, &block)
    @id = id
    @target = target
    @options = args.extract_options!
    @content = block_given? ? block : args.first
  end

  def render(view)
    view.content_for(target, eval_content(view)) if applies?(view)
  end

  def applies?(view)
    included = options[:only] ? condition_applies?(:only, view) : true
    excluded = options[:except] ? condition_applies?(:except, view) : false
    included and not excluded
  end

  private

    def eval_content(view)
      content.is_a?(Proc) ? view.instance_eval(&content) : content
    end

    def condition_applies?(type, view)
      proc = lambda do |condition, value|
        condition = options[type][condition]
        condition.is_a?(Proc) ? condition.call(view.controller) : value.in?(condition)
      end
      proc.call(:controller, view.controller.controller_path) or
      proc.call(:action, view.controller.action_name) or
      proc.call(:format, view.template_format)
    end
end