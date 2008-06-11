class CommentsController < ApplicationController
  authenticates_anonymous_user
  include CacheableFlash
  
  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  
  with_options :only => [:preview, :create] do |c|
    before_filter :set_commentable
    before_filter :set_comment_params
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
      redirect_to params[:return_to]
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

    def set_commentable
      @commentable = params[:commentable][:type].constantize.find params[:commentable][:id]
      # TODO raise if params[:commentable][:type] not set
      # TODO raise if commentable not found
    end
  
    def set_comment_params
      params[:comment].merge! :site_id => @commentable.site_id, 
                              :section_id => @commentable.section_id,
                              :author => current_user
    end 
end