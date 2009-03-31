# Menu.instance 'admin/menu_main' do |view|
#   item 'overview', :url => url_for(...)
#   item 'assets',   :url => url_for(...)
#   menu 'sections', :populate => lambda {...} # used for populating the menu programmatically
#   menu 'settings', :url => url_for(...)      # when an url is given, submenu item has a link
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
    
    def reset
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
      reset
      apply_definitions(view)
      highlight(view.request.path)
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
      options[:caption] ||= url && link_to(id.is_a?(Symbol) ? I18n.t(:"adva.titles.#{id}") : id, url)
    end
    
    def url
      options[:url] ||= (options[:caption] =~ /href="([^"]*)"/ and $1) or nil # FIXME remove the caption option?
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
      
      def reset
        @items = []
      end
    
      def apply_definitions(view)
        view.instance_variable_set(:@__menu, self)
        (class << view; self; end).class_eval do
          def method_missing(name, *args, &block)
            return @__menu.send(name, *args, &block) if @__menu.respond_to?(name)
            super
          end
        end
        definitions.each { |definition| view.instance_eval(&definition) }
        view.instance_eval(&options[:populate]) if options[:populate]
        items.each { |item| item.send(:apply_definitions, view) if item.is_a?(Menu::Base) }
      end
      
      def highlight(path)
        # add_class_name('active') if path =~ %r(^#{url}(/|$))
        items.each { |item| item.highlight(path) }
      end
    
      # def add_class_name(class_name)
      #   options[:class] ||= ''
      #   options[:class] = options[:class].to_s.split(' ').push(class_name).uniq.join(' ')
      # end
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
      options[:caption] ||= begin
        raise "you have to set either :url or :caption" unless url
        link_to(id.is_a?(Symbol) ? I18n.t(:"adva.titles.#{id}") : id, url)
      end
    end
    
    def url
      options[:url] ||= (options[:caption] =~ /href="[^"]*"/ and $1) or nil
    end
    
    def highlight(path)
      add_class_name('active') if path =~ %r(^#{url}(/|$))
    end
    
    def add_class_name(class_name)
      options[:class] ||= ''
      options[:class] = options[:class].to_s.split(' ').push(class_name).uniq.join(' ')
    end
  end
end