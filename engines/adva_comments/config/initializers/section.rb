class SectionFormBuilder < ExtensibleFormBuilder
  before(:section, :submit_buttons) do |f|
    unless @section.type == 'Forum'
      render :partial => 'admin/sections/comments_settings', :locals => { :f => f } 
    end
  end
end