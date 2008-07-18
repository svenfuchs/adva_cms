module Matchers
  module ClassExtensions
    class Base
      class << self
        def inherited(klass)
          ClassExtensions.send :define_method, klass.name.demodulize.underscore do |*args|
            klass.new *args
          end
        end
      end
      
      def initialize(*args)
        @options = args.extract_options!
        @args = args
      end
      
      def matches?(target)
        @target = target
        does_match?
      end

      def failure_message
        msg = "Expected #{@target} to #{self.class.name.demodulize.underscore.gsub('_', ' ')}"
        msg += " with the options: #{@options.inspect}" unless @options.empty?
        msg + '.'
      end
    end
  
    class ActAsAuthenticatedUser < Base
      def does_match?
        @target.included_modules.include? Authentication::InstanceMethods
      end
    end
  
    class ActAsCommentable < Base
      def does_match?
        @target.acts_as_commentable?
      end
    end
  
    class ActAsNestedSet < Base
      def does_match?
        @target.included_modules.include? SymetrieCom::Acts::NestedSet::InstanceMethods
      end
    end
  
    class ActAsParanoid < Base
      def does_match?
        @target.included_modules.include? Caboose::Acts::Paranoid::InstanceMethods
      end
    end
  
    class ActAsRoleContext < Base
      def does_match?
        @target.acts_as_role_context? && @target.roles == Array(@options[:roles])
      end
    end
  
    class ActAsTaggable < Base
      def does_match?
        @target.included_modules.include? ActiveRecord::Acts::Taggable::InstanceMethods
      end
    end
  
    class ActAsThemed < Base
      def does_match?
        @target.included_modules.include? ThemeSupport::ActiveRecord::InstanceMethods
      end
    end
  
    class ActAsVersioned < Base
      def does_match?
        @target.included_modules.include? ActiveRecord::Acts::Versioned::ActMethods
      end
    end
    
    class FilterAttributes < Base
      def does_match?
        @target.included_modules.include?(XssTerminate::InstanceMethods) &&
        @target.xss_terminate_options.values_at(*@options.keys).flatten == @options.values.flatten
      end
    end
  
    class FilterColumn < Base
      def does_match?
        column = @args.first
        @target.send "#{column}=", '*strong*'
        @target.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
        @target.send :process_filters     
        @result = @target.send("#{column}_html")
        @result == '<p><strong>strong</strong></p>'
      end
    end
    
    class HaveAPermalink < Base
      def does_match?
        @target.new.respond_to?(:create_unique_permalink) && 
        @target.permalink_attributes == @args
      end
    end
    
    class HaveCounter < Base
      def does_match?
        name = :"#{@args.first}_counter"
        @target.reflect_on_all_associations(:has_one).find { |a| a.name == name }
      end
    end
    
    class InstantiateWithSti < Base
      def does_match?
        @target.instantiates_with_sti?
      end
    end 
  end
end