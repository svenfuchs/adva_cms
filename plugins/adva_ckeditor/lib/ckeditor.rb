class Ckeditor
  class << self
    def load!
      # load CKeditor
      ActionView::Helpers::AssetTagHelper.register_javascript_expansion :wysiwyg_editor  => ['adva_ckeditor/ckeditor/ckeditor', 'adva_ckeditor/setup_ckeditor']
      @@loaded = true
    end

    def loaded?
      defined?(@@loaded) && @@loaded
    end
  end
end