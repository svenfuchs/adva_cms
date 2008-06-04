define Section do
  instance :root
end

define User do
  instance :admin
end

define ApiKey do
  instance :default
end

define Site do
  has_many :sections, [:find, :build, :root] => stub_section,
                      [:paginate] => stub_sections
  belongs_to :user
  has_one :api_key
    
  methods  [:save, :destroy] => true,
           :next => stub_site(:another),
           :active? => true
  
  instance :site,
           :id => 1,
           :name => 'site'
  
  instance :another,
           :id => 2,
           :name => 'another'
end

scenario :site do
  @site = stub_site(:site)
end