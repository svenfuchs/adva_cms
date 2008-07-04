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
  
  When "the user visits the new section page" do
    get "/admin/sites/#{@site.to_param}/sections/new"
  end
  
  When "the user visits the section's show page" do
    get "/admin/sites/#{@site.to_param}/sections/#{@section.to_param}"
  end
  
  When "the user fills in the section creation form with valid values" do
    chooses 'Section'
    fills_in 'title', :with => 'a new section title'
  end
  
  Then "the page has a section creation form" do
    action = "/admin/sites/#{@site.to_param}/sections"
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the page has a section edit form" do
    @section = Section.find :first
    action = "/admin/sites/#{@section.site.to_param}/sections/#{@section.to_param}"
    response.should have_tag('form[action=?]', action) do |form|
      form.should have_tag('input[name=?][value=?]', '_method', 'put')
    end
  end
  
  Then "the user is redirected the section's show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/sections/[\d]*)
    response.should render_template('admin/sections/show')
  end
  
  Then "a new Section is created" do
    Section.count.should == 1
  end
end