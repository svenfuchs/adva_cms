module Adva
  module ContentForAssignment
    def render(view, local_assigns = {})
      view.controller.registrered_contents.each do |id, content|
        content.render(view)
      end
      super
    end
  end
end

ActionView::Renderable.module_eval do
  include Adva::ContentForAssignment
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
    
    normalize_options!
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
      proc.call(:controller, view.controller.controller_path.to_sym) or
        proc.call(:action, view.controller.action_name.to_sym) or
        proc.call(:format, view.template_format.to_sym)
    end

    def normalize_options!
      @options.each do |type, condition|
        condition.each do |key, value|
          case value
          when Array;  @options[type][key] = value.map(&:to_sym)
          when String; @options[type][key] = value.to_sym
          end
        end
      end
    end
end
