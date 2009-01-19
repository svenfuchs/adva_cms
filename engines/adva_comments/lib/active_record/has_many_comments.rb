module ActiveRecord
  module HasManyComments
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_comments(options = {})
        return if has_many_comments?

        options[:order] = 'comments.created_at'
        options[:as] = :commentable if options.delete(:polymorphic)
        options[:class_name] ||= 'Comment'

        has_counter :comments,
                    :as => options[:as] || name.underscore

        has_counter :approved_comments,
                    :as => options[:as] || name.underscore,
                    :class_name => 'Comment',
                    :after_create => false,
                    :after_destroy => false

        with_options options do |c|
          c.has_many :comments, :dependent => :delete_all do
            def by_author(author)
              find_all_by_author_id_and_author_type(author.id, author.class.name)
            end
            def last_one
              find :last
            end
          end
          c.has_many :approved_comments, :conditions => ["comments.approved = ? AND comments.commentable_type <> 'Topic'", 1], :class_name => 'Comment'
          c.has_many :unapproved_comments, :conditions => ["comments.approved = ? AND comments.commentable_type <> 'Topic'", 0], :class_name => 'Comment'
          # c.has_one  :recent_comment, :order => "comments.created_at DESC"
        end

        include InstanceMethods
      end

      def has_many_comments?
        included_modules.include? ActiveRecord::HasManyComments::InstanceMethods
      end
    end

    module InstanceMethods
      def after_comment_update(comment)
        comments_counter.decrement!          if comment.frozen?
        approved_comments_counter.increment! if comment.just_approved?
        approved_comments_counter.decrement! if comment.frozen? or comment.just_unapproved?
        
        owner.after_comment_update(comment)  if owner and owner.respond_to?(:after_comment_update)
      end
    end
  end
end
