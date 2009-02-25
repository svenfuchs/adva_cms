ActionController::Dispatcher.to_prepare do
  Site.has_many :assets, :order => 'assets.created_at desc', :dependent => :destroy do
    def recent
      find(:all, :limit => 6)
    end
  end
end