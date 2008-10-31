class BlogController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods

  before_filter :set_category, :set_tags, :only => :index
  before_filter :set_articles, :only => :index
  before_filter :set_article, :only => :show
  before_filter :guard_view_permissions, :only => :show

  caches_page_with_references :index, :show,
    :track => ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
  authenticates_anonymous_user
  acts_as_commentable

  def index
    respond_to do |format|
      format.html { render @section.render_options }
      format.atom { render :layout => false }
    end
  end

  def show
    respond_to do |format|
      format.html { render @section.render_options }
    end
  end

  protected

    def set_section; super(Blog); end

    def set_articles
      options = { :page => current_page, :tags => @tags }
      options[:limit] = request.format == :html ? @section.articles_per_page : 15
      source = @category ? @category.contents : @section.articles
      @articles = source.paginate_published_in_time_delta params[:year], params[:month], options
    end

    def set_article
      @article = @section.articles.find_by_permalink params[:permalink], :include => :author
      if !@article || is_archived? || !@article.published? && !can_preview?
        raise ActiveRecord::RecordNotFound
      end
    end

    def set_category
      if params[:category_id]
        @category = @section.categories.find params[:category_id]
        raise ActiveRecord::RecordNotFound unless @category
      end
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def set_commentable
      set_article if params[:permalink]
      super
    end
    
    def can_preview?
      has_permission?('update', 'article')
    end
    
    def is_archived?
      @article.published? && !@article.published_at?(params.values_at(:year, :month, :day))
    end

    def guard_view_permissions
      unless @article.published?
        guard_permission(:update, :article)
        @skip_caching = true
      end
    end

    def current_role_context
      @article || @section
    end
end
