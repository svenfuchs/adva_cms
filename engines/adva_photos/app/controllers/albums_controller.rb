class AlbumsController < BaseController
  include ActionController::GuardsPermissions::InstanceMethods
  
  before_filter :set_section
  before_filter :set_set, :set_tags, :set_photos, :only => :index
  before_filter :set_photo,                       :only => :show
  before_filter :guard_view_permissions,          :only => :show
  
  authenticates_anonymous_user
  acts_as_commentable
  
  def index
  end
  
  def show
  end
  
  protected
    def set_photos
      options = { :order => 'created_at DESC', :conditions => 'published_at NOT NULL', :page => current_page, :tags => @tags }
      options[:limit] = request.format == :html ? @section.photos_per_page : 15
      # TODO i think a very expensive way to handle this one ;) .. throw away thing for now
      source = @set ? @section.photos.collect {|photo| photo if photo.sets.include?(@set) } : @section.photos
      @photos = source.paginate options
    end

    def set_photo
      @photo = @section.photos.find params[:photo_id], :include => :author
    end

    def set_set
      if params[:set_id]
        @set = @section.sets.find params[:set_id]
        raise ActiveRecord::RecordNotFound unless @set
      end
    end

    def set_tags
      if params[:tags]
        names = params[:tags].split('+')
        @tags = Tag.find(:all, :conditions => ['name IN(?)', names]).map(&:name)
        raise ActiveRecord::RecordNotFound unless @tags.size == names.size
      end
    end

    def guard_view_permissions
      unless @photo.published?
        guard_permission(:update, :article)
        @skip_caching = true
      end
    end
end