# Menu.instance 'admin/menu_main' do |view|
#   item 'overview', :url => url_for(...)
#   item 'assets',   :url => url_for(...)
#   menu 'sections', :populator => lambda {...} # when a populator is given it populates the menu
#   menu 'settings', :url => url_for(...)       # when an url is given, submenu item has a link
# end
# 
# Menu.instance 'admin/menu_main' do
#   item 'newsletters', :url => url_for(...), :after => 'assets'
# end

module Menu
  mattr_accessor :instances
  @@instances = {}
  
  class << self
    def instance(name, options = {}, &block)
      returning @@instances[name] ||= Base.new(name, options) do |instance|
        instance.definitions << block if block
      end
    end
    
    def reset!
      @@instances = {}
    end
  end

  class Base
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    
    cattr_reader :default_options
    @@default_options = { :partial => 'shared/menu', :class => 'menu' }
    
    attr_reader :id, :options, :definitions, :items
    
    def initialize(id, options = {}, &block)
      @id = id
      @options = self.class.default_options.merge(options)

      @definitions = []
      @definitions << block if block
      @items = []
    end
    
    def render(view)
      reset!
      apply_definitions!(view)
      view.render :partial => @options[:partial], :locals => { :menu => self }
    end
    
    def item(id, options = {})
      insert_at_position(Item.new(id, options), @items, *options.values_at(:before, :after))
    end
    
    def menu(id, options = {}, &block)
      insert_at_position(self.class.new(id, options), @items, *options.values_at(:before, :after))
    end
    
    def empty?
      @items.empty?
    end
    
    def caption
      content_tag :span, id
    end
    
    def partial
      options[:partial]
    end
    
    protected
    
      def insert_at_position(object, collection, before, after)
        index = 0  if before == :_first
        index = -1 if after == :_last

        index ||= if found = before && collection.detect { |o| o.id == before }
          collection.index(found)
        elsif found = after && collection.detect { |o| o.id == after }
          collection.index(found) + 1
        end
        index ||= -1

        collection.insert(index, object)
        object
      end
      
      def reset!
        @items = []
      end
    
      def apply_definitions!(view)
        view.instance_variable_set(:@__menu, self)
        (class << view; self; end).class_eval do
          def method_missing(name, *args, &block)
            return @__menu.send(name, *args, &block) if @__menu.respond_to?(name)
            super
          end
        end
        definitions.each { |definition| view.instance_eval(&definition) }
      end
  end
  
  class Item
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    
    attr_reader :id, :options
    
    def initialize(id, options = {})
      @id = id
      @options = options
    end
    
    def caption
      options[:caption] || link_to(id.is_a?(Symbol) ? I18n.t(:"adva.titles.#{id}") : id, url)
    end
    
    def url
      options[:url] || '#'
    end
  end
end