module ActiveRecord
  module ActsAsCommentable
    def self.included(base)
      base.extend ActMacro  
    end

    module ActMacro
      def acts_as_commentable(options = {})
        return if acts_as_commentable?
        
        write_inheritable_attribute :accept_comments?, options.delete(:accept_comments?) || true
        
        options.merge! :order => 'created_at', :class_name => 'Comment'
        options[:as] = :commentable if options.delete(:polymorphic)

        with_options options do |c|
          c.has_many :comments, :dependent => :delete_all
          c.has_many :approved_comments, :conditions => ['comments.approved = ?', 1]
          c.has_many :unapproved_comments, :conditions => ['comments.approved = ?', 0]          
        end
        
        include InstanceMethods
      end

      def acts_as_commentable?
        included_modules.include?(ActiveRecord::ActsAsCommentable::InstanceMethods)
      end
    end
  
    module InstanceMethods
      def approved_comments_count
        @approved_comments_count ||= approved_comments.count
      end
      
      # def accept_comments?
      #   @accept_comments ||= begin
      #     case accessor = self.class.read_inheritable_attribute(:accept_comments?) || :accept_comments?
      #       when Symbol then send(accessor)
      #       when Proc   then accessor.call(self)
      #       else accessor
      #     end
      #   end
      # end
    end
  end
end
