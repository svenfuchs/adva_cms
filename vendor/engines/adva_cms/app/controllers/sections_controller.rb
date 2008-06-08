class SectionsController < BaseController
  before_filter :set_article

  caches_page_with_references :show, :track => ['@article']
  
  authenticates_anonymous_user
  acts_as_commentable

  def show
    render @section.render_options
  end
  
  protected
  
    def set_section
      @section = params[:id].blank? ? @site.sections.root : @site.sections.find(params[:id])
      raise SectionRoutingError.new("Section must be a Section: #{@section.inspect}") unless @section.is_a? Section
    end
  
    def set_article
      @article = if params[:permalink].blank?
        @section.articles.primary
      else
        @section.articles.find_published_by_permalink params[:permalink]
      end
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
