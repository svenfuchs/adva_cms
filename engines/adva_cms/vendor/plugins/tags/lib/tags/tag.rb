module Tags
  class Node
    attr_accessor :options, :children, :parent

    def initialize(options = nil)
      @options = options || {}
      @children = TagsList.new(self)
      @level = options.delete(:level)
    end

    def root
      parent ? parent.root : self
    end

	  def level
	    @level ||= parents.size
    end

    def parents
      parent ? [parent] + (parent.try(:parents) || []) : []
    end

    def self_and_parents
      [self] + parents
    end

    protected

      def insert_at_position(child, before, after)
        index = 0  if before == :first
        index = -1 if after == :last

        index ||= if found = before && children.detect { |o| o.id == before }
          children.index(found)
        elsif found = after && children.detect { |o| o.id == after }
          children.index(found) + 1
        end
        index ||= -1

        children.insert(index, child)
        child
      end

      def add_class(class_name)
        unless class_name.blank?
          options[:class] ||= ''
          options[:class] = options[:class].split(' ').push(class_name).uniq.join(' ')
        end
      end
  end

  class TagsList < Array
    attr_reader :owner
    def initialize(owner)
      @owner = owner
    end

    def <<(tag)
      tag.parent.children.delete(tag) if tag.parent
      tag.parent = owner
      super
    end

    def insert(index, tag)
      tag.parent = owner
      super
    end
  end

  class Tag < Node
    include ActionView::Helpers::TagHelper

    class_inheritable_accessor :tag_name
    attr_accessor :content

    class << self
      def tag_name
        read_inheritable_attribute(:tag_name) || name.demodulize.underscore.to_sym
      end
    end

    def initialize(*args)
      super(args.extract_options!)
      self.content = args.shift
    end

    def content=(content)
      @content = content.is_a?(Symbol) ? I18n.t(content) : content
    end

    def tag_name
      self.class.tag_name
    end

    def render(options = {})
      content = (self.content || '').dup
      yield(content) if block_given?
      content_tag(tag_name, content.to_s, self.options.merge(options))
    end

    protected
      def lf(str)
        "\n#{str}\n"
      end

      def indent(str)
        str.gsub(/^/, "  ")
      end
  end

	class A < Tag
	end

	class Span < Tag
	end

	class Div < Tag
	end

	class Ul < Tag
	end

	class Li < Tag
	end
end
