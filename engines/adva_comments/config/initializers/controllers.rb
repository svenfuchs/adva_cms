ActionController::Dispatcher.to_prepare do
  BaseController.class_eval do
    helper :comments

    def comments # FIXME why isn't this in acts_as_commentable ?
      @comments = @commentable.approved_comments
      respond_to do |format|
        format.atom { render :template => 'comments/comments', :layout => false }
      end
    end
  end
  
  Admin::BaseController.helper :comments, :'admin/comments'
end