ActionController::Dispatcher.to_prepare do
  Category.class_eval do
    def all_contents_with_set
      section.class.to_s == 'Album' ? scope_by_set : all_contents_without_set
    end
    alias_method_chain :all_contents, :set # this is soooo 2008 ;-)

    def scope_by_set
      Photo.scoped(:include => :sets, :conditions => ["categories.lft >= ? AND categories.rgt <= ?", lft, rgt])
    end
  end
end