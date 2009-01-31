module ActiveRecord
  module HasManyComments
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_comments(options = {})
        return if has_many_comments?

        options[:as] = :commentable if options.delete(:polymorphic)
        options[:order] = 'comments.created_at'
        options[:class_name] ||= 'Comment'

        has_counter :comments,
                    :as => options[:as] || name.underscore

        has_counter :approved_comments,
                    :as => options[:as] || name.underscore,
                    :class_name => 'Comment',
                    :after_create => false,
                    :after_destroy => false
        
        has_many_comments_associations(options)

        include InstanceMethods
      end
        
      def has_many_comments_associations(options = {})
        options[:order] = 'comments.created_at, comments.id'
        options[:class_name] ||= 'Comment'

        with_options options do |c|
          c.has_many :comments, :dependent => :delete_all do
            def by_author(author)
              find_all_by_author_id_and_author_type(author.id, author.class.name)
            end
            def last_one
              find :last
            end
          end
          
          # FIXME why do we overwrite the class_name option here? shouldn't we 
          # use the one that was passed with the options hash?
          # FIXME can we remove the Topic dependency here? just ignore it because
          # there's no concept of approving comments in the Forum?
          condition = "comments.approved = ? AND comments.commentable_type <> 'Topic'"
          c.has_many :approved_comments,   :conditions => [condition, 1], :class_name => 'Comment'
          c.has_many :unapproved_comments, :conditions => [condition, 0], :class_name => 'Comment'
          
          # FIXME why is this on the Forum and not here?
          # c.has_one  :recent_comment, :order => "comments.created_at DESC"
        end
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
