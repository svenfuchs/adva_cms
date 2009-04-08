module Menu
  class Base
    class_inheritable_accessor :definitions
    self.definitions = []
    
    class Builder
      attr_reader :object

      def initialize(object)
        @object = object
      end
    
      def name(name)
        @object.name = name
      end
    
      def parent(parent)
        @object.parent = parent
      end
      
      def activates(activates)
        @object.activates = activates
      end
      
      def menu(name, &block)
        menu = Builder.new(Menu.new(name)).tap { |builder| block.call(builder) }.object
        menu.parent = @object
      end

      def item(name, options = {})
        Item.new(name, options).parent = @object
      end
    end

    class << self
      def define(&block)
        definitions << block
      end
      
      def build
        Builder.new(new).tap { |builder| definitions.each { |block| block.call(builder) } }.object.root
      end
    end

    attr_accessor :name, :url, :active, :parent, :children, :activates

    def initialize(name = nil, options = {})
      @name = name || self.class.name.underscore.sub('_menu', '').to_sym
      @children = []
		  [:text, :content, :url].each { |key| instance_variable_set(:"@#{key}", options.delete(key)) }
    end

    def root
      parent ? parent.root : self
    end

    def parent=(parent)
      @parent = parent
      parent.children << self
    end

    def [](*keys)
      key = keys.shift
      child = children.detect { |item| item.name == key } or raise "can not find item #{key.inspect}"
      keys.empty? ? child : child[*keys]
    end
    
    def activation_path
      target = activates ? activates.call(self) : parent
      [self] + Array(target ? target.activation_path : nil).compact
    end
    
    def activate(path)
      path == url ? activation_path.each { |item| item.active = true } : self.active = false
      # activation_path.each { |node| node.active = true } if path == url
      children.each { |child| child.activate(path) }
    end
  end
  
  class Item < Base
  end

  class Menu < Base
  end

  class Group < Base
  end

  # class TopMenu < Group
  #   name :top
  #   menu :left, :class => 'main left' do |m|
  #     m.item :overview, lambda { ... }
  #     m.item :sections, lambda { ... }
  #   end
  # end
  #
  # class BlogMenu < Group
  #   menu :left, :class => 'main left' do |m|
  #     m.parent TopMenu.instance.[:left][:sections]
  #     m.item :articles, :url => lambda { index_path([@section, :article]) }
  #   end
  #   menu :right, :class => 'main right' do |m|
  #     m.parent :left, :articles
  #   end
  # end
end
