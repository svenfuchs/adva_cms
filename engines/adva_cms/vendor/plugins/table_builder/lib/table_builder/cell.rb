module TableBuilder
  class Cell < Tag
    def self.level; 3 end
    
    attr_reader :content

    def initialize(parent, content = nil, options = {})
      super(parent.head? ? :th : :td, parent, options)
      @content = content
    end

    def to_html
      super(content)
    end
  end
end