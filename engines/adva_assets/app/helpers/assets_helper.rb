module AssetsHelper
  def asset_title_for(asset)
    asset.title.blank? ? asset.filename : asset.title
  end

  def asset_image_for(asset, thumbnail = :tiny, options = {})
    image_tag(*asset_image_args_for(asset, thumbnail, options))
  end

  def bucket_assets
    return [] unless session[:bucket]
    @bucket_assets ||= @site.assets.find session[:bucket].keys
  rescue ActiveRecord::RecordNotFound
    @bucket_assets = []
  end

  def asset_image_args_for(asset, thumbnail = :tiny, options = {})
    thumb_size = Array.new(2).fill(Asset.attachment_options[:thumbnails][thumbnail].to_i).join('x')
    options    = options.reverse_merge(:title => "#{asset.title} \n #{asset.tags.join(', ')}", :size => thumb_size)
    if asset.movie?
      ['/images/icons/video.png', options]
    elsif asset.audio?
      ['/images/icons/audio.png', options]
    elsif asset.pdf?
      ['/images/icons/pdf.png', options]
    elsif asset.other?
      ['/images/icons/doc.png', options]
    elsif asset.thumbnails_count.zero?
      [asset.public_filename, options]
    else
      [asset.public_filename(thumbnail), options]
    end
  end
end