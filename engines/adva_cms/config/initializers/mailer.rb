ActionMailer::Base.class_eval do
  class << self
    def site(object)
      object = object.owner while object.owner && !object.is_a?(Site)
      object
    end
  end

  def site(object)
    self.site(object)
  end
end