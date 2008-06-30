steps_for :default do
  When "the user GETs $path" do |path|
    get path
  end
  
  When "the user POSTs to" do |path, params|
    post path, params
  end
  
  When "the user PUTs to" do |path, params|
    put path, params
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
    @form = css_select('form[action=?][method=?]', action, 'post').first
    @form.should_not be_nil
  end
  
  Then "the page does not have a form posting to $action" do |action|
    response.should_not have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the form contains an input tag with $attributes" do |attributes|
    args = attributes.inject ['input'] do |args, (name, value)|
      args.first << "[#{name}=?]"
      args << value
    end
    css_select(@form, *args).should_not be_empty
  end  
  
  Then "the $template template is rendered" do |template|
    response.should render_template(template)
  end
  
  Then "the user is redirected to $url" do |url|
    response.should redirect_to(url)
  end
  
  Then "the request does not succeed" do |url|
    response.should_not be_success
  end
end