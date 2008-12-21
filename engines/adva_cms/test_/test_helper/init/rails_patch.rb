# strangely, request.path is empty when caching kicks in, this seems to fix that

ActionController::TestProcess.module_eval do
  def build_request_uri_with_set_path(*args)
    build_request_uri_without_set_path(*args)
    @request.path = @request.env['REQUEST_URI']
  end
  alias_method_chain :build_request_uri, :set_path
end

ActionController::Caching::Pages::ClassMethods.module_eval do
  def caches_page(*actions)
    # We want to turn perform_caching on/off at runtime, so we need the filters to 
    # be registered no matter what. perform_caching is checked at all relevant other 
    # places, too, though.
    # return unless perform_caching
    options = actions.extract_options!
    after_filter({:only => actions}.merge(options)) { |c| c.cache_page }
  end
end