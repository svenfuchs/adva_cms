class ArticlesController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles

  before_filter :adjust_action
  before_filter :set_category, :only => :index
  before_filter :set_tags,     :only => :index
  before_filter :set_articles, :only => :index
  before_filter :set_article,  :only => :show
  before_filter :guard_view_permissions, :only => :show

  caches_page_with_references :index, :show, :comments,
    :track => ['@article', '@articles', '@category', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]
    # TODO move :comments and @commentable to acts_as_commentable

  authenticates_anonymous_user
  acts_as_commentable

  def index
    respond_to do |format|
      format.html { render "#{@section.type.tableize}/articles/index" }
      format.atom { render :layout => false }
    end
  end

  def show
    respond_to do |format|
      format.html { render "#{@section.type.tableize}/articles/show" }
    end
  end

  protected
    # adjusts the action from :index to :show when the current section is a Section 
    # and it doesn't have any articles
    def adjust_action
      if request.parameters['action'] == 'index' and single_mode?
        @action_name = @_params[:action] = request.parameters['action'] = 'show'
      end
    end

    def set_section; super(Section); end

    def set_articles
      options = { 
        :page  => current_page, 
        :tags  => @tags,
        :limit => (request.format == :html ? @section.contents_per_page : 15)
      }
      source = @category ? @category.contents : @section.articles
      @articles = @section.is_a?(Blog) ?
        source.paginate_published_in_time_delta(params[:year], params[:month], options) :
        source.paginate(options) # FIXME should use published scope
    end

    def set_article
      if params[:permalink]
        @article = @section.articles.find_by_permalink(params[:permalink], :include => :author)
        raise ActiveRecord::RecordNotFound unless valid_article?
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
    
    def valid_article?
      @article and (!@section.is_a?(Blog) or @article.published_at?(params.values_at(:year, :month, :day)))
    end

    def guard_view_permissions
      if @article && @article.draft?
        raise ActiveRecord::RecordNotFound unless has_permission?('update', 'article')
        skip_caching!
      end
    end

    def current_resource
      @article || @section
    end

    def single_mode?
      @section.type == 'Section' and @section.articles.empty?
    end
end
