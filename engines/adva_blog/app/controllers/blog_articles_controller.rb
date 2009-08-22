class BlogArticlesController < ArticlesController
  def index
    respond_to do |format|
      format.html { render :template => "#{@section.type.tableize}/articles/index" }
      format.atom { render :template => "#{@section.type.tableize}/articles/index", :layout => false }
    end
  end

  protected
    def set_section; super(Blog); end

    def set_articles
      scope = @category ? @category.all_contents : @section.articles
      scope = scope.tagged(@tags) if @tags.present?
      scope = scope.published(params[:year], params[:month])
      @articles = scope.paginate(:page  => current_page, :limit => @section.contents_per_page)
    end

    def valid_article?
      @article and (@article.draft? or @article.published_at?(params.values_at(:year, :month, :day)))
    end
end