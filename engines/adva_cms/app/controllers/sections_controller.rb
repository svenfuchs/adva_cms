class SectionsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods

  before_filter :set_articles
  before_filter :guard_view_permissions, :only => [:index, :show]

  caches_page_with_references :index, :show, :comments, 
    :track => ['@articles', '@article', '@commentable']
    # TODO move :comments and @commentable to acts_as_commentable

  authenticates_anonymous_user
  acts_as_commentable
  
  def index
    action = true ? 'show' : 'index' # Section.is_a_simple_page_displaying_a_single_article?
    render :action => action
  end

  def show
  end

  protected

    def set_section; super(Section); end
    
    def set_articles
      if false # Section.wants_to_display_multiple_articles?
        @articles = @section.articles
      elsif params[:permalink]
        @article = @section.articles.find_by_permalink(params[:permalink], :include => :author)
        raise ActiveRecord::RecordNotFound unless @article and can_view(@article)
      else
        @article = @section.articles.primary
      end
    end
    
    def can_view(article)
      article.published? or has_permission?('update', 'article')
    end

    def guard_view_permissions
      if @article && @article.draft?
        guard_permission(:update, :article)
        skip_caching!
      end
    end

    def current_resource
      @article || @section
    end
    
    # does not work for some reason ... would be nicer to "forward" requests
    # to another action though
    #
    # def process(request, response, method = :perform_action, *arguments)
    #   if request.parameters['action'] == 'show' and true # Section.acts_as_simple_page
    #     request.parameters['action'] = 'index'
    #   end
    #   super
    # end
end
