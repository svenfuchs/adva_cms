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
    theme = Theme.find(params[:theme_id], params[:subdir])
    @file = if params[:file].first == 'preview.png'
      theme.preview
    else
      theme.files.find Theme::File.to_id(params.values_at(:type, :file))
    end or raise "can not find file #{params[:file]} in theme #{theme.name}"
  end

  def cache_file
    self.class.cache_page response.body, request.request_uri
  rescue
    STERR.puts "Cache Exception: #{$!}"
  end
end


