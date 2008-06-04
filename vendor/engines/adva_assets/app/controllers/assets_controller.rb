class AssetsController < ApplicationController
  session :off
  caches_page_with_references :show
  def show
    file         = Pathname.new([params[:path], params[:ext]] * '.')
    content_type = site.resources.content_type(file)
    resource     = site.resources[file.to_s]

    if !resource.file?
      show_404
    elsif site.resources.image?(file)
      send_data resource.read, :filename => resource.basename.to_s, :type => content_type, :disposition => 'inline'
    else
      headers['Content-Type'] = content_type
      render :text => resource.read
    end
  end
end
