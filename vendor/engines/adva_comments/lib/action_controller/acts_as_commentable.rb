module ActionController
  module ActsAsCommentable
    def self.included(base)
      base.class_eval do 
        extend ActMacro
      end
    end

    module ActMacro
      def has_many_comments(options = {})
        return if has_many_comments?
        include InstanceMethods

        before_filter :set_commentable, :only => :comments
        before_filter :set_comment, :except => :comments
        helper :comments        
      end

      def has_many_comments?
        included_modules.include?(ActionController::ActsAsCommentable::InstanceMethods)
      end
    end

    module InstanceMethods
      def comments
        @comments = @commentable.approved_comments    
        respond_to do |format|
          format.atom do        
            render :template => 'comments/comments', :layout => false
          end
        end
      end
      
      protected      
      
        def set_comment
          @comment = Comment.new params[:comment] # || flash[:comment] # bad idea, as this would get cached
          # @comment.user = current_user if respond_to? :current_user
          @comment.author = Anonymous.new
        end
    end
  end
end

