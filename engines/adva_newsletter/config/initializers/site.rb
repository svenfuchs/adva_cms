ActionController::Dispatcher.to_prepare do
  Site.has_many :newsletters, :dependent => :destroy, :class_name => "Adva::Newsletter"
end
