class Ckeditor
  def self.load!
    # load CKeditor
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion :wysiwyg_editor  => ['adva_ckeditor/ckeditor/ckeditor', 'adva_ckeditor/setup_ckeditor']
  end
end