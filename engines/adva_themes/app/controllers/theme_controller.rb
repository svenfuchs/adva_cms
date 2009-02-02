class ThemeController < ApplicationController
  before_filter :set_file, :only => :file
  after_filter :cache_file, :only => :file

  def file
    if @file.text?
      headers['Content-Type'] = @file.content_type
      render :text => @file.data
    else
      send_data @file.data, :filename => @file.basename.to_s, :type => @file.content_type, :disposition => 'inline'
    end
  end

  def error
    render :nothing => true, :status => 404
  end

private

  def set_file
    theme = find_theme or return error
    @file = if params[:file].first == 'preview.png'
      theme.preview
    else
      theme.files.find Theme::File.to_id(params.values_at(:type, :file))
    end or return error
  end

  def find_theme
    if params[:subdir]
      Theme.find(params[:theme_id], params[:subdir])
    else
      site = Site.find_by_host(request.host_with_port)
      site.themes.find(params[:theme_id])
    end
  end

  def cache_file
    self.class.cache_page response.body, request.request_uri
  rescue
    STERR.puts "Cache Exception: #{$!}"
  end
end


