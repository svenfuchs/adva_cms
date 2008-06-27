class CommentsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper_method :has_permission?

  authenticates_anonymous_user
  layout 'default'
  
  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  
  before_filter :set_comment, :only => :show
  before_filter :set_commentable, :only => [:show, :preview, :create]
  before_filter :set_comment_params, :only => [:preview, :create]
  
  def show
    has_permission?(:update, :comment)
    # p current_user
    # p @comment.role_authorizing(:update, :comment)
  end

  def preview
    @comment = @commentable.comments.build params[:comment]
    @comment.send :process_filters
    render :layout => false
  end
  
  def create
    @comment = @commentable.comments.build(params[:comment])
    if @comment.save
      flash[:notice] = "Thank you for your comment!"
      redirect_to comment_path(@comment)
      # render :action => :show
    else
      flash[:comment] = params[:comment]
      flash[:error] = @comment.errors.full_messages.to_sentence
      redirect_to params[:return_to]
    end
  end
  
  def update
    # TODO temporarily allow to edit a comment based on the cookie
    # params[:comment].delete(:approved)
  end
  
  def destroy
  end
  
  protected
  
    def set_comment
      @comment = Comment.find params[:id]
    end

    def set_commentable
      @commentable = if @comment
        @comment.commentable
      else
        params[:commentable][:type].constantize.find(params[:commentable][:id]) rescue nil
      end
      raise ActiveRecord::RecordNotFound unless @commentable
    end
  
    def set_comment_params
      params[:comment].merge! :site_id => @commentable.site_id, 
                              :section_id => @commentable.section_id,
                              :author => current_user
    end 
    
    def current_role_context
      @comment || @commentable
    end
end