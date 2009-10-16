  class AlbumsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles, :photos

  before_filter :set_section
  before_filter :set_set, :set_tags, :set_photos, :only => :index
  before_filter :set_photo,                       :only => :show
  before_filter :guard_view_permissions,          :only => :show

  # TODO move :comments and @commentable to acts_as_commentable
  caches_page_with_references :index, :show, :comments,
    :track => ['@photo', '@photos', '@set', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]

  acts_as_commentable if Rails.plugin?(:adva_comments)
  authenticates_anonymous_user

  def index
    respond_to do |format|
      format.html
      # format.atom { render :layout => false }
    end
  end

  def show
    respond_to do |format|
      format.html
      # format.atom { render :layout => false }
    end
  end

  protected
    def set_section; super(Album); end

    def set_photos
      scope = @set ? @set.all_contents : @section.photos
      scope = scope.tagged(@tags) if @tags.present?
      limit = request.format == :html ? @section.photos_per_page : 15 # TODO: why?
      @photos = scope.published.paginate(:page => current_page, :limit => limit)
    end

    def set_photo
      @photo = @section.photos.find(params[:photo_id], :include => :author)
      raise ActiveRecord::RecordNotFound if !@photo || !@photo.published? && !can_preview?
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t(:'adva.photos.flash.photo.set_photo.failure')
      redirect_to album_url(@section)
    end

    def set_set
      @set = @section.sets.find(params[:set_id]) if params[:set_id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t(:'adva.photos.flash.photo.set_set.failure')
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t(:'adva.photos.flash.photo.set_tags.failure')
      @tags = nil
    end

    def can_preview?
      has_permission?('update', 'photo')
    end

    def guard_view_permissions
      unless @photo.published?
        guard_permission(:update, :photo)
        skip_caching!
      end
    end
end
