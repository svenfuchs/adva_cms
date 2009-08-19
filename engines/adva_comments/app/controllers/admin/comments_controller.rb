class Admin::CommentsController < Admin::BaseController
  layout "admin"

  before_filter :set_comments, :only => :index
  before_filter :set_comment, :only => [:edit, :update, :destroy]
  before_filter :set_commentable, :set_comment_params, :only => :create
  after_filter :postback_spaminess, :only => [:update]

  cache_sweeper :comment_sweeper, :only => [:create, :update, :destroy]
  guards_permissions :comment

  def update
    if @comment.update_attributes params[:comment]
      trigger_events @comment
      flash[:notice] = t(:'adva.comments.flash.update.success')
      redirect_to params[:return_to] || admin_site_comments_url
    else
      flash.now[:error] = t(:'adva.comments.flash.update.failure')
      render :action => :edit
    end
  end

  def destroy
    @comment.destroy
    trigger_events @comment
    flash[:notice] = t(:'adva.comments.flash.destroy.success')
    redirect_to params[:return_to] || admin_site_comments_url
  end

  private

    def set_menu
      @menu = Menus::Admin::Comments.new
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
      # FIXME how to remove the Topic dependency here? 
      # maybe make Comment a subclass of Comment::Base or something so that we can use STI to exclude 
      # special comment types?
      collection = source.comments.scoped(:conditions => ['commentable_type NOT IN (?)', 'Topic'])

      options = { :page => current_page, :per_page => 25, :order => 'created_at.id DESC' }
      @comments = collection.filtered(params[:filters]).paginate filter_options 
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
        @site.spam_engine.mark_spaminess(spaminess, @comment, :url => show_url(@comment.commentable))
      end
    end

    def current_resource
      @comment ? @comment.commentable : @content || @section || @site
    end
end

