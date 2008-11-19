# This class exists so including the Rails HTML sanitization helpers doesn't polute your models.
class RailsSanitize
  include ActionView::Helpers::SanitizeHelper
  
  class << self
    include ActionView::Helpers::SanitizeHelper::ClassMethods
  end
end