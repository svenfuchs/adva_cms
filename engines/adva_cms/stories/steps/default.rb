steps_for :default do
  When "the user goes to the url $path" do |path|
    get path
  end

  When "the user fills in the anonymous name and email fields" do
    fill_in 'user[name]', :with => 'anonymous'
    fill_in 'user[email]', :with => 'anonymous@email.org'
  end
  
  When "the user fills in the anonymous name and email fields with incorrect data" do
    fill_in 'user[name]', :with => ''
    fill_in 'user[email]', :with => 'anonymous@email'
  end

  Then "the $object's $name is set to '$value'" do |object, name, value|
    object = instance_variable_get("@#{object.downcase}")
    object.reload
    object.send(name).to_s.should == value
  end

  Then "the $object's comments are set to 'Never expire'" do |object|
    object = instance_variable_get("@#{object.downcase}")
    object.reload
    object.comment_age.should == 0
  end

  Then "the page shows '$text'" do |text|
    response.should have_text(%r(#{text})i)
  end

  Then "the page does not show '$text'" do |text|
    response.should_not have_text(text)
  end

  Then "the page shows the $template template" do |template|
    response.should render_template(template)
  end

  Then "the page has an empty list" do
    response.should have_tag("div.empty")
  end

  Then "the form contains anonymous name and email fields" do
    @form.should have_tag('input[name=?]', 'user[name]')
    @form.should have_tag('input[name=?]', 'user[email]')
  end

  Then "the form does not contain anonymous name and email fields" do
    @form.should_not have_tag('input[name=?]', 'user[name]')
    @form.should_not have_tag('input[name=?]', 'user[email]')
  end

  Then "the user is redirected to the url $url" do |url|
    url = login_url(:return_to => request.url) if url == ':login'
    response.should redirect_to(url)
  end

  Then "the request does not succeed" do
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

  Then "the 'Save as draft?' checkbox is checked by default" do
    response.should have_tag("input#article-draft[type=?][value=?]", 'checkbox', 1)
  end

  Then "the page should not have '$link' link" do |link|
    response.should_not have_tag("a", link)
  end

  Then "the page should have '$link' link" do |link|
    response.should have_tag("a", link)
  end
end
