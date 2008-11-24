factories :sections, :articles

steps_for :blog_category do
  When "the user visits the admin blog categories list page" do
    get admin_categories_path(@blog.site, @blog)
  end

  When "the user visits the admin blog category edit page" do
    get edit_admin_category_path(@blog.site, @blog, @category)
  end

  When "the user fills in the admin category creation form with valid values" do
    fills_in 'title', :with => 'a new category title'
  end

  Then "a new category has been saved" do
    Category.find_by_title('a new category title').should_not be_nil
  end

  Then "the user sees the admin blog categories list page" do
    request.request_uri.should == admin_categories_path(@blog.site, @blog)
    response.should render_template('admin/categories/index')
  end

  Then "the page has an admin category creation form" do
    action = admin_categories_path(@blog.site, @blog)
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end

  Then "the page has an admin category edit form" do
    action = admin_category_path(@blog.site, @blog, @category)
    response.should have_form_putting_to(action)
  end

  Then "the user is redirected the admin blog categories list page" do
    request.request_uri.should == admin_categories_path(@blog.site, @blog)
    response.should render_template('admin/categories/index')
  end

  Then "the user is redirected the admin blog category edit page" do
    request.request_uri.should == edit_admin_category_path(@blog.site, @blog, @category)
    response.should render_template('admin/categories/edit')
    puts response.body
  end

  Then "the page has a list of categories with the new category listed" do
    response.should have_tag('#categories', /a new category title/)
  end
end
