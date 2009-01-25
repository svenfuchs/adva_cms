require 'with/implementation'
require 'with/node'
require 'with/sharing'
require 'with/context'
require 'with/call'

module With
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    include Sharing
  
    def with_common(*names)
      @with_common ||= []
      @with_common += names
    end
    
    def describe(name, &block)
      context = Context.build(name, *with_common, &block).first
      context.compile(self, With.options.slice(:file, :line))
      context
    end

    def reset
      # shared.clear
      with_common.clear
      instance_methods.select{|m| m =~ /^test/ }.each {|m| remove_method(m) }
    end
  end
  
  class << self
    def applies?(names, conditions)
      conditions[:in].nil? || names.include?(conditions[:in]) and
      conditions[:not_in].nil? || !names.include?(conditions[:not_in])
    end
  
    def options
      @@options ||= {}
    end
  
    def options=(options)
      @@options = options
    end

    def aspects
      @@aspects ||= []
    end

    def aspects=(aspects)
      @@aspects = aspects
    end
    
    def aspect?(aspect)
      self.aspects.include?(aspect)
    end
    
    def reset_all
      ObjectSpace.each_object(Test::Unit::TestCase) do |test_case|
        test_case.class.reset if test_case.class.respond_to?(:reset)
      end
    end
  end
  
  # hmm, i can't see a way to solve nested it blocks rather than this because 
  # :it usually indicates an assertion and within assertions we want to be able 
  # to use instance vars as in:
  # it "articles should be new" do @article.new_record?.should == true end
  # def it(name, &block)
  #   yield
  # end
  
  def within(name)
    result = @_with_contexts.include?(name)
    yield if result and block_given?
    return result
  end
end

Test::Unit::TestCase.send :include, With
