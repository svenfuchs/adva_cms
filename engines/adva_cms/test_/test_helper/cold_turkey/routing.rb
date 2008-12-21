class ActionController::TestCase
  @@variable_types = {:headers => :to_s, :flash => nil, :session => nil, :flash_cookie => nil}

  def params_from(path, method = :get)
    ActionController::Routing::Routes.recognize_path(path, :method => method)
  end
  
  def it_maps(method, path, params)
    if path_prefix = params.delete(:path_prefix)
      path = path_prefix + path
    end
    params[:controller] ||= @controller.class.controller_path
    assert_recognizes params, {:path => path, :method => method }
  end

  def it_generates(path, params)
    assert_generates path, params
  end
end