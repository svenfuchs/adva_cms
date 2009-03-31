module ActiveRecord
  module BelongsToAuthor
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def belongs_to_user(*args)
        options = args.extract_options!
        args = (args.empty? ? [:user] : args)
        belongs_to_cacheable *args.dup << options # FIXME should not be polymorphic!
        
        args.each do |name|
          class_eval <<-code, __FILE__, __LINE__
            def #{name}_link(options = {})
              include_email = options[:include_email] && respond_to?(:#{name}_email)
              name = #{name}_name
              text = #{name}_homepage.blank? ? name : %Q(<a href="\#{#{name}_homepage}">\#{name}</a>)
              text = "\#{text} (\#{#{name}_email})" if include_email
              text
            end

            def #{name}_ip
              #{name}.ip if #{name} && #{name}.respond_to?(:ip)
            end

            def #{name}_agent
              #{name}.agent if #{name} && #{name}.respond_to?(:agent)
            end

            def #{name}_referer
              #{name}.referer if #{name} && #{name}.respond_to?(:referer)
            end
          code
        end
      end

      def belongs_to_author(*args)
        options = args.extract_options!
        args = (args.empty? ? [:author] : args) << options
        belongs_to_user *args
      end
    end
  end
end