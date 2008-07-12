class CommentsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :content
  helper_method :has_permission?

  authenticates_anonymous_user
  layout 'default'
  
  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  
  before_filter :set_comment, :only => [:show, :update]
  before_filter :set_commentable, :only => [:show, :preview, :create]
  before_filter :set_comment_params, :only => [:preview, :create]
  
  def show
    has_permission?(:update, :comment)
  end

  def preview
    @comment = @commentable.comments.build params[:comment]
    @comment.send :process_filters
    render :layout => false
  end
  
  def create
    # params[:comment].delete(:approved) # TODO use attr_protected api
    @comment = @commentable.comments.build(params[:comment])
    if @comment.save
      @comment.check_spam content_url(@comment.commentable), {:authenticated => authenticated?}
      flash[:notice] = "Thank you for your comment!"
      redirect_to comment_path(@comment)
    else
      flash[:error] = @comment.errors.full_messages.to_sentence
      render :action => :show
    end
  end
  
  def update
    # params[:comment].delete(:approved) # TODO use attr_protected api
    if @comment.update_attributes params[:comment]
      flash[:notice] = "Thank you for your comment!"
      redirect_to comment_path(@comment)
    else
      set_commentable
      flash[:error] = @comment.errors.full_messages.to_sentence
      render :action => :show
    end
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
        params[:comment][:commentable_type].constantize.find(params[:comment][:commentable_id]) 
        # params[:commentable][:type].constantize.find(params[:commentable][:id]) rescue nil
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