module With
  class << self
    def view(name, options = {}, &block)
      if block_given?
        views[name.to_sym] = Call.new(name, &block)
      else
        views[name.to_sym] or raise "can not find view #{name.inspect}"
      end
    end
    
    def views
      @@views ||= {}
    end
  end
  
  module ClassMethods
    def view(name, options = {}, &block)
      options[:path] ||= controller_class.controller_path if respond_to?(:controller_class)
      name = "#{options[:path]}/#{name}"
      With.view name, options, &block
    end
  end
  
  def it_renders_view(name, options = {}, &block)
    it_renders_template options.delete(:template) || name
    shows name, options, &block
  end
  
  def state(name)
    yield if @_with_view_options[:state] == name
  end
  
  def shows(name, options = {}, &block)
    name = "#{@controller.class.controller_path}/#{name}"
    @_with_view_options = options
    instance_eval &With.view(name, :path => @controller.class.controller_path)
  end
  
  def has_text(pattern)
    pattern = /#{pattern}/ unless pattern.is_a?(Regexp)
    assert_match pattern, @response.body
  end
  
  def does_not_have_text(pattern)
    pattern = /#{pattern}/ unless pattern.is_a?(Regexp)
    assert @response.body !~ pattern
  end
  
  def has_tag(*args, &block)
    assert_select *args, &block
  end
  
  def has_form_posting_to(path, &block)
    path = instance_eval(&path) if path.is_a?(Proc)
    assert_select "form[method=post][action=#{path}]", &block
  end
  
  def has_form_putting_to(path, &block)
    path = instance_eval(&path) if path.is_a?(Proc)
    assert_select "form[method=post][action=#{path}]" do
      assert_select 'input[name=_method][value=put]'
      instance_eval &block if block
    end
  end
end