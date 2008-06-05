class Admin::CommentsController < Admin::BaseController
  layout "admin"

  before_filter :set_section, :set_content, :set_filter
  before_filter :set_contents, :set_comments, :only => :index
  before_filter :set_comment, :only => [:show, :edit, :update, :destroy]        
  before_filter :set_commentable, :set_comment_params, :only => :create
  
  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  
  def show
    @reply = Comment.new :commentable_type => @comment.commentable_type,
                         :commentable_id => @comment.commentable_id
  end
  
  # def create
  #   @comment = @commentable.comments.build params[:comment]
  #   if @comment.save
  #     flash[:notice] = "The comment has been saved."
  #     redirect_to params[:redirect_to]
  #   else
  #     @reply, @comment = @comment, @section.comments.find(params[:comment_id])      
  #     flash.now[:error] = "The comment could not be saved."
  #     render :action => :show
  #   end
  # end
  
  def update
    if @comment.update_attributes params[:comment]
      flash[:notice] = "The comment has been updated."
      redirect_to params[:redirect_to]
    else
      flash.now[:error] = "The comment could not be updated."
      render :action => :edit
    end
  end
  
  def destroy
    if @comment.destroy
      flash[:notice] = "The comment has been deleted."
      redirect_to params[:redirect_to] || admin_site_comments_path
    else
      flash[:error] = "The comment could not be deleted."
      redirect_to params[:redirect_to]
    end
  end
  
  private
  
    def set_section
      @section = Section.find(params[:section_id]) if params[:section_id]
    end
    
    def set_contents
      source = @section || @site
      @contents = source.unapproved_comments.group_by(&:commentable)
    end
  
    def set_content
      @content = Content.find(params[:content_id]) if params[:content_id]
    end
  
    def set_commentable
      type, id = params[:comment].values_at(:commentable_type, :commentable_id)
      @commentable = type.constantize.find id
    end
  
    def set_comment_params
      params[:comment].merge! :site_id => @commentable.site_id, 
                              :section_id => @commentable.section_id,
                              :author => current_user
    end
    
    def set_comments
      source = @content || @section || @site
      collection = source.send params[:filter] != 'all' ? "#{params[:filter]}_comments" : 'comments'
      options = {:page => current_page, :per_page => params[:per_page], :order => 'created_at DESC'}
      @comments = collection.paginate options
    end

    def set_comment
      source = @section || @site
      @comment = source.comments.find(params[:id])
    end
    
    def set_filter
      params[:filter] ||= 'all'
    end
end

