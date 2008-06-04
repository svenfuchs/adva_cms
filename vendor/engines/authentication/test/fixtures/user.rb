class User < ActiveRecord::Base
  acts_as_authenticated_user
end