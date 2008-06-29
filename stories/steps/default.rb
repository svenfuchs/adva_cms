steps_for :default do
  When "the user GETs $path" do |path|
    get path
  end
  
  Then "the page shows $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should have_text(text)
  end  
  
  Then "the page does not show $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should_not have_text(/#{text}/i)
  end
  
  Then "the page has a form posting to $action" do |action|
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the page does not have a form posting to $action" do |action|
    response.should_not have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the $template template is rendered" do |template|
    response.should render_template(template)
  end
  
  Then "the user is redirected to $url" do |url|
    response.should redirect_to(url)
  end
  
  Then "an error message is shown" do |url|
    response.should_not be_success
  end
end