module TableBuilder
  class Tag
    include ActionView::Helpers::TagHelper

    attr_reader :name, :options, :parent

    def initialize(name, parent = nil, options = {})
      @name = name
      @parent = parent
      @options = options
    end
    
    def collection_class
      table.collection_class
    end
    
    def collection_name
      table.collection_name
    end
    
    def table
      is_a?(Table) ? self : parent.try(:table)
    end
    
    def head?
      is_a?(Head) || !!parent.try(:head?)
    end

    def to_html(content = nil)
      content ||= yield(html = '') && html if block_given?
      content = lf(indent(content.to_s))
      lf(content_tag(name, content, options))
    end
    
    protected
      def lf(str)
        "\n#{str}\n"
      end
      
      def indent(str)
        str.gsub(/^/, "  ")
        # str.split("\n").map { |l| l.blank? ? l : "  #{l}" }.join("\n")
      end
      
      def add_class!(options, klass)
        unless klass.blank?
          options[:class] ||= ''
          options[:class] = options[:class].split(' ').push(klass).join(' ')
        end
      end
  end
end