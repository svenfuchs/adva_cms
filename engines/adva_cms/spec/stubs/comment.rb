define Comment do
  belongs_to :author, stub_user
  # belongs_to :commentable
  belongs_to :board

  methods  :id => 1,
           :board= => nil,
           :body => 'body',
           :body_html => 'body html',
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :created_at => Time.now,
           :approved? => true,
           :just_approved? => true,
           :update_attributes => true,
           :attributes= => nil,
           :valid? => true,
           :save => true,
           :destroy => true,
           :has_attribute? => true,
           :frozen? => false,
#           :role_authorizing => Rbac::Role.build(:author, :context => stub_comment),
           :commentable= => nil,
           :check_approval => false,
           :approved_changed? => false,
           :track_method_calls => nil

  instance :comment
end
