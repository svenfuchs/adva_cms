factories :sections, :wikipages

steps_for :wiki do  
  Given "a wikipage" do
    Wikipage.delete_all
    Wikipage::Version.delete_all
    @wikipage = create_wikipage
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
  
  Then "a new version of the wikipage is created" do
    Wikipage.find(@wikipage.id).versions.count.should == 2
  end
end  
