class EventsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles

  before_filter :set_section
  before_filter :set_category, :only => [:index]
  before_filter :set_tags, :only => [:index]
  before_filter :set_event, :except => [:index, :new]

  authenticates_anonymous_user
  acts_as_commentable

  caches_page_with_references :index, :show, :track => ['@event', '@events', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
  cache_sweeper :calendar_event_sweeper, :tag_sweeper, :category_sweeper, :only => [:create, :update, :destroy]

  def index
    if %w(elapsed recently_added).include?(params[:scope])
      source = @section.events.published.send(params[:scope])
    end
    source ||= @section.events.published.upcoming(current_timespan)
    if %w(title body).include?(params[:filter])
      @events = source.search(params[:query], params[:filter]).paginate({:page => params[:page]})
    elsif params[:filter] == 'tags' and not params[:query].blank?
      @events = source.paginate_tagged_with(params[:query], :page => params[:page])
    else
      if @category 
        @events = source.by_categories(@category.id).paginate(:page => params[:page])
      else
        @events ||= source.paginate(:page => params[:page])
      end
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

    # future extensions may use something like params[:from] params[:to]
    # but for now we only assume the end of year, month or day
    attr_accessor :current_timespan_format
    helper_method :current_timespan_format
    helper_method :current_timespan
    def current_timespan
      return @current_timespan if @current_timespan
      return @current_timespan = [Date.today, nil] if params[:year].blank?
      y = params[:year].to_i
      m = params[:month].to_i
      d = params[:day].to_i
      puts y([y,m,d])
      if m == 0 and d == 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year')
        @current_timespan = Date.new(y)
        @current_timespan = [@current_timespan, @current_timespan.end_of_year]
      elsif m > 0 and d == 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year_month')
        @current_timespan = Date.new(y, m)
        @current_timespan = [@current_timespan, @current_timespan.end_of_month]
      elsif m > 0 and d > 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year_month_day')
        @current_timespan = Date.new(y, m, d)
        @current_timespan = [@current_timespan, @current_timespan.end_of_day]
      end
    end

    def set_category
      if params[:category_id]
        @category = @section.categories.find params[:category_id]
        raise ActiveRecord::RecordNotFound unless @category
      end
    end

    def set_event
      @event = @section.events.published.find_by_id params[:id]
      @event ||= @section.events.published.find_by_permalink params[:id]
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
