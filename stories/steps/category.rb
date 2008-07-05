factories :sections
steps :blog

steps_for :category do  
  Given "a blog with a category" do
    Category.delete_all
    Section.delete_all
    @blog = create_blog
    @category = create_category :section => @blog
  end

  Given "a blog with no categories" do
    Category.delete_all
    Section.delete_all
    @blog = create_blog
  end
  
  When "the user visits the blog's categories list page" do
    get admin_categories_path(@blog.site, @blog)
  end
  
  When "the user visits the blog category's edit page" do
    get edit_admin_category_path(@blog.site, @blog, @category)
  end
  
  When "the user fills in the category creation form with valid values" do
    fills_in 'title', :with => 'a new category title'
  end
  
  Then "the user sees the blog categories list page" do
    request.request_uri.should == admin_categories_path(@blog.site, @blog)
    response.should render_template('admin/categories/index')
  end
  
  Then "the page has a category creation form" do
    action = admin_categories_path(@blog.site, @blog)
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the page has a category edit form" do
    action = admin_category_path(@blog.site, @blog, @category)
    response.should have_form_putting_to(action)
  end

  Then "the user is redirected the blog categories list page" do
    request.request_uri.should == admin_categories_path(@blog.site, @blog)
    response.should render_template('admin/categories/index')
  end

  Then "the user is redirected the blog category's edit page" do
    request.request_uri.should == edit_admin_category_path(@blog.site, @blog, @category)
    response.should render_template('admin/categories/edit')
  end
  
  Then "the page has a list of blog categories with the new category listed" do
    response.should have_tag('#categories', 'a new category title')
  end
end