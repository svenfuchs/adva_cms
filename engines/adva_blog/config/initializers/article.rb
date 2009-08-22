ActionController::Dispatcher.to_prepare do
  Article.class_eval do
    def full_permalink
      raise "cannot create full_permalink for an article that belongs to a non-blog section" unless section.is_a?(Blog)
      # raise "can not create full_permalink for an unpublished article" unless published?
      date = [:year, :month, :day].map { |key| [key, (published? ? published_at : created_at).send(key)] }.flatten
      Hash[:permalink, permalink, *date]
    end
  end
end