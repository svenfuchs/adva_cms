class AlbumsController < BaseController
  def show
    @album = @site.sections.find(params[:section_id])
  end
end