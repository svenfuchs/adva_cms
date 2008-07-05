factories :sections

steps_for :section do
  Given "a section" do
    @section = create_section
  end
  
  Given "a site with a Section" do
    Site.delete_all
    Section.delete_all
    @site = create_site
    @section = create_section :site => @site, :type => 'Section'
  end
  
  Given "a site with no sections" do
    Site.delete_all
    Section.delete_all
    @site = create_site
  end
  
  When "the user visits the admin section creation page" do
    get new_admin_section_path(@site)
  end
  
  When "the user visits the admin section show page" do
    get admin_section_path(@section.site, @section)
  end
  
  When "the user fills in the admin section creation form with valid values" do
    chooses 'Section'
    fills_in 'title', :with => 'a new section title'
  end
  
  Then "a new Section was created with the title 'a new section title'" do
    @section = Section.find_by_title 'a new section title'
    @section.should_not be_nil
  end
  
  Then "the page has an admin section creation form" do
    action = admin_sections_path(@site)
    response.should have_form_posting_to(action)
  end
  
  Then "the page has an admin section edit form" do
    action = admin_section_path(@site, @section)
    response.should have_form_putting_to(action)
  end
  
  Then "the user is redirected to the admin section show page" do
    request.request_uri.should == admin_section_path(@site, @section)
    response.should render_template('admin/sections/show')
  end
end