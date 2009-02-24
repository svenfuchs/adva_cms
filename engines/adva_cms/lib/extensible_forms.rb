require 'action_view/helpers/form_helper'

module ActionView
  module Helpers
    module FormHelper
      def fields_for_with_resource_form_builders(name, *args, &block)
        name = singular_class_name(name) unless name.class.in?(String, Symbol)

        options = args.last.is_a?(Hash) ? args.last : {}
        options[:builder] ||= pick_form_builder(name)
        
        fields_for_without_resource_form_builders(name, *args, &block)
      end
      alias_method_chain :fields_for, :resource_form_builders

      def field_set(object_name, name, content = nil, options = {}, &block)
        InstanceTag.new(object_name, name, self, options.delete(:object)).to_field_set_tag(content, options, &block)
      end

      protected
        def singular_class_name(name)
          ActionController::RecordIdentifier.singular_class_name(name)
        end

        def pick_form_builder(name)
          "#{name.to_s.classify}FormBuilder".constantize
        rescue NameError
          ActionView::Base.default_form_builder
        end
    end

    class InstanceTag
      def to_field_set_tag(content = nil, options = {}, &block)
        options = options.stringify_keys
        name_and_id = options.dup
        add_default_name_and_id(name_and_id)
        options.delete("index")
        options["id"] ||= name_and_id["id"]
        content ||= @template_object.capture(&block) if block_given?
        content_tag("fieldset", content, options)
      end
    end
  end
end

class ExtensibleFormBuilder < ActionView::Helpers::FormBuilder
  class_inheritable_accessor :callbacks
  self.callbacks = { :before => {}, :after => {} }

  class_inheritable_accessor :options
  self.options = { :labels => false, :wrap => false, :default_class_names => {} }

  class << self
    [:labels, :wrap].each do |option|
      define_method(:"#{option}=") { |value| self.options[option] = value }
    end

    def default_class_names(type = nil)
      if type
        self.options[:default_class_names][type] ||= []
      else
        self.options[:default_class_names]
      end
    end

    def before(object_name, method, string = nil, &block)
      add_callback(:before, object_name, method, string || block)
    end

    def after(object_name, method, string = nil, &block)
      add_callback(:after, object_name, method, string || block)
    end

    protected

      def add_callback(stage, object_name, method, callback)
        method = method.to_sym
        callbacks[stage][object_name] ||= { }
        callbacks[stage][object_name][method] ||= []
        callbacks[stage][object_name][method] << callback
      end
  end

  helpers = field_helpers + %w(select date_select datetime_select time_select time_zone_select) -
                            %w(hidden_field label fields_for apply_form_for_options!)

  helpers.each do |method_name|
    class_eval <<-src, __FILE__, __LINE__
      def #{method_name}(*args, &block)
        type = #{method_name.to_sym.inspect}

        options = args.extract_options!
        options = add_default_class_names(options, type)

        label, wrap, hint = options.values_at(:label, :wrap, :hint)
        name = args.first

        with_callbacks(name) do
          tag = super(*(args << options), &block)
          tag = hint(tag, hint) if hint
          tag = labelize(type, tag, name, label) if label || self.options[:labels]
          tag = wrap(tag) if wrap || self.options[:wrap]
          tag
        end
      end
    src
  end

  def field_set(*args, &block)
    options = args.extract_options!
    options = add_default_class_names(options, :field_set)

    name    = args.first
    name ||= :default_fields

    @template.concat with_callbacks(name) {
      legend = options.delete(:legend) || ''
      legend = @template.content_tag('legend', legend) unless legend.blank?
      @template.field_set(@object_name, name, nil, objectify_options(options)) do
        legend + (block ? block.call : '')
      end
    }
  end

  def buttons(name = :submit_buttons, &block)
    @template.concat with_callbacks(name) {
      @template.capture { @template.buttons(&block) }
    }
  end

  def render(*args)
    @template.send(:render, *args)
  end

  protected

    def labelize(type, tag, method, label = nil)
      label = case label
      when String then label
      when Symbol then I18n.t(label)
      else nil
      end

      case type
      when :check_box, :radio_button
        tag + "\n" + self.label(method, label, :class => 'inline light', :id => extract_id(tag))
      else
        self.label(method, label) + tag
      end
    end

    def wrap(tag)
      @template.content_tag(:p, tag)
    end

    def hint(tag, hint)
      hint = I18n.t(hint) if hint.is_a?(Symbol)
      @template.content_tag(:span, hint, :class => 'hint') + tag
    end

    def add_default_class_names(options, type)
      options[:class] = (Array(options[:class]) + self.class.default_class_names(type)).join(' ')
      options.delete(:class) if options[:class].blank?
      options
    end

    def with_callbacks(method, &block)
      result = ''
      result += run_callbacks(:before, method) if method
      result += yield
      result += run_callbacks(:after, method) if method
      result
    end

    def run_callbacks(stage, method)
      if callbacks = callbacks_for(stage, method.to_sym)
        callbacks.inject('') do |result, callback|
          result + case callback
            when Proc
              assign_ivars!
              instance_eval(&callback)
            else
              callback
          end.to_s
        end
      end || ''
    end

    def callbacks_for(stage, method)
      object_name = @object_name.try(:to_sym)
      self.callbacks[stage][object_name] and
      self.callbacks[stage][object_name][method.to_sym]
    end
    
    def assign_ivars!
      unless @ivars_assigned
        @template.assigns.each { |key, value| instance_variable_set("@#{key}", value) }
        vars = @template.controller.instance_variable_names
        vars.each { |name| instance_variable_set(name, @template.controller.instance_variable_get(name)) }
        @ivars_assigned = true
      end
    end

    # yep, we gotta do this crap because there doesn't seem to be a sane way
    # to hook into actionview's form_helper methods
    def extract_id(tag)
      tag =~ /id="([^"]+)"/
      $1
    end
end

ActionView::Base.default_form_builder = ExtensibleFormBuilder