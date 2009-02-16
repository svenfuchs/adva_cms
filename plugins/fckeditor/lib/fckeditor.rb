class Fckeditor
  def self.load!
    # load FCKeditor
    register_javascript_expansion :admin  => ['fckeditor/fckeditor/fckeditor.js', 'fckeditor/setup_fckeditor.js']
  end
end