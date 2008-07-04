steps_for :default do
  Given "the user has POSTed to" do |path, params|
    post path, params
  end
  
  When "the user GETs $path" do |path|
    get path
  end
  
  When "the user POSTs to" do |path, params|
    post path, params
  end
  
  When "the user PUTs to" do |path, params|
    put path, params
  end

  # Then "the $actor sees the $resource show page" do |actor, resource|
  #   response.should render_template("#{resource.gsub(" ","_").pluralize}/show")
  # end
  
  Then "a new $klass is saved" do |klass|
    klass.classify.constantize.count.should == 1
  end
  
  Then "the $object's $name is: $value" do |object, name, value|
    object = instance_variable_get("@#{object}")
    object.reload
    object.send(name).should == value
  end
  
  Then "the page shows $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should have_text(text)
  end  
  
  Then "the page does not show $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should_not have_text(/#{text}/i)
  end
  
  Then "the page has an empty list" do
    response.should have_tag('div[class=?]', 'empty')
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