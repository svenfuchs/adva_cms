module Menus
	class Menu
		attr_reader :id, :items, :options
		
		def initialize(id, options = {}, &block)
		  @id = id
		  @options = options
		  @items = []
		  @block = block
	  end
    
    def caption
      @caption ||= id.is_a?(Symbol) ? I18n.t(id, :scope => :'adva.titles') : id
    end
	  
	  def tag
	    @tag ||= url ? Tags::A.new(caption, :href => url) : Tags::Span.new(caption) if caption
    end

		def render(scope, &block)
		  prepare_render(scope)
		  menu = items.empty? ? '' : Tags::Ul.new(options).render { |html| items.each { |item| html << item.render(scope) } }
      caption ? Tags::Li.new(tag.render + menu).render : menu
		end
		
    def definitions
      @definitions ||= []
    end
    
    def item(id, options = {}, &block)
      type = options.delete(:type) || Menus::Item
      insert_at_position(type.new(id, options, &block), @items, *options.values_at(:before, :after))
    end
    
    def menu(id, options = {}, &block)
      type = options.delete(:type) || Menus::Menu
      insert_at_position(type.new(id, options, &block), @items, *options.values_at(:before, :after))
    end
    
    def url
      options[:url] ||= (options[:caption] =~ /href="[^"]*"/ and $1) or nil # FIXME remove the caption option?
    end
    
    protected
    
      def prepare_render(scope)
  		  reset
  		  build(scope)
  		  activate(scope.request.path) if scope.respond_to?(:request)
      end
      
      def reset
        @items = []
      end
    
      def build(scope)
        klass = (class << scope; self; end)
        scope.instance_variable_set(:@__menu, self)
        klass.send(:define_method, :method_missing) { |m, *args, &block| @__menu.respond_to?(m) ? @__menu.send(m, *args, &block) : super }

        definitions.each { |definition| scope.instance_eval(&definition) }
        scope.instance_eval(&@block) if @block
        klass.send(:remove_method, :method_missing)

        items.each { |item| item.send(:build, scope) if item.respond_to?(:build) }
      end
    
      def activate(path)
#        add_class_name('active') if path && path =~ %r(^#{url}(/|$))
        items.each { |item| item.activate(path) }
      end
    
      def add_class_name(class_name)
        options[:class] ||= ''
        options[:class] = options[:class].to_s.split(' ').push(class_name).uniq.join(' ')
      end
    
      def insert_at_position(object, collection, before, after)
        index = 0  if before == :first
        index = -1 if after == :last

        index ||= if found = before && collection.detect { |o| o.id == before }
          collection.index(found)
        elsif found = after && collection.detect { |o| o.id == after }
          collection.index(found) + 1
        end
        index ||= -1

        collection.insert(index, object)
        object
      end
	end
end