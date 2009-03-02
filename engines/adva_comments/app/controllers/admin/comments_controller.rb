class Admin::CommentsController < Admin::BaseController
  layout "admin"

  before_filter :set_section, :set_content
  before_filter :set_contents, :set_comments, :only => :index
  before_filter :set_comment, :only => [:show, :edit, :update, :destroy]
  before_filter :set_commentable, :set_comment_params, :only => :create
  after_filter :postback_spaminess, :only => [:update]

  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :comment

  def index
  end

  def show
    @reply = Comment.new :commentable_type => @comment.commentable_type,
                         :commentable_id => @comment.commentable_id
  end

  # def create
  #   @comment = @commentable.comments.build params[:comment]
  #   if @comment.save
  #     flash[:notice] = t(:'adva.comments.flash.create.success')
  #     redirect_to params[:return_to]
  #   else
  #     @reply, @comment = @comment, @section.comments.find(params[:comment_id])
  #     flash.now[:error] = t(:'adva.comments.flash.create.failure')
  #     render :action => :show
  #   end
  # end

  def update
    if @comment.update_attributes params[:comment]
      trigger_events @comment
      flash[:notice] = t(:'adva.comments.flash.update.success')
      redirect_to params[:return_to]
    else
      flash.now[:error] = t(:'adva.comments.flash.update.failure')
      render :action => :edit
    end
  end

  def destroy
    @comment.destroy
    trigger_events @comment
    flash[:notice] = t(:'adva.comments.flash.destroy.success')
    redirect_to params[:return_to] || admin_site_comments_path
  end

  private

    def set_section
      @section = @site.sections.find(params[:section_id]) if params[:section_id]
      super 
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
      collection = source.comments
      @comments = collection.paginate filter_options 
    end

    def set_comment
      source = @section || @site
      @comment = source.comments.find(params[:id])
    end
    
    def filter_options
      options = {:page => current_page, :per_page => params[:per_page], :order => 'created_at DESC'}
      case params[:filter]
      when 'state'
        params[:state] == 'approved' ? options[:conditions] = "approved = '1'" : options[:conditions] = "approved = '0'"
      when 'body'
        options[:conditions] = Comment.send(:sanitize_sql, ["LOWER(body) LIKE :query", {:query => "%#{params[:query].downcase}%"}])
      when 'author_name'
        options[:conditions] = Comment.send(:sanitize_sql, ["LOWER(author_name) LIKE :query", {:query => "%#{params[:query].downcase}%"}])
      when 'author_email'
        options[:conditions] = Comment.send(:sanitize_sql, ["LOWER(author_email) LIKE :query", {:query => "%#{params[:query].downcase}%"}])
      when 'author_homepage'
        options[:conditions] = Comment.send(:sanitize_sql, ["LOWER(author_homepage) LIKE :query", {:query => "%#{params[:query].downcase}%"}])
      end
      options
    end

    def postback_spaminess
      if @comment.approved_changed? and @site.respond_to?(:spam_engine)
        spaminess = @comment.approved? ? :ham : :spam
        @site.spam_engine.mark_spaminess spaminess, content_url(@comment.commentable), @comment
      end
    end

    def current_resource
      @comment ? @comment.commentable : @content || @section || @site
    end
end

