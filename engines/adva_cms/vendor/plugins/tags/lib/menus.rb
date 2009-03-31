module Menus
  mattr_accessor :instances
  @@instances = {}
  
  class << self
    def instance(name, options = {}, &block)
      @@instances[name] ||= Menus::Base.new(name, options)
      @@instances[name].definitions << block if block
      @@instances[name]
    end
    
    def reset
      @@instances = {}
    end
  end
end

# require 'menus/menu'
# require 'menus/item'
require 'menus/base'