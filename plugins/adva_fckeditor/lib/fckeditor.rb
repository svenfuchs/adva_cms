class Fckeditor
  def self.load!
    # load FCKeditor
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion :admin  => ['adva_fckeditor/fckeditor/fckeditor.js', 'adva_fckeditor/setup_fckeditor.js']
  end
end