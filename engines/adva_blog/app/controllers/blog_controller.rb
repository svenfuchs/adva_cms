class BlogController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles
  
  before_filter :set_category, :set_tags, :only => :index
  before_filter :set_articles, :only => :index
  before_filter :set_article, :only => :show
  before_filter :guard_view_permissions, :only => :show

  caches_page_with_references :index, :show, :comments,
    :track => ['@article', '@articles', '@category', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]
  # TODO move :comments and @commentable to acts_as_commentable
    
  authenticates_anonymous_user
  acts_as_commentable

  def index
    respond_to do |format|
      format.html { render } # @section.render_options TODO breaks specs on Rails 2.2
      format.atom { render :layout => false }
    end
  end

  def show
    respond_to do |format|
      format.html { render } # @section.render_options TODO breaks specs on Rails 2.2
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
        skip_caching!
      end
    end

    def current_resource
      @article || @section
    end
end
