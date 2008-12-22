class ActionController::TestCase
  class << self
    def screen(name, options = {}, &block)
      controller_class = options[:controller] || self.controller_class
      name = screen_name(controller_class, name)
      screens[name] = block
    end
  
    def screens
      @@screens ||= {}
    end
    
    def screen_name(controller_class, name)
      [controller_class.controller_path, name].join('/').to_sym
    end
  end

  def it_renders_screen(screen_name)
    it_renders_template(screen_name)
    assert_screen(screen_name)
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
  
    def assert_screen(name)
      name = self.class.screen_name(@controller, name)
      screen = self.class.screens[name] or raise "could not find screen #{name}"
      instance_eval &screen
    end
end

