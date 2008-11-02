# == Schema Information
# Schema version: 10
#
# Table name: attachments
#
#  id           :integer       not null, primary key
#  size         :integer
#  content_type :string(255)
#  filename     :string(255)
#  height       :integer
#  width        :integer
#  parent_id    :integer
#  thumbnail    :string(255)
#  page_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Attachment < ActiveRecord::Base
  belongs_to :wikipage

  scope_out :parent, :conditions => ["parent_id IS ?", nil]

  has_attachment :storage => :file_system,
                 :thumbnails => { :thumb => [50, 50], :small => "100x100>", :large => "400x400>"},
                 :processor => :rmagick

end
