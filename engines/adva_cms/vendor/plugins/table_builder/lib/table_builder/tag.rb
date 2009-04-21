module TableBuilder
  class Tag
    class_inheritable_accessor :level, :tag_name

    include ActionView::Helpers::TagHelper

    attr_reader :options, :parent

    def initialize(parent = nil, options = {})
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

    def render(content = nil)
      yield(content = '') if content.nil? && block_given?
      content = lf(indent(content.to_s))
      lf(content_tag(tag_name, content, options))
    end
    
    def add_class(klass)
      add_class!(options, klass)
    end
    
    protected
      def lf(str)
        "\n#{str}\n"
      end
      
      def indent(str)
        str.gsub(/^/, "  ")
      end
      
      def add_class!(options, klass)
        unless klass.blank?
          options[:class] ||= ''
          options[:class] = options[:class].split(' ').push(klass).join(' ')
        end
      end
  end
end