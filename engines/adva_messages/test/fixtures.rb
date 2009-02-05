user      = User.find_by_first_name('user')
moderator = User.find_by_first_name('moderator')
admin     = User.find_by_first_name('admin')
superuser = User.find_by_first_name('superuser')

peeping_tom = User.create! :first_name => 'the peeping tom',
                           :email => 'the-peeping-tom@example.com',
                            :password => 'a password',
                            :verified_at => Time.now

another_site = Site.find_by_host('another-site.com')
another_site.users << peeping_tom

message =
Message.create! :sender     => user,
                :recipient  => moderator,
                :subject    => 'a message to the moderator subject',
                :body       => 'a message to the moderator body'
                                  
Message.create! :sender     => superuser,
                :recipient  => admin,
                :subject    => 'a message to the admin subject',
                :body       => 'a message to the admin body'
                
Message.create! :sender     => superuser,
                :recipient  => superuser,
                :subject    => 'a message to self subject',
                :body       => 'a message to self body'

reply = Message.reply_to(message)
reply.sender = moderator
reply.body   = 'a reply to the message'
reply.save!

