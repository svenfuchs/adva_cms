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

  Given "a section with no articles" do
    Given "a section"
    @section.articles.should be_empty
  end

  Given "a section with an article" do
    Article.delete_all
    Given "a section"
    @article = create_article
    @article.section = @section
    @article.save!
  end

  Given "the section commenting is set to 'Never expire'" do
    raise "this step expects the variable @section to be set" unless @section
    @section.comment_age = 0
    @section.save!
  end

  When "the user visits the admin section creation page" do
    get new_admin_section_path(@site)
  end

  When "the user visits the admin section edit page" do
    get edit_admin_section_path(@site, @section)
  end
  
  When "the user visits the admin section comments page" do
    get admin_site_comments_path(@section.site, :section_id => @section.id)
  end

  When "the user fills in the admin section creation form with valid values" do
    chooses 'Section'
    fills_in 'title', :with => 'a new section title'
  end

  When "the user goes to the section url on frontend" do
    raise "step expects the variable @section to be set" unless @section
    get "/#{@section.permalink}"
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

  Then "the user is redirected to the admin section's contents page" do
    request.request_uri.should == controller.admin_section_contents_path(@section)
    response.should render_template('admin/articles/index')
  end

  Then "the user is redirected to the admin section's edit page" do
    request.request_uri.should == controller.send(:edit_admin_section_path, @section.site, @section)
    response.should render_template('admin/sections/edit')
  end
end
