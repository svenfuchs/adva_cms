require 'admin/asset_tag_helper'

module Admin
  module AssetsHelper
    def asset_image_for(asset, style = :tiny, options = {})
      image_tag(*asset_image_args_for(asset, style, options))
    end

    def asset_image_args_for(asset, style = :tiny, options = {})
      # thumb_size = Array.new(2).fill(Asset.attachment_options[:thumbnails][thumbnail].to_i).join('x')
      # options    = options.reverse_merge(:title => "#{asset.title} \n #{asset.tags.join(', ')}", :size => thumb_size)
      # if asset.movie?
      #   ['/images/adva_cms/icons/assets/video.png', options]
      # elsif asset.audio?
      #   ['/images/adva_cms/icons/assets/audio.png', options]
      # elsif asset.pdf?
      #   ['/images/adva_cms/icons/assets/pdf.png', options]
      # elsif asset.other?
      #   ['/images/adva_cms/icons/assets/doc.png', options]
      # elsif asset.thumbnails_count.zero?
      #   [asset.public_filename, options]
      # else
        [asset.base_url(style), options]
      # end
    end

    def upload_summary
      t(:'adva.assets.upload_summary', :count => @site.assets.count,
  		  :size => number_to_human_size(@site.assets.sum(:data_file_size) || 0))
    end
  end
end