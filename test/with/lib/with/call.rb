module With
  extend Sharing

  class Call
    include Implementation

    attr_reader :name, :block

    def initialize(name, conditions = {}, &block)
      raise "need to provide a block" unless block

      @name = name
      @conditions = conditions
      @block = block

      @conditions[:if] = With.condition(@conditions[:if]) if @conditions[:if].is_a?(Symbol)
    end

    def applies?(context)
      names = context.parents.map(&:name) << context.name
      With.applies?(names, @conditions)
    end

    def to_proc
      name, block, conditions = self.name, self.block, @conditions
      Proc.new {
        @_with_current_context = name
        if conditions[:if]
          instance_eval(&block) if instance_eval(&conditions[:if])
        else
          instance_eval(&block)
        end
      }
    end

    def call
      to_proc.call
    end
  end
end