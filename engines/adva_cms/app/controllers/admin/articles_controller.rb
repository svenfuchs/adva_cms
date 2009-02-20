class Admin::ArticlesController < Admin::BaseController
  layout "admin"
  helper 'admin/comments', 'assets', 'roles'

  # before_filter :admin_required
  # member_actions.push *%W(index show new destroy create)

  before_filter :set_section
  before_filter :set_article,         :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories,      :only => [:new, :edit]
  before_filter :set_content_locale,  :only => [:new, :edit, :create, :update]
  before_filter :params_author,       :only => [:create, :update]
  before_filter :params_draft,        :only => [:create, :update]
  before_filter :params_published_at, :only => [:create, :update]
  before_filter :params_category_ids, :only => [:update]

  cache_sweeper :article_sweeper, :category_sweeper, :tag_sweeper,
                :only => [:create, :update, :destroy]

  guards_permissions :article, :update => :update_all

  # TODO remove this dependency from here and put it into the plugin
  cache_sweeper :article_ping_observer, :only => [:create, :update]

  def index
    @articles = @section.articles.paginate article_options
    template = @section.type == 'Section' ? 'admin/articles/index' : "admin/#{@section.type.downcase}/index"
    render :template => template
  end

  def show
    @article.revert_to params[:version] if params[:version]
    subdir = @section.type == 'Section' ? 'sections' : @section.type.downcase
    # render @section.render_options(:action => :show, :layout => 'default').merge(:template => "#{subdir}/show")
    render :template => "#{subdir}/show", :layout => 'default'
  end

  def new
    @article = @section.articles.build :comment_age => @section.comment_age, :filter => @section.content_filter
  end

  def edit
  end

  def create
    current_locale = I18n.locale
    I18n.locale = @content_locale
    @article = @section.articles.build(params[:article])
    success = @article.save
    I18n.locale = current_locale

    if success
      trigger_events @article
      flash[:notice] = t(:'adva.articles.flash.create.success')
      redirect_to edit_admin_article_path(:id => @article.id, :cl => @content_locale)
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
      redirect_to edit_admin_article_path( :cl => @content_locale )
    else
      set_categories
      flash.now[:error] = t(:'adva.articles.flash.update.failure')
      render :action => 'edit', :cl => @content_locale
    end
  end
  
  def rollback
    version = params[:article][:version].to_i
    if @article.version != version and @article.revert_to(version)
      trigger_event @article, :rolledback
      flash[:notice] = t(:'adva.articles.flash.rollback.success', :version => version)
      redirect_to edit_admin_article_path( :cl => @content_locale )
    else
      flash[:error] = t(:'adva.articles.flash.rollback.failure', :version => version)
      redirect_to edit_admin_article_path( :cl => @content_locale )
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
  
    def set_section; super; end

    def set_article
      @article = @section.articles.find params[:id]
    end

    def set_categories
      @categories = @section.categories.roots
    end

    def set_content_locale
      @content_locale = params[:cl] || I18n.locale      
    end
    
    def params_author
      # FIXME - shouldn't we pass params[:article][:author_id] instead?
      author = User.find(params[:article][:author]) if params[:article][:author]
      author ||= current_user
      set_article_param(:author, author) or raise "author and current_user not set"
    end

    def params_category_ids
      default_article_param :category_ids, []
    end

    def params_draft
      set_article_param :published_at, nil if save_draft?
    end

    def params_published_at
      date = Time.extract_from_attributes!(params[:article], :published_at, :local)
      set_article_param :published_at, date if date && !save_draft?
    end

    def save_with_revision?
      @save_revision ||= !!params.delete(:save_revision)
    end

    def save_draft?
      params[:draft] == '1'
    end

    def set_article_param(key, value)
      params[:article] ||= {}
      params[:article][key] = value
    end

    def default_article_param(key, value)
      params[:article] ||= {}
      params[:article][key] ||= value
    end
    
    def article_options
      # TODO params[:per_page] ??
      options = {:page => current_page, :per_page => params[:per_page], :order => 'contents.position, contents.id DESC'}
      options.reverse_merge(filter_options)
    end

    def filter_options
      options = {}
      case params[:filter]
      when 'category'
        options[:joins] = "#{options[:joins]} INNER JOIN categorizations ON contents.id = categorizations.categorizable_id AND categorizations.categorizable_type = 'Content'"
        condition = Article.send(:sanitize_sql, ['categorizations.category_id = ?', params[:category].to_i])
        options[:conditions] = options[:conditions] ? "(#{options[:conditions]}) AND (#{condition})" : condition
      when 'title'
        options[:conditions] = Content.send(:sanitize_sql, ["LOWER(contents.title) LIKE ?", "%#{params[:query].downcase}%"])
      when 'body'
        options[:conditions] = Content.send(:sanitize_sql, ["LOWER(contents.excerpt) LIKE :query OR LOWER(contents.body) LIKE :query", {:query => "%#{params[:query].downcase}%"}])
      when 'tags'
        tags = TagList.new(params[:query], :parse => true)
        options[:joins] = "INNER JOIN taggings ON taggings.taggable_id = contents.id and taggings.taggable_type = 'Content' INNER JOIN tags on taggings.tag_id = tags.id"
        options[:conditions] = Content.send(:sanitize_sql, ["tags.name IN (?)", tags])
      when 'draft'
        options[:conditions] = 'published_at is null'
      end
      options
    end

    def current_resource
      @article || @section
    end

    def expire_cached_pages_by_reference(record, method = nil)
      expire_pages CachedPage.find_by_reference(record, method)
    end
end

