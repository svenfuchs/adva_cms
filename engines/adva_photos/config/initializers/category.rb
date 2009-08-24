ActionController::Dispatcher.to_prepare do
  Category.class_eval do
    def all_contents_with_set
      section.class.to_s == 'Album' ? Photo.by_set(self) : all_contents_without_set
    end
    alias_method_chain :all_contents, :set # this is soooo 2008 ;-)
  end
end