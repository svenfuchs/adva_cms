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
    get "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/categories"
  end
  
  When "the user visits the blog category's edit page" do
    get "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/categories/#{@category.to_param}/edit"
  end
  
  When "the user fills in the category creation form with valid values" do
    fills_in 'title', :with => 'a new category title'
  end
  
  Then "the user sees the blog categories list page" do
    webrat_session.current_page.url.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/categories)
    response.should render_template('admin/categories/index')
  end
  
  Then "the page has a category creation form" do
    action = "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/categories"
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the page has a category edit form" do
    action = "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/categories/#{@category.to_param}"
    response.should have_tag('form[action=?]', action) do |form|
      form.should have_tag('input[name=?][value=?]', '_method', 'put')
    end
  end

  Then "the user is redirected the blog categories list page" do
    webrat_session.current_page.url.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/categories)
    response.should render_template('admin/categories/index')
  end

  Then "the user is redirected the blog category's edit page" do
    webrat_session.current_page.url.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/categories/[\d]*/edit)
    response.should render_template('admin/categories/edit')
  end
  
  Then "the page has a list of blog categories with the new category listed" do
    response.should have_tag('#categories', 'a new category title')
  end
end