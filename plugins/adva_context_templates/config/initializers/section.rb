class SectionFormBuilder < ExtensibleFormBuilder
  before(:section, :submit_buttons) do |f|
    unless @section.type == 'Forum'
      render :partial => 'admin/sections/template_settings', :locals => { :f => f } 
    end
  end
end