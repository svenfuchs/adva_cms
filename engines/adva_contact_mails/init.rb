config.to_prepare do
  Site.class_eval do
    has_many :contact_mails
  end
end