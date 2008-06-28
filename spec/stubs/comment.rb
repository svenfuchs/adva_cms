define Comment do
  belongs_to :author, stub_user
  # belongs_to :commentable
  
  methods  :id => 1,
           :body => 'body', 
           :body_html => 'body html',
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :created_at => Time.now,
           :approved? => true,
           :update_attributes => true,
           :save => true,
           :destroy => true,
           :has_attribute? => true,
           :frozen? => false,
           :role_authorizing => Role.build(:author),
           :commentable= => nil

  instance :comment
end