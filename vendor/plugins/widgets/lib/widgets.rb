module Widgets 
  def self.included(base)
    base.class_eval do 
      extend ClassMethods  
      class_inheritable_accessor :widgets
      self.widgets = {}            
    end
  end
  
  module ClassMethods    
    def widget(name, options = {})    
      self.widgets[name] = options
    end
  end
end

require File.dirname(__FILE__) + '/action_view.rb'