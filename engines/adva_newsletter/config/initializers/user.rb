User.class_eval do
  has_many :subscriptions, :dependent => :destroy
end