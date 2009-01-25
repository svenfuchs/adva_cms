$:.unshift File.dirname(__FILE__) + '/../lib/'
require 'with'

class Target
  include With
  
  def called
    @called ||= []
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class Array
  def to_sentence
    case length
      when 0
        ""
      when 1
        self[0].to_s
      else
        "#{self[0...-1].join(', ')} and #{self[-1]}"
    end
  end
end

class Hash
  def slice(*keys)
    Hash[*keys.map { |key| [key, self[key]] if has_key?(key) }.flatten.compact]
  end
end

class Test::Unit::TestCase
  def context_names(contexts)
    contexts.map do |context| 
      context.leafs.map { |leaf| (leaf.parents << leaf).map(&:name) }
    end
  end
end

module With
  class Node
    def inspect
      $_INDENT ||= 0
      $_INDENT += 1
      s = "\n#<Context:#{self.object_id} @name=#{name.inspect}\n"
      s << "  @parent(#{parent.object_id})=#{parent.name.inspect}\n" unless parent.nil?
      s << "  @calls(#{@calls.object_id})=#{@calls.inspect}\n" unless @calls.empty?
      s << "  @children(#{@children.object_id})=#{children.inspect}" unless children.empty?
      s << ">"
      s = s.split(/\n/).map{|s| ' ' * $_INDENT + s }.join("\n")
      $_INDENT -= 1
      s
    end
  end

  class Call
    def inspect
      s = "#<Call:#{self.object_id} @name=#{name.inspect}"
      s << " @conditions=#{@conditions.inspect}" unless @conditions.empty?
      s + '>'
    end
  end
end