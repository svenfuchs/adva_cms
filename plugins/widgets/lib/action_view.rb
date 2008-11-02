ActionView::Base.class_eval do
  alias_method :render_without_widget, :render unless method_defined? :render_without_widget
  def render(options = {}, old_local_assigns = {}, &block)
    if options.is_a?(Hash) and options[:widget].is_a?(Symbol)
      render_widget options, &block
    else
      render_without_widget(options, old_local_assigns, &block)
    end
  end
  
  def render_widget(options, &block)
    widget = controller.widgets[options.delete(:widget)]
    if widget and widget_conditions_satisfied?(widget)
      options[:partial] = widget[:partial]
      render options, &block
    end
  end
  
  def widget_conditions_satisfied?(widget)
    result = widget.slice(:only, :except).map do |type, conditions|
      result = yield_and conditions.map{|condition| widget_condition_satisfied?(*condition) }
      type == :except ? !result : result
    end
    yield_and(result) || result.empty?
  end
  
  def widget_condition_satisfied?(type, value)
    if value.is_a? Array
      yield_or value.map {|value| widget_condition_satisfied?(type, value) }
    else
      params[type].to_sym == value.to_sym
    end
  end  

  def yield_or(array)
    array.inject(false){|a, b| a || b }
  end
  
  def yield_and(array)
    array.inject(true){|a, b| a && b }
  end  
end