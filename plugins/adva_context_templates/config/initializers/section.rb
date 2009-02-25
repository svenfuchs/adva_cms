class SectionFormBuilder < ExtensibleFormBuilder
  before(:section, :submit_buttons) do |f|
    unless @section.type == 'Forum'
      render :partial => 'admin/sections/template_settings', :locals => { :f => f } 
    end
  end
end

ActionController::Dispatcher.to_prepare do
  Section.class_eval do
    has_option :template, :layout

    # Template and layout can be specified as full template names like "sections/home"
    # and 'layouts/simple'. Both can also use * as a wildchard for the current action
    # name. E.g. "sections/*" will become "sections/show" when the current action is
    # :show. The template/" and "layout/" (for layout) subdirectories can be given or
    # omitted, thus "templates/sections/home" and "sections/home" are identical.
    def template_options(action)
      @template_options ||= {}
      @template_options[action] ||= [:layout, :template].inject({}) do |options, type|
        option = template_option(type, action)
        options[type] = option unless option.blank?
        options
      end
    end

    protected

      def template_option(type, action)
        return unless option = send(type)
        option.sub!(/(\*)$/, action.to_s)
        option.sub!(/^templates\//, '')
        option.sub!(/^(?!layouts)/, 'layouts/') if type == :layout and !option.blank?
        option
      end
  end
end