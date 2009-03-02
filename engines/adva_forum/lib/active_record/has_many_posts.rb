module ActiveRecord
  module HasManyPosts
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_posts(options = {})
        options[:order] = 'comments.created_at, comments.id'
        options[:class_name] ||= 'Post'

        has_counter :posts, :as => options[:as]
        
        options.delete(:as) unless options[:as] == :commentable
        with_options options do |c|
          c.has_many :posts, :dependent => :delete_all do
            def by_author(author)
              find_all_by_author_id_and_author_type(author.id, author.class.name)
            end
          end
        end

        include InstanceMethods
      end

      def has_many_posts?
        included_modules.include? ActiveRecord::HasManyPosts::InstanceMethods
      end
    end

    module InstanceMethods
    end
  end
end
