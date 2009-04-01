class EventsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles

  before_filter :set_section
  before_filter :set_category, :only => [:index]
  before_filter :set_tags, :only => [:index]
  before_filter :set_event, :except => [:index, :new]

  authenticates_anonymous_user
  acts_as_commentable

  # TODO move :comments and @commentable to acts_as_commentable
  caches_page_with_references :index, :show, :comments,
    :track => ['@event', '@events', '@category', '@commentable', { '@site' => :tag_counts, '@section' => :tag_counts }]

  def index
    # FIXME: it's not too nice to pass in the section but somehow it doesn't work via the association proxy
    search_params = params.slice(:scope, :filter, :category_id, :query).merge(:timespan => current_timespan, :section => @section)
    @events = CalendarEvent.find_published_by_params(search_params).paginate(:page => params[:page])

    respond_to do |format|
      format.js do
        render :update do |page|
          page.select('.calendar_cell .calendar').each do |calendar|
            page.replace calendar.getAttribute('id'), :partial => 'calendar', :locals => { :calendar_section => @section }
          end
        end
      end
      format.html
      format.ics
    end
  end

  def show
    respond_to do |format|
      format.html
      format.ics
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
      y, m, d = params[:year].to_i, params[:month].to_i, params[:day].to_i

      if m == 0 and d == 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year')
        date = Date.new(y)
        @current_timespan = [date.beginning_of_year, date.end_of_year]
      elsif m > 0 and d == 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year_month')
        date = Date.new(y, m)
        @current_timespan = [date.beginning_of_month, date.end_of_month]
      elsif m > 0 and d > 0
        @current_timespan_format = t(:'adva.calendar.titles.formats.year_month_day')
        date = Date.new(y, m, d)
        @current_timespan = [date.beginning_of_day, date.end_of_day]
      end
    end

    def set_category
      if params[:category_id]
        @category = @section.categories.find params[:category_id]
        raise ActiveRecord::RecordNotFound unless @category
      end
    end

    def set_event
      @event = @section.events.published.find_by_permalink params[:permalink]
      if !@event || (@event.draft? && !can_preview?)
        raise ActiveRecord::RecordNotFound
      end
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def can_preview?
      has_permission?('update', 'article')
    end

    def current_resource
      @event || @section
    end
end
