class HelloWorldComponent < Components::Base
  helper_method :get_string

  def say_it(string)
    string
  end

  def say_it_with_style(string)
    bolded(string)
  end

  def say_it_with_help(string)
    @string = string
    render
  end

  def bolded(string)
    @string = string
    render
  end

  protected

  def get_string
    @string
  end
end