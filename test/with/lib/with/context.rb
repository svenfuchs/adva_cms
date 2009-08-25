module With
  class Context < Node
    class << self
      def build(*names, &block)
        context = new
        
        names.each do |names| 
          children = Array(names).map do |name| 
            name.is_a?(Symbol) ? With.shared(name) : new(name, &block)
          end.flatten
          context.append_children children
        end
        
        context.children.each do |child|
          child.parent = nil
          child.leafs.each { |leaf| leaf.define(&block) } if block
        end
      end
    end
    
    def with(*names, &block)
      options = names.last.is_a?(Hash) ? names.pop : {}
      Context.build(*names, &block).each do |child|
        add_child child
        child.filter(options) unless options.empty?
      end
    end
    
    [:before, :action, :assertion, :after].each do |name|
      class_eval <<-code
        def #{name}(name = nil, options = {}, &block)
          contexts = options[:with] ? with(*options.delete(:with)) : [self]
          contexts.each {|c| c.calls(:#{name}) << Call.new(name, options, &block) }
        end
      code
    end
    alias :expect :before
    alias :it :assertion

    def compile(target, options = {})
      file, line = With.options[:file], With.options[:line]
      leafs.each { |leaf| define_test_method(target, leaf) if leaf.implemented_at?(file, line) }
    end
    
    protected

      def method_missing(method_name, *args, &block)
        options = {}
        if args.last.is_a?(Hash) # and [:in, :not_in].select{|key| args.last.has_key?(key) }
          [:with, :in, :not_in, :if].each { |key| options[key] = args.last.delete(key) }
          args.pop if args.last.empty?
        end

        if Test::Unit::TestCase.method_defined?(method_name)
          assertion ([method_name] << args.map(&:inspect)).join('_'), options do
            send method_name, *args, &block
          end
        else
          lambda { send method_name, *args, &block }
        end
      end

      def define_test_method(target, context, options = {})
        method_name = generate_test_method_name(context)
        target.send :define_method, method_name, &lambda {
          call_stage = lambda do |stage|
            @_with_current_stage = stage
            context.collect(stage).map do |call| 
              if @_expected_exception and stage == :action
                assert_raises(@_expected_exception) { instance_eval(&call) }
              else
                instance_eval(&call)
              end
            end
          end
          begin
            @_with_contexts = (context.parents << context).map(&:name)
            [:before, :action, :assertion].each { |stage| call_stage.call(stage) } 
          ensure
            call_stage.call(:after)
          end
        }
      end
      
      def generate_test_method_name(context)
        contexts = context.parents << context
        assertions = context.calls(:assertion)
        
        name = "test_##{context.object_id}\n#{contexts.shift.name}"
        name += "\n  with " + contexts.map(&:name).to_sentence
        name += "\n  it " + assertions.map(&:name).to_sentence
        name.gsub('_', ' ').gsub('  ', ' ').gsub('it it', 'it')
      end
  end
end