site = Site.find_by_name('site with pages')
ContactMail.create :site    => site,
                   :subject => 'Hi!',
                   :body    => 'How are you doing?'