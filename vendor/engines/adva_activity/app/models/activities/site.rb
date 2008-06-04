module Activities
  module Site
    include_into 'Site'

    def self.included(base)
      base.class_eval do
        has_many :activities, :dependent => :destroy
      end
    end
  end
end
