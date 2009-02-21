class Fckeditor
  def self.load!
    # load FCKeditor
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion :admin  => ['fckeditor/fckeditor/fckeditor.js', 'fckeditor/setup_fckeditor.js']
  end
end