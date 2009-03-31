class Admin::ArticlesController < Admin::BaseController
  default_param :article, :author_id, :only => [:create, :update], &lambda { current_user.id }

  before_filter :adjust_action
  before_filter :set_section
  before_filter :set_articles,   :only => [:index]
  before_filter :set_article,    :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]

  cache_sweeper :article_sweeper, :category_sweeper, :tag_sweeper,
                :only => [:create, :update, :destroy]

  guards_permissions :article, :update => :update_all

  def index
    render :template => "admin/#{@section.type.tableize}/articles/index"
  end

  def show
    @article.revert_to params[:version] if params[:version]
    render :template => "#{@section.type.tableize}/articles/show", :layout => 'default'
  end

  def new
    defaults = { :comment_age => @section.comment_age, :filter => @section.content_filter }
    @article = @section.articles.build defaults.update(params[:article] || {})
  end

  def edit
  end

  def create
    p params
    @article = @section.articles.build(params[:article])
    if @article.save
      trigger_events @article
      flash[:notice] = t(:'adva.articles.flash.create.success')
      redirect_to edit_admin_article_path(:id => @article.id, :cl => content_locale)
    else
      set_categories
      flash.now[:error] = t(:'adva.articles.flash.create.failure')
      render :action => 'new'
    end
  end
  
  def update
    params[:article][:version].blank? ? update_attributes : rollback
  end

  def update_attributes    
    @article.attributes = params[:article]
    
    if save_with_revision? ? @article.save : @article.save_without_revision
      trigger_events @article
      flash[:notice] = t(:'adva.articles.flash.update.success')
      redirect_to edit_admin_article_path(:cl => content_locale)
    else
      set_categories
      flash.now[:error] = t(:'adva.articles.flash.update.failure')
      render :action => 'edit', :cl => content_locale
    end
  end
  
  def rollback
    version = params[:article][:version].to_i
  
    if @article.version != version and @article.revert_to(version)
      trigger_event @article, :rolledback
      flash[:notice] = t(:'adva.articles.flash.rollback.success', :version => version)
      redirect_to edit_admin_article_path(:cl => content_locale)
    else
      flash[:error] = t(:'adva.articles.flash.rollback.failure', :version => version)
      redirect_to edit_admin_article_path(:cl => content_locale)
    end
  end

  def update_all
    allowed = ['position']
    attrs = Hash[*params[:articles].collect do |id, pair|
       [id, Hash[*pair.select{|key, value| allowed.include?(key) }.flatten]]
    end.flatten]
    @section.articles.update attrs.keys, attrs.values
    expire_cached_pages_by_reference @section # TODO should be in the sweeper
    render :text => 'OK'
  end

  def destroy
    if @article.destroy
      trigger_events @article
      flash[:notice] = t(:'adva.articles.flash.destroy.success')
      redirect_to admin_articles_path
    else
      set_categories
      flash.now[:error] = t(:'adva.articles.flash.destroy.failure')
      render :action => 'edit'
    end
  end

  protected

    def current_resource
      @article || @section
    end

    def set_articles
      options = { :page => current_page, :per_page => 25, :order => 'contents.position, contents.id DESC' }
      @articles = @section.articles.filtered(params[:filters]).paginate options
    end

    def set_article
      @article = @section.articles.find(params[:id])
    end

    def set_categories
      @categories = @section.categories.roots
    end

    def save_with_revision?
      @save_revision ||= !!params.delete(:save_revision)
    end

    # adjusts the action from :index to :new or :edit when the current section and it doesn't have any articles
    def adjust_action
      if params[:action] == 'index' and @section.try(:single_article_mode)
        if @section.articles.empty?
          action = 'new'
          params[:article] = { :title => @section.title }
        else
          action = 'edit'
          params[:id] = @section.articles.first.id
        end
        @action_name = @_params[:action] = request.parameters['action'] = action
      end
    end

    # FIXME move to the sweeper
    def expire_cached_pages_by_reference(record, method = nil)
      expire_pages CachedPage.find_by_reference(record, method)
    end
end

