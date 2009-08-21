module ResourceHelper
  def resource_url(action, resource, options = {})
    type, resource = *resource.reverse if resource.is_a?(Array)
    raise "can not generate a url for a new #{resource.class.name}" if resource.try(:new_record?)

    namespace = resource_url_namespace(options)
    type = normalize_resource_type(action, type, resource)
    options.reverse_merge!(:only_path => true)

    args = resource_owners(resource) << options
    args.shift unless namespace.try(:to_sym) == :admin

    send(resource_url_method(namespace, action, type, options), *args.uniq)
  end

  def resource_link(action, *args)
    action = action.to_sym
    url_options = args.extract_options!.dup
    options = url_options.slice!(:only_path, :namespace, :anchor, :cl) # FIXME rather slice out known link_to options here

    resource, text = *args.reverse
    type, resource = *resource.reverse if resource.is_a?(Array)

    type = normalize_resource_type(action, type, resource)
    text = normalize_resource_link_text(text, action, type)
    options = normalize_resource_link_options(options, action, type, resource)

    resource = [resource, type] if [:index, :new].include?(action)
    url = options.delete(:url) || resource_url(action, resource, url_options)

    link_to(text, url, options)
  end

  [:index, :new, :show, :edit, :delete].each do |action|
    define_method(:"#{action}_url") do |*args|
      args << options = args.extract_options!
      options[:only_path] = false
      resource_url(action, *args)
    end

    define_method(:"#{action}_path") do |*args|
      args << options = args.extract_options!
      options[:only_path] = true
      resource_url(action, *args)
    end

    define_method(:"link_to_#{action}") do |*args|
      resource_link(action, *args)
    end
  end

  def links_to_actions(actions, *args)
    actions.map { |action| resource_link(action, *args) }.join("\n")
  end

  protected

    def normalize_resource_type(action, type, resource)
      type ||= resource.is_a?(Symbol) ? resource : resource.class.name
      type = 'section' if type.to_s.classify.constantize < Section
      type = type.to_s.tableize.gsub("/","_") if action == :index
      type = type.to_s.split("::").first == "Adva" ? type.to_s.underscore.gsub("/","_") : type.to_s.demodulize.underscore
      type
    end

    def resource_url_namespace(options)
      options.key?(:namespace) ? options.delete(:namespace) : current_controller_namespace
    end

    def current_controller_namespace
      path = respond_to?(:controller_path) ? controller_path : controller.controller_path
      namespace = path.split('/')[0..-2].join('_')
      namespace.present? ? namespace : nil
    end

    def resource_link_id(action, type, resource)
      id = [action, type]
      id << resource.id if resource.is_a?(ActiveRecord::Base) && !action.in?(:index, :new)
      id.join('_')
    end

    def resource_owners(resource)
      return [] if resource.nil? || resource.is_a?(Symbol)
      return resource.owners << resource if resource.respond_to?(:owners)

      owners = []
      if resource.respond_to?(:section)
        owners << resource.section.site << resource.section
      elsif resource.respond_to?(:site)
        owners << resource.site
      elsif resource.respond_to?(:owner)
        owners << resource.owner
      end

      owners << resource
    end

    def resource_url_method(namespace, action, type, options)
      method = [namespace, type].compact

      method << (options.delete(:only_path) ? 'path' : 'url')
      method.unshift(action) if [:new, :edit].include?(action.to_sym)

      method.compact.join('_').gsub('/', '_')
    end

    def normalize_resource_link_options(options, action, type, resource)
      options[:class] ||= "#{action} #{type}"
      options[:id] ||= resource_link_id(action, type, resource)
      options[:title] ||= t(:"adva.titles.#{action}")
      options.reverse_merge!(resource_delete_options(type, options)) if action == :delete
      options
    end

    def normalize_resource_link_text(text, action, type)
      type = type.to_s.gsub('/', '_').pluralize
      text ||= t(:"adva.#{type}.links.#{action}", :default => :"adva.resources.links.#{action}")
      text = t(text) if text.is_a?(Symbol)
      text
    end

    def resource_delete_options(type, options)
      type = type.to_s.gsub('/', '_').pluralize
      message = options.delete(:confirm)
      message ||= t(:"adva.#{type}.confirm_delete", :default => :"adva.resources.confirm_delete")
      message = t(message) if message.is_a?(Symbol)
      { :confirm => message, :method => :delete }
    end
end
