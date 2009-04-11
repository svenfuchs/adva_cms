module Admin::PhotosHelper
  def link_to_delete_set(set)
    link_to_delete(set, :url => admin_set_path(set.section.site, set.section, set), :confirm => :'adva.photos.admin.sets.delete_confirmation')
  end
end