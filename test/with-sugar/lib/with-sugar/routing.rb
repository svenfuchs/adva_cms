module With
  @@variable_types = {:headers => :to_s, :flash => nil, :session => nil, :flash_cookie => nil}

  def params_from(path, method = :get)
    ActionController::Routing::Routes.recognize_path(path, :method => method, :host_with_port => @request.host_with_port)
  end
  
  def it_maps(method, path, params = {})
    path, format = $1, $2 if path =~ /(.*)\.([\w]+)$/
    
    if path_prefix = params.delete(:path_prefix)
      path = path_prefix + path
    end

    if path_suffix = params.delete(:path_suffix)
      path = path + path_suffix
    end
    
    path = '/' if path.empty?
    path.gsub!('//', '/')
    path = path + '.' + format if format

    params[:controller] ||= @controller.class.controller_path
    assert_recognizes params, {:path => path, :method => method }
  end

  def it_generates(path, params)
    assert_generates path, params
  end
end