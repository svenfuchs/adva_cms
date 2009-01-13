factories :sections, :wikipages

steps_for :wiki do
  Given "a wiki" do
    @wiki ||= begin
      Given 'a site'
      Given "no wikipage"
      Section.delete_all
      Category.delete_all
      create_wiki :site => @site
    end
  end

  Given "a wiki that allows anonymous users to create and update wikipages" do
    Given "a wiki"
    @wiki.update_attributes! 'permissions' => { 
      'create wikipage' => 'anonymous', 'create comment' => 'anonymous',
      'update wikipage' => 'anonymous', 'create comment' => 'anonymous'
    }
  end

  Given "a wiki that allows registered users to create and update wikipages" do
    Given "a wiki"
    @wiki.update_attributes! 'permissions' => { 
      'create wikipage' => 'user', 'create comment' => 'user',
      'update wikipage' => 'user', 'create comment' => 'user'
    }
  end

  Given "a wikipage" do
    Given "a wiki"
    Given "no wikipage"
    @wikipage = create_wikipage
    @wikipage_versions_count = 1
  end

  Given "a home wikipage" do
    Given "a wiki"
    Given "no wikipage"
    @wikipage = create_wikipage :title => 'Home', :body => 'the home wikipage body'
  end

  Given "no wikipage" do
    Wikipage.delete_all
    Wikipage::Version.delete_all
  end

  Given "a wikipage that has a revision" do
    Given "a wiki"
    Given "no wikipage"
    @wikipage = create_wikipage :body => 'the old wikipage body'
    @wikipage.update_attributes! :body => 'the wikipage body'
    @wikipage_versions_count = 2
  end

  When "the user visits the wikipage page" do
    get wikipage_path(@wiki, @wikipage.permalink)
  end

  When "the user visits the wiki home page" do
    get wiki_path(@wiki)
  end

  When "the user visits the wikipage edit page" do
    get edit_wikipage_path(@wiki, @wikipage.permalink)
  end

  When "the user visits the wikipage revision page" do
    get wikipage_rev_path(@wiki, @wikipage.permalink, 1)
  end

  When "the user tries to update the wikipage with valid parameters" do
    valid_data = {:updated_at => "2008-01-01 12:00:00 UTC", :title => "the wikipage title", :body => "the wikipage body" }
    put wikipage_path(@wiki, @wikipage.permalink), :wikipage => valid_data
  end

  Then "a new version of the wikipage is created" do
    @wikipage.reload
    @wikipage.versions.count.should == @wikipage_versions_count + 1
  end

  Then "the page has a wikipage creation form" do
    action = '/pages' # TODO for some reason wikipages_path(@wiki) is not a root wiki path here
    response.should have_form_posting_to(action)
    @form = css_select 'form[action=?]', action
  end

  Then "the page has a wikipage edit form" do
    action = wikipage_path(@wiki, @wikipage)
    response.should have_form_putting_to(action)
    @form = css_select 'form[action=?]', action
  end

  Then "the page has a link for rolling back the wikipage" do
    path = wikipage_path(@wiki, @wikipage.permalink, :version => 1)
    response.should have_tag('a[href=?]', path, /rollback/)
  end
end
