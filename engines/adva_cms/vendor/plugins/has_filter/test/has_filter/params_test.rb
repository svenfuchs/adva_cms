require File.dirname(__FILE__) + '/../test_helper.rb'

class ActiveSupport::TestCase
  def requested_params(html)
    params = params_from_form(html)
    params = requestify_params(params)
    Rack::Utils.parse_nested_query(params)
  end

  def params_from_form(html, id = nil)
    id, html = 'test', %(<form id="test">#{html}</form>) unless html =~ /<form /
    session = Webrat::Session.new
    scope = Webrat::Scope.new(session) { @response_body = html }
    Webrat::Locators::FormLocator.new(session, scope.dom, id).locate.send(:params)
  end

  # from rails integration/session 
  def requestify_params(parameters, prefix=nil)
    if Hash === parameters
      return nil if parameters.empty?
      parameters.map { |k,v|
        requestify_params(v, params_name_with_prefix(prefix, k))
      }.join("&")
    elsif Array === parameters
      parameters.map { |v|
        requestify_params(v, params_name_with_prefix(prefix, ""))
      }.join("&")
    elsif prefix.nil?
      parameters
    else
      "#{CGI.escape(prefix)}=#{CGI.escape(parameters.to_s)}"
    end
  end

  def params_name_with_prefix(prefix, name)
    prefix ? "#{prefix}[#{name}]" : name.to_s
  end
end

class HasFilterParamsTest < ActiveSupport::TestCase
  # test 'foo' do
  #   html = <<-html
  #     <input type="text" name="filters[]" value="foo">'
  #     <input type="text" name="filters[]" value="bar">'
  #   html
  #   p params = params_from_form(html)
  #   params = requestify_params(params)
  #   params = Rack::Utils.parse_nested_query(params)
  #   # params = Rack::Utils.normalize_params(params)
  #   p params
  # end

  # test 'foo' do
  #   html = <<-html
  #     <select type="text" name="filters[body][][scope]"><option name="contains">contains</option></select>
  #     <input type="text"  name="filters[body][][query]" value="foo">
  #     <select type="text" name="filters[body][][scope]"><option name="starts_with">starts_with</option></select>
  #     <input type="text"  name="filters[body][][query]" value="bar">
  #   html
  #   p params = params_from_form(html)
  #   params = requestify_params(params)
  #   params = Rack::Utils.parse_nested_query(params)
  #   # params = Rack::Utils.normalize_params(params)
  #   p params
  # end
end

