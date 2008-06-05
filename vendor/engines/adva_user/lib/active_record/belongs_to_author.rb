# Provides a common facade for models that reference User and Anonymous as
# their author:
#
#   belongs_to :author, :polymorphic => true
#
# It also caches the attributes name, email and homepage locally in the model
# so that users and anonymouses can be deleted without compromising the data
# integrity (although users might still want to act_as_paranoid).
#
# Currently used by Content, Comment and Activity.

module ActiveRecord
  module BelongsToAuthor
    def self.included(base)
      base.extend ActMacro  
    end

    module ActMacro
      def belongs_to_author(*args)
        return if belongs_to_author?
        options = args.extract_options!
        column_names = args.empty? ? [:author] : args
        HelperMethods.define_author_methods self, column_names
        include InstanceMethods
      end

      def belongs_to_author?
        included_modules.include?(InstanceMethods)
      end
    end
    
    module HelperMethods      
      def self.define_author_methods(target, column_names)
        column_names.each do |column|
          target.class_eval <<-code, __FILE__, __LINE__
            belongs_to :#{column}, :polymorphic => true # TODO :with_deleted => true
            validates_presence_of :#{column}
            before_save :cache_#{column}_attributes!
        
            def #{column}_name
              #{column} ? #{column}.name : read_attribute(:#{column}_name)
            end  
  
            def #{column}_email
              #{column} ? #{column}.email : read_attribute(:#{column}_email) if has_attribute? :#{column}_email
            end  
  
            def #{column}_homepage
              #{column} ? #{column}.homepage : read_attribute(:#{column}_homepage) if has_attribute? :#{column}_homepage
            end
  
            def #{column}_link(options = {})
              include_email = options[:include_email] && has_attribute?(:#{column}_email)
              text = include_email ? "\#{#{column}_name} (\#{#{column}_email})" : #{column}_name
              #{column}_homepage.blank? ? text : %Q(<a href="\#{#{column}_homepage}">\#{#{column}_name}</a>)
            end 
            
            private
              def cache_#{column}_attributes!
                self.#{column}_name = #{column}.name
                self.#{column}_email = #{column}.email if respond_to? :#{column}_email=
                self.#{column}_homepage = #{column}.homepage if respond_to? :#{column}_homepage=
              end            
          code
        end        
      end
    end
    
    module InstanceMethods
    end
  end
end