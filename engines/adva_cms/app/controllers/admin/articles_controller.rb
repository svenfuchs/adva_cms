class Admin::ArticlesController < Admin::BaseController
  default_param :article, :author_id, :only => [:create, :update], &lambda { current_user.id }

  before_filter :protect_single_article_mode
  before_filter :set_section
  before_filter :set_articles,   :only => [:index]
  before_filter :set_article,    :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]
  before_filter :optimistic_lock, :only => :update
  before_filter :set_current_content_locale, :only => [:new, :edit]
  
  cache_sweeper :article_sweeper, :category_sweeper, :tag_sweeper,
                :only => [:create, :update, :destroy]

  guards_permissions :article, :update => :update_all

  def index
  end

  def show
    @article.revert_to(params[:version]) if params[:version]
    render :template => "#{@section.type.tableize}/articles/show", :layout => 'default'
  end

  def new
    defaults = { :comment_age => @section.comment_age, :filter => @section.content_filter }
    @article = @section.articles.build(defaults.update(params[:article] || {}))
  end

  def edit
    @locale = params[:cl].to_sym if params[:cl]
  end

  def create
    @article = @section.articles.build(params[:article])
    if @article.save
      trigger_events(@article)
      flash[:notice] = t(:'adva.articles.flash.create.success')
      redirect_to edit_admin_article_url(:id => @article.id, :cl => content_locale)
    else
      set_categories
      flash.now[:error] = t(:'adva.articles.flash.create.failure')
      render :action => 'new'
    end
  end

  def update
    params[:article][:version].present? ? rollback : update_attributes
  end

  def update_attributes
    current_content_locale = params[:cl]
    @article.attributes = params[:article]

    if save_with_revision? ? @article.save : @article.save_without_revision
      trigger_events(@article)
      flash[:notice] = t(:'adva.articles.flash.update.success')
      redirect_to edit_admin_article_url(:cl => current_content_locale)
    else
      set_categories
      flash.now[:error] = t(:'adva.articles.flash.update.failure')
      render :action => 'edit', :cl => current_content_locale
    end
  end

  def rollback
    version = params[:article][:version].to_i

    if @article.version != version and @article.revert_to(version)
      trigger_event(@article, :rolledback)
      flash[:notice] = t(:'adva.articles.flash.rollback.success', :version => version)
      redirect_to edit_admin_article_url(:cl => content_locale)
    else
      flash[:error] = t(:'adva.articles.flash.rollback.failure', :version => version)
      redirect_to edit_admin_article_url(:cl => content_locale)
    end
  end

  def update_all
    # FIXME we currently use :update_all to update the position for a single object
    # instead we should either use :update_all to batch update all objects on this
    # resource or use :update. applies to articles, sections, categories etc.
    id, attributes = *params[:articles].collect { |id, data| [id, { :left_id => data[:left_id] }] }.first
    @section.articles.find(id).move_to(attributes)
    expire_cached_pages_by_reference(@section) # TODO should be in the sweeper
    render :text => 'OK'
  end

  def destroy
    if @article.destroy
      trigger_events(@article)
      flash[:notice] = t(:'adva.articles.flash.destroy.success')
      redirect_to admin_articles_url
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

    def set_menu
      @menu = Menus::Admin::Articles.new
    end

    def set_account
      @account = Site.find_by_id(params[:site_id]).account
    end

    def set_articles
      options = { :page => current_page, :per_page => 25 }
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

    # # adjusts the action from :index to :new or :edit when the current section and it doesn't have any articles
    # def adjust_action
    #   if params[:action] == 'index' and @section.try(:single_article_mode)
    #     if @section.articles.empty?
    #       action = 'new'
    #       params[:article] = { :title => @section.title }
    #     else
    #       action = 'edit'
    #       params[:id] = @section.articles.first.id
    #     end
    #     @action_name = @_params[:action] = request.parameters['action'] = action
    #   end
    # end

    def protect_single_article_mode
      if params[:action] == 'index' and @section.try(:single_article_mode)
        redirect_to @section.articles.empty? ?
          new_admin_article_url(@site, @section, :article => { :title => @section.title }) :
          edit_admin_article_url(@site, @section, @section.articles.first)
      end
    end
    
    def optimistic_lock
      return unless params[:article]
      
      unless updated_at = params[:article].delete(:updated_at)
        # TODO raise something more explicit here
        raise t(:'adva.articles.exception.missing_timestamp')
      end
      
      # We parse the timestamp of article too so we can get rid of those microseconds postgresql adds
      if @article.updated_at && (Time.zone.parse(updated_at) != Time.zone.parse(@article.updated_at.to_s))
        flash[:error] = t(:'adva.articles.flash.optimistic_lock.failure')
        render :action => :edit
      end
    end

    # FIXME move to the sweeper
    def expire_cached_pages_by_reference(record, method = nil)
      expire_pages CachedPage.find_by_reference(record, method)
    end

    def set_current_content_locale
      @locale = params[:cl].present? ? params[:cl].to_sym : I18n.locale.to_sym
    end
end

