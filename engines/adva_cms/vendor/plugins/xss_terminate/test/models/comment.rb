# Commet uses the default: stripping tags fro all fields.
class Comment < ActiveRecord::Base
  belongs_to :entry
  belongs_to :person
end
