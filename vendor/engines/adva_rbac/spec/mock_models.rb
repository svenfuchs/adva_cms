# # class Account < ActiveRecord::Base
# #   acts_as_role_context
# #   attr_accessor :permissions
# # end
# 
# class Site < ActiveRecord::Base
#   acts_as_role_context :actions => ["manage themes", "manage assets"]
#                        #:parent => Account
# 
#   #belongs_to :account
# end
# 
# class Section < ActiveRecord::Base
#   acts_as_role_context :actions => ["create article", "update article", "delete article"],
#                        :parent => Site
# 
#   belongs_to :site
# end
# 
# class Content < ActiveRecord::Base
#   acts_as_role_context :parent => Section
# 
#   belongs_to :section
# end
# 
# class Comment < ActiveRecord::Base
#   acts_as_role_context :parent => Content
# 
#   belongs_to :content
# end
# 
# class Board < ActiveRecord::Base
#   acts_as_role_context :parent => Section
# end
# 
# class User < ActiveRecord::Base
#   #belongs_to :account
#   has_many :roles, :class_name => 'Rbac::Role::Base'
# 
#   def has_role?(role, options = {})
#     role = Rbac::Role.build role, options unless role.is_a? Rbac::Role::Base
#     role.granted_to? self
#   end
# 
#   # def has_exact_role?(name, object = nil)
#   #   role = Role.build(name, object)
#   #   role.exactly_granted_to? self
#   # end
# end
