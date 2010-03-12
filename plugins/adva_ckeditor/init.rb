ActionController::Dispatcher.to_prepare do
  Admin::BaseController.class_eval do
    content_for :head, :enable_ck_editor, :only => { :format => :html } do
      javascript_include_tag(:wysiwyg_editor, :cache => false) if Ckeditor.loaded?
    end
  end
end
