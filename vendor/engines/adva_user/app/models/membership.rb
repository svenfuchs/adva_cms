class Membership < ActiveRecord::Base
  belongs_to :site
  belongs_to :user

  validates_uniqueness_of :site_id, :scope => :user_id

  # tentacle does this. is it a good idea to keep has_many :roles on the membership?
  # before_create :set_first_user_admin
  # def set_first_user_admin
  #   self.transaction do
  #     if group && group.members.count == 0
  #       self.admin = true
  #     end
  #   end
  # end
end