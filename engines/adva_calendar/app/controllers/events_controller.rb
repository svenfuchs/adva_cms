class EventsController < BaseController
  before_filter :set_section
  before_filter :set_timespan
  before_filter :set_category, :only => [:index]
  before_filter :set_tags, :only => [:index]
  before_filter :set_event, :except => [:index, :new]

  authenticates_anonymous_user
  acts_as_commentable

  caches_page_with_references :index, :show, :track => ['@event', '@events', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
  cache_sweeper :calendar_event_sweeper, :tag_sweeper, :category_sweeper, :only => [:create, :update, :destroy]

  def index
    # a bit restricting, I know
    if @category 
      @events = @section.events.by_categories(@category.id).paginate(:page => params[:page])
    else
      @events = @section.events.elapsed.paginate({:page => params[:page]}).becomes(Event) if params[:elapsed]
      @events = @section.events.recent.paginate({:page => params[:page]}) if params[:recent] and @events.blank?
      @events ||=  @section.events.upcoming(@timespan).paginate({:page => params[:page]})
    end
    respond_to do |format|
      format.html { render }
      format.ics { render :layout => false }
    end
  end

  def show
    respond_to do |format|
      format.html { render }
      format.ics { render :layout => false }
    end
  end

  private

    def set_section; super(Calendar); end

    def set_timespan
      return @timespan = [Date.today, nil] if params[:year].blank?
      y = params[:year].to_i
      m = params[:month].to_i
      d = params[:day].to_i
      if m == 0 and d == 0
        @timespan = Date.new(y)
        @timespan = [@timespan, @timespan.end_of_year]
      elsif m > 0 and d == 0
        @timespan = Date.new(y, m)
        @timespan = [@timespan, @timespan.end_of_month]
      elsif m > 0 and d > 0
        @timespan = Date.new(y, m, d)
        @timespan = [@timespan, @timespan.end_of_day]
      end
    end

    def set_category
      if params[:category_id]
        @category = @section.categories.find params[:category_id]
        raise ActiveRecord::RecordNotFound unless @category
      end
    end

    def set_event
      @event = @section.events.find_by_id params[:id]
      @event ||= @section.events.find_by_permalink params[:id]
      raise "could not find event '#{params[:id]}'" unless @event
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def set_author_params
      params[:event][:author] = current_user ? current_user : nil if params[:event]
    end

    def current_role_context
      @event || @section
    end
end
