factories :sections
steps :blog

steps_for :category do  
  Given "no blog category" do
    Category.delete_all
  end
  
  When "the user visits the blog's categories list page" do
    get "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/categories"
  end
  
  When "the user fills in the category creation form with valid values" do
    fills_in 'title', :with => 'a new category title'
  end
  
  Then "the page has an empty list of blog categories" do
    response.should have_tag('div[class=?]', 'empty')
  end
  
  Then "the page has a category creation form" do
    action = "/admin/sites/#{@blog.site.to_param}/sections/#{@blog.to_param}/categories"
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end

  Then "the user is redirected the blog's categories list page" do
    webrat_session.current_page.url.should =~ %r(/admin/sites/[\d]*/sections/[\d]*/categories)
  end
  
  Then "the page has a list of blog categories with the new category listed" do
    response.should have_tag('#content #categories', 'a new category title')
  end
end