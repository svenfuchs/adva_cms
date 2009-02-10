module With
  class Node
    include Implementation
    
    attr_accessor :name, :parent, :children, :calls
    
    def initialize(name = nil, &block)
      @name = name
      @block = block
      @children = []
      @calls = {}
    end
    
    def initialize_copy(orig)
      @children = orig.children.map { |child| child.clone }
      @children.each { |child| child.parent = self }
      @calls = {}
      orig.calls.each { |key, calls| @calls[key] = calls.map{ |call| call.clone } }
    end
    
    def define(&block)
      @block = block
      instance_eval &block
    end
    
    # def select(&block)
    #   result = yield(self) ? [self] : [] #  || !@calls.select(&block).empty?
    #   result += @children.map { |child| child.select(&block) }.flatten
    # end
    
    def filter(conditions)
      if With.applies?(parents.map(&:name), conditions)
        @children.each {|child| child.filter(conditions) }
      else
        parent.children.delete(self)
      end
    end
    
    def calls(stage = nil)
      stage.nil? ? @calls : (@calls[stage] ||= [])
    end

    def collect(stage)
      (parent ? parent.collect(stage) : []) + calls(stage).select {|call| call.applies?(self) }
    end

    def parents
      parent ? parent.parents + [parent] : []
    end

    def leafs
      return [self] if children.empty?
      children.map { |child| child.leafs }.flatten
    end
    
    def add_child(child)
      @children << child
      child.parent = self
    end

    def append_children(children)
      leafs.each { |leaf| children.each {|child| leaf.add_child(child.dup) } }
    end
  end
end