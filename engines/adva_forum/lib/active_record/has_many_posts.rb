module ActiveRecord
  module HasManyPosts
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_posts(options = {})
        return if has_many_posts?

        options.reverse_merge!(:class_name => 'Post',
          :order => 'comments.created_at, comments.id', :dependent => :delete_all)

        has_counter :posts, :as => options[:as]
        options.delete(:as) unless options[:as] == :commentable
        has_many :posts, options
      end

      def has_many_posts?
        instance_methods.include?('posts')
      end
    end
  end
end
