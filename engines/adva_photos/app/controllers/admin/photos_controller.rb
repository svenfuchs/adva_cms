class Admin::PhotosController < Admin::BaseController
  layout 'admin'
  before_filter :set_section
  
  def index
    @photos = @section.photos.paginate photo_paginate_options
  end
  
  def new
    @photo = @section.photos.build :comment_age => @section.comment_age, :filter => @section.content_filter
  end
  
  protected
    def photo_paginate_options
      {:page => params[:page], :order => 'created_at DESC'}
    end
end