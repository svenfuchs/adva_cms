ActionController::Base.class_eval do
  def render_with_custom_templates(options = nil, extra_options = {}, &block)
    applies = options.blank? || options.is_a?(Hash) && (options[:template] || options[:action])
    custom_options = if applies && @section
      @section.render_options(action_name)
    end
    
    unless custom_options.blank?
      begin
        render_without_custom_templates custom_options, &block
      rescue ActionView::MissingTemplate => e
        render_without_custom_templates options, extra_options, &block
      end
    else
      render_without_custom_templates options, extra_options, &block
    end
  end
  alias_method_chain :render, :custom_templates
end