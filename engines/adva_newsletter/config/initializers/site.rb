ActionController::Dispatcher.to_prepare do
  Site.has_many :newsletters, :dependent => :destroy
  Site.has_many :deleted_newsletters
end