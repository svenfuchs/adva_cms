module ActionController
  module ActsAsCommentable
    def self.included(base)
      base.class_eval do 
        extend ActMacro
      end
    end

    module ActMacro
      def acts_as_commentable(options = {})
        return if acts_as_commentable?
        include InstanceMethods

        before_filter :set_commentable, :only => :comments
        before_filter :set_comment, :except => :comments
        helper :comments        
      end

      def acts_as_commentable?
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

