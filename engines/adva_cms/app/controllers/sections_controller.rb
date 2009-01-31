class SectionsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods

  before_filter :set_article
  before_filter :guard_view_permissions, :only => :show

  # TODO move :comments and @commentable to acts_as_commentable
  caches_page_with_references :show, :comments, :track => ['@article', '@commentable']

  authenticates_anonymous_user
  acts_as_commentable

  def show
    # render @section.render_options TODO breaks specs on Rails 2.2
  end

  protected

    def set_section; super(Section); end
    
    def set_article
      @article = params[:permalink] ? 
                 @section.articles.find_by_permalink(params[:permalink], :include => :author) :
                 @section.articles.primary

      if !@article or (!@article.published? and !has_permission?('update', 'article'))
        # the article was not found OR (the article was not published AND user not allowed to view the article)
        raise ActiveRecord::RecordNotFound
      end
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
end
