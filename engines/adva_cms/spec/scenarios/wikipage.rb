scenario :wikipage_exists do
  @wikipage = Wikipage.new :author => stub_user, :site => stub_site, :section => stub_section, :title => 'title', :body => 'body'
  stub_methods @wikipage, :new_record? => false, :save_version? => false
end

scenario :wikipage_created do
  stub_scenario :wikipage_exists
  stub_methods @wikipage, :new_record? => true
end

scenario :wikipage_revised do
  stub_scenario :wikipage_exists
  stub_methods @wikipage, :save_version? => true
end

scenario :wikipage_destroyed do
  stub_scenario :wikipage_exists
  stub_methods @wikipage, :frozen? => true
end
