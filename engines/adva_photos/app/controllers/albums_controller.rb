class AlbumsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  helper :roles

  before_filter :set_section
  before_filter :set_set, :set_tags, :set_photos, :only => :index
  before_filter :set_photo,                       :only => :show
  before_filter :guard_view_permissions,          :only => :show

  # TODO move :comments and @commentable to acts_as_commentable
  caches_page_with_references :index, :show, :comments,
    :track => ['@photo', '@photos', '@set', '@commentable', {'@site' => :tag_counts, '@section' => :tag_counts}]

  authenticates_anonymous_user
  acts_as_commentable

  def index
    respond_to do |format|
      format.html { render }
      # format.atom { render :layout => false }
    end
  end

  def show
    respond_to do |format|
      format.html { render }
      # format.atom { render :layout => false }
    end
  end

  protected
    def set_section; super(Album); end

    def set_photos
      # TODO that condition part would clearly go to model...
      options = { :page => current_page, :tags => @tags, :conditions => ["published_at IS NOT NULL"], :order => 'published_at DESC' }
      options[:limit] = request.format == :html ? @section.photos_per_page : 15
      # TODO i think a very expensive way to handle this one ;) .. throw away thing for now
      source = @set ? @section.photos.collect {|photo| photo if photo.sets.include?(@set) } : @section.photos
      @photos = source.paginate options
    end

    def set_photo
      @photo = @section.photos.find params[:photo_id], :include => :author
      if !@photo || !@photo.published? && !can_preview?
        raise ActiveRecord::RecordNotFound
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Photo you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to album_path
    end

    def set_set
      if params[:set_id]
        @set = @section.sets.find params[:set_id]
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Set you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Tag you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
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