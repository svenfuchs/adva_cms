module TableBuilder
  class Rows < Tag
    self.level = 1
    
    attr_reader :rows

    def initialize(parent, options = {})
      super
      @rows = []
    end
    
    def empty?
      @rows.empty?
    end
    
    def row(*args, &block)
      options = args.extract_options!
      @rows << Row.new(self, args.shift, options, &block)
    end
    
    def render
      build if respond_to?(:build)
      super(@rows.map(&:render))
    end
  end
end