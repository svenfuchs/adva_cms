module ActiveRecord
  module HasManyComments
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_comments(options = {})
        # return if has_many_comments? # would not work for Section < Content which both have_many_comments

        options[:order] = 'comments.created_at, comments.id'
        options[:class_name] ||= 'Comment'

        has_counter :comments,
                    :as => options[:as]

        has_counter :approved_comments,
                    :as => options[:as],
                    :class_name => 'Comment',
                    :callbacks => { 
                      :after_approve   => :increment!, 
                      :after_unapprove => :decrement!, 
                      :after_destroy  => :decrement! 
                    }

        options.delete(:as) unless options[:as] == :commentable
        with_options options do |c|
          c.has_many :comments, :dependent => :delete_all do
            def by_author(author)
              find_all_by_author_id_and_author_type(author.id, author.class.name)
            end
          end
          c.has_many :approved_comments,   :conditions => ["comments.approved = ?", 1] 
          c.has_many :unapproved_comments, :conditions => ["comments.approved = ?", 0]
        end

        include InstanceMethods
      end

      def has_many_comments?
        included_modules.include? ActiveRecord::HasManyComments::InstanceMethods
      end
    end

    module InstanceMethods
    end
  end
end
ActiveRecord::Base.send :include, ActiveRecord::HasManyComments
