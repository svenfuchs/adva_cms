module TableBuilder
  class Table < Tag
    self.level = 0
    self.tag_name = :table

    attr_reader :body, :head, :foot, :collection, :columns

    def initialize(view = nil, collection = [], options = {})
      @view = view
      @collection = collection
      @columns = []
      @collection_name = options.delete(:collection_name)

      super(nil, options.reverse_merge(:id => collection_name, :class => "#{collection_name} list"))
      
      yield(self) if block_given?
    end
    
    ['head', 'body', 'foot'].each do |name|
      class_eval <<-code
        def #{name}                                # def head
          @#{name} ||= #{name.classify}.new(self)  #   @head ||= Head.new(self)
        end                                        # end
      code
    end

    def column(*names)
      options = names.last.is_a?(Hash) ? names.pop : {}
      names.each do |name| 
        @columns << Column.new(self, name, options)
      end
    end
    
    def empty(*args, &block)
      @empty = (args << block).compact
    end
    
    def row(*args, &block)
      body.row(*args, &block)
    end

    def collection_class
      # @collection.first.class.base_class
      @collection.first.class
    end

    def collection_name
      @collection_name ||= collection_class.name.tableize.gsub('/', '_').gsub('rails_', '')
    end

    def render
      (@collection.empty? && @empty) ? render_empty : begin
        column(*collection_attribute_names) if @columns.empty?
        super do |html|
          html << head.render
          html << body.render
          html << foot.render if @foot && !@foot.empty?
        end.gsub(/\n\s*\n/, "\n")
      end
    end
    
    def render_empty
      @empty.insert(1, @empty.pop.call) if @empty.last.respond_to?(:call)
      content_tag(*@empty)
    end

    protected
      
      def collection_attribute_names
        record = @collection.first
        names = record.respond_to?(:attribute_names) ? record.attribute_names : []
        names.map(&:titleize)
      end
  end
end