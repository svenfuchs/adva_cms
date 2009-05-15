User.class_eval do
  has_many :subscriptions, :dependent => :destroy, :class_name => "Adva::Subscription"
end
