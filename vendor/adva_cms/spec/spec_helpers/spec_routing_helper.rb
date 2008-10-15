module SpecRoutingHelper
  def filter(name)
    "ActionController::Routing::Filter::#{name.to_s.camelize}".constantize
  end

  def before_recognize_path(name, path, host = 'test.host')
    filter(name).send(:before_recognize_path, nil, [path, { :host_with_port => host }]).first
  end

  def before_recognize(name, path, host = 'test.host')
    filter(name).send(:before_recognize, nil, [path, { :host_with_port => host }]).first
  end

  def before_url_helper(name, base, args)
    filter(name).send(:before_url_helper, base, args)
  end

  def after_url_helper(name, base, path, args = nil)
    returning path do filter(name).send(:after_url_helper, base, path, args) end
  end
end