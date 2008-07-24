class SectionsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  
  before_filter :set_article
  before_filter :guard_view_permissions, :only => :show

  caches_page_with_references :show, :track => ['@article']
  
  authenticates_anonymous_user
  acts_as_commentable

  def show
    render @section.render_options
  end
  
  protected
  
    def set_section
      @section = params[:section_id].blank? ? @site.sections.root : @site.sections.find(params[:section_id])
      raise SectionRoutingError.new("Section must be a Section: #{@section.inspect}") unless @section.is_a? Section
    end
  
    def set_article
      if params[:permalink].blank?
        @article = @section.articles.primary
      else
        @article = @section.articles.find_by_permalink params[:permalink], :include => :author
        raise ActiveRecord::RecordNotFound unless @article
      end
    end
    
    def guard_view_permissions
      if @article && @article.draft?
        guard_permission(:update, :article)
        @skip_caching = true
      end
    end
    
    def current_role_context
      @article || @section
    end
    
    # experimental ... not sure if that's a good idea, but it would reduce quite 
    # some routes, i.e. even increase performance
    # def process(*args)
    #   forward_polymorphic(*args) or super
    # end
  
    # def forward_polymorphic(request, *args)
    #   if id = request.parameters[:id] || request.parameters[:section_id]
    #     section = Section.find(id)
    #     unless section.instance_of?(Section)
    #       controller = "#{section.type.classify}Controller".constantize
    #       return controller.process(request, *args)
    #     end
    #   end
    # end
end
