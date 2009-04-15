class Test::Unit::TestCase
  share :a_wiki do
    before do
      @section = Wiki.find_by_permalink 'a-wiki'
      @site = @section.site
      set_request_host!
    end
  end
  
  share :wikipage_optimistic_locking_passes do
    before do
      stub(@controller).optimistic_lock
    end
  end
  
  def valid_wikipage_params(user)
    { :title      => 'a wikipage',
      :body       => 'a wikipage body',
      :author_id  => user.id }
  end

  share :valid_wikipage_params do
    before do
      @params = { :wikipage => valid_wikipage_params(@user) }
    end
  end
  
  share :invalid_wikipage_params do
    before do
      @params = { :wikipage => valid_wikipage_params(@user).update(:title => '') }
    end
  end
  
  share :a_wikipage do
    before do 
      @wikipage = @section.wikipages.first
    end
  end
  
  share :the_wikipage_has_a_revision do
    before do 
      @wikipage.update_attributes! :body => "#{@wikipage.body} was revised"
    end
  end
  
  share :the_wikipage_does_not_have_a_revision do
    before do 
      # p @wikipage.versions
    end
  end
  
  share :no_wikipage do
    before do 
      @wikipage = @section.wikipages.clear
    end
  end
  
  share :a_wikipage_category do
    before do
      @category = @section.categories.first
    end
  end
  
  share :no_wikipage_category do
    before do
      @section.categories.clear
    end
  end
end