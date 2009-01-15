define Asset do
  belongs_to :site
  has_many :contents #, :through => :asset_assignments
  has_many :asset_assignments #, :order => 'position', :dependent => :delete_all
  
  methods  :id => 1,
           :content_type => "text/plain",
           :filename => "test.txt",
           :public_filename => "public filename",
           :size => 123,
           :thumbnail => nil,
           :width => nil,
           :height => nil,
           :title => "test file",
           :thumbnails_count => 0,
           :created_at => Date.today,
           :save => true,
           :save! => true,
           :update_attributes => true,
           :update_attributes! => true,
           :destroy => true,
           :track_method_calls => nil

  instance :asset
end
