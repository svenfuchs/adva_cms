class ForumsController < BaseController
  before_filter :set_topics, :only => :show
  # caches_page_with_references :show, :track => ['@article']
  
  authenticates_anonymous_user
  acts_as_commentable

  def show
    # beast does this. does that make sense? i hate to save stuff to the session. it breaks rest.
    # also, doesn't work with page_caching
    # (session[:forums] ||= {})[@forum.id] = Time.now.utc
    # (session[:forums_page] ||= Hash.new(1))[@forum.id] = current_page if current_page > 1
    render @section.render_options
  end
  
  protected
  
    def set_section
      super
      raise SectionRoutingError.new("Section must be a Forum: #{@section.inspect}") unless @section.is_a? Forum
    end
  
    def set_topics
      @topics = @section.topics.paginate :page => current_page, 
                                         :per_page => @section.articles_per_page, # TODO
                                         :include => :last_post
    end
end
