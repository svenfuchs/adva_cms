# class Monitorship < ActiveRecord::Base
#   belongs_to :profile
#   belongs_to :topic
#   
#   validates_presence_of :profile_id, :topic_id
#   validate :uniqueness_of_relationship
#   before_create :check_for_inactive
#   
#   attr_accessible :profile_id, :topic_id
# 
# protected
#   def uniqueness_of_relationship
#     if self.class.exists?(:profile_id => profile_id, :topic_id => topic_id, :active => true)
#       errors.add_to_base("Cannot add duplicate profile/topic relation")
#     end
#   end
#   
#   def check_for_inactive
#     monitorship = self.class.find_by_profile_id_and_topic_id_and_active(profile_id, topic_id, false)
#     if monitorship
#       monitorship.active = true
#       monitorship.save
#       false
#     end
#   end
# end
