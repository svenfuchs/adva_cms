class ActionController::TestCase
  class << self
    def view(name, options = {}, &block)
      controller_class = options[:controller] || self.controller_class
      name = view_name(controller_class, name)
      views[name] = block
    end
  
    def views
      @@views ||= {}
    end
    
    def view_name(controller_class, name)
      [controller_class.controller_path, name].join('/').to_sym
    end
  end

  def it_renders_view(view_name)
    it_renders_template(view_name)
    assert_view(view_name)
  end
  
  def has_tag(name, attributes = {}, &block)
    selector = name.to_s + attributes.map { |name, value| "[#{name}=#{value}]" }.join
    assert_select selector, &block
  end
  
  def has_form_posting_to(path, &block)
    assert_select "form[method=post][action=#{path}]", &block
  end
  
  def has_form_putting_to(path, &block)
    assert_select "form[method=post][action=#{path}]" do
      assert_select 'input[name=_method][value=put]'
      instance_eval &block if block
    end
  end
  
  protected
  
    def assert_view(name)
      name = self.class.view_name(@controller, name)
      view = self.class.views[name] or raise "could not find view #{name}"
      instance_eval &view
    end
end

