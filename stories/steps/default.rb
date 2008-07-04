steps_for :default do
  Given "the user has POSTed to" do |path, params|
    post path, params
  end
  
  When "the user GETs $path" do |path|
    get path
  end
  
  When "the user clicks on '$link'" do |link|
    clicks_link link
  end

  When "the user POSTs to" do |path, params|
    post path, params
  end
  
  When "the user PUTs to" do |path, params|
    put path, params
  end
 
  When "fills in '$field' with '$value'" do |field, value|
    fills_in field, :with => value
  end

  When "clicks the button '$button'" do |button|
    clicks_button button
  end

  # TODO hardcoded to the core
  When "the 'save as draft' checkbox is already checked" do
    response.should have_tag('input#article-draft[value=?]', 1)
  end
 
  Then "the page shows $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should have_text(text)
  end  
  
  Then "the page does not show $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should_not have_text(text)
  end
  
  Then "the page has a form posting to $action" do |action|
    @form = css_select('form[action=?][method=?]', action, 'post').first
    @form.should_not be_nil
  end
  
  Then "the page does not have a form posting to $action" do |action|
    response.should_not have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the page has a form putting to $action" do |action|
    @form = css_select('form[action=?]', action).first
    @form.should_not be_nil
    css_select(@form, 'input[name=?][value=?]', '_method', 'put').should_not be_empty
  end
  
  Then "the page does not have a form putting to $action" do |action|
    @form = css_select('form[action=?]', action).first
    css_select(@form, 'input[name=?][value=?]', '_method', 'put').should be_empty if @form
  end

  Then "the page has an empty list of articles" do
    response.should have_tag("div.empty")
  end
  
  Then "the form contains an input tag with $attributes" do |attributes|
    args = attributes.inject ['input'] do |args, (name, value)|
      args.first << "[#{name}=?]"
      args << value
    end
    css_select(@form, *args).should_not be_empty
  end
  
  Then "the form does not contain an input tag with $attributes" do |attributes|
    args = attributes.inject ['input'] do |args, (name, value)|
      args.first << "[#{name}=?]"
      args << value
    end
    css_select(@form, *args).should be_empty
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
  
  Then "the flash contains an error message" do 
    if flash = cookies['flash']
      flash = JSON.parse CGI::unescape(flash)
    end
    flash['error'].should_not be_nil
  end
  
  Then "the edit link is only visible for certain roles" do
    response.should have_tag('.visible-for a[href$=?]', 'edit')
  end
end
