# what would be a better name instead of "custom_templates"

ActionController::Base.class_eval do
  def render_with_custom_templates(options = nil, extra_options = {}, &block)
    custom_options = custom_render_options(options)
    unless custom_options.blank?
      begin
        render_without_custom_templates(custom_options, &block)
      rescue ActionView::MissingTemplate => e
        render_without_custom_templates(options, extra_options, &block)
      end
    else
      render_without_custom_templates(options, extra_options, &block)
    end
  end
  alias_method_chain :render, :custom_templates

  protected

    def custom_render_options(options)
      options.update @section.render_options(action_name) if custom_render?(options)
    end

    def custom_render?(options)
      !! request.path =~ /^\/admin/ or @section.nil? or
         params[:format] && params[:format] != 'html' or
         options.is_a?(Hash) && (options.keys - [:template, :action]).any?
    end

    def custom_render?(options)
      !!(request.path !~ /^\/admin/ and 
         @section and
         params[:format].nil? || params[:format] == 'html' and
         options.is_a?(Hash) && (options.empty? || (options.keys & [:template, :action]).any?))
    end
end