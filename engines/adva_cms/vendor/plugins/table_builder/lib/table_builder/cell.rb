module TableBuilder
  class Cell < Tag
    self.level = 3

    attr_reader :content

    def initialize(parent, content = nil, options = {})
      super(parent, options)
      @content = content
      options[:colspan] = table.columns.size if options[:colspan] == :all
    end

    def render
      super(content)
    end

    def tag_name
      parent.head? ? :th : :td 
    end
  end
end