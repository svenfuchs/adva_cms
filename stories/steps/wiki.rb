factories :sections, :wikipages

steps_for :wiki do  
  Given "a wiki" do
    Section.delete_all
    @wiki = create_wiki
  end
  
  Given "a wiki that allows anonymous users to create and update wikipages" do
    Section.delete_all
    @wiki = create_wiki
    @wiki.update_attributes! 'permissions' => {'wikipage' => {'create' => 'anonymous', 'update' => 'anonymous'}}
  end
  
  Given "a wiki that allows registered users to create and update wikipages" do
    Section.delete_all
    @wiki = create_wiki
    @wiki.update_attributes! 'permissions' => {'wikipage' => {'create' => 'user', 'update' => 'user'}}
  end
  
  Given "a wikipage" do
    Wikipage.delete_all
    Wikipage::Version.delete_all
    @wikipage = create_wikipage
    @wikipage_versions_count = 1
  end
  
  Given "a home wikipage" do
    Wikipage.delete_all
    Wikipage::Version.delete_all
    @wikipage = create_wikipage :title => 'Home', :body => 'the home wikipage body'
  end
  
  Given "no wikipage" do
    Wikipage.delete_all
    Wikipage::Version.delete_all
  end
  
  Given "a wikipage that has a revision" do
    Wikipage.delete_all
    Wikipage::Version.delete_all
    @wikipage = create_wikipage :body => 'the old wikipage body'
    @wikipage.update_attributes! :body => 'the wikipage body'
    @wikipage_versions_count = 2
  end
  
  Then "a new version of the wikipage is created" do
    @wikipage.reload
    @wikipage.versions.count.should == @wikipage_versions_count + 1
  end
  
  Then "the page has a rollback link putting to the version number to $path" do |path|
    response.should have_tag('a[href=?]', "#{path}?version=1", /rollback/)
  end
  
  Then "the wikipage has the attributes $attributes" do |attributes| 
    @wikipage.reload
    attributes.each do |name, value|
      @wikipage.send(name).should == value
    end
  end
end  
