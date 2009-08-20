ActionController::Base.class_eval do
  def url_for_with_returning(options = {})
    return url_for_without_returning(options) unless options.is_a?(Hash)

    case returning = options.delete(:return)
    when true, :here
      options.reverse_merge! :return_to => params[:return_to] || request.request_uri
    end
    url_for_without_returning(options)
  end
  alias_method_chain :url_for, :returning
end