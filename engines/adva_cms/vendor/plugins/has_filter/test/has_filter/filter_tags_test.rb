require File.dirname(__FILE__) + '/../test_helper.rb'

module HasFilter
  class FilterTagsTest < ActiveSupport::TestCase
    include HasFilter
    include HasFilter::TestHelper

    def setup
      params = [{ :title       => { :scope => 'starts_with', :query => 'foo' },
                  :body        => { :scope => 'starts_with', :query => '' },
                  :excerpt     => { :scope => 'starts_with', :query => '' },
                  :tagged      => '', 
                  :selected    => 'title' },
                { :title       => { :scope => 'contains', :query => '' },
                  :body        => { :scope => 'contains', :query => 'bar' },
                  :excerpt     => { :scope => 'contains', :query => '' },
                  :tagged      => '', 
                  :selected    => 'body' },
                { :title       => { :scope => 'contains', :query => '' },
                  :body        => { :scope => 'contains', :query => '' },
                  :excerpt     => { :scope => 'contains', :query => '' },
                  :tagged      => 'baz', 
                  :selected    => 'tagged' },
                { :title       => { :scope => 'contains', :query => '' },
                  :body        => { :scope => 'contains', :query => '' },
                  :excerpt     => { :scope => 'contains', :query => '' },
                  :state       => [ :published ],
                  :tagged      => '', 
                  :selected    => 'state' },
                { :title       => { :scope => 'contains', :query => '' },
                  :body        => { :scope => 'contains', :query => '' },
                  :excerpt     => { :scope => 'contains', :query => '' },
                  :state       => [ :published ],
                  :tagged      => '', 
                  :categorized => [HasFilterCategory.first.id],
                  :selected    => 'categorized' }]

      @categories = HasFilterCategory.all
      view = ActionView::Base.new
      @html = HasFilterArticle.filter_chain.select(params).to_form_fields(view, :categories => @categories).join("\n")
    end

    test 'the chain has two fieldsets with filters' do
      assert_html @html, 'fieldset[class=set]', 5
    end

    test 'one fieldset has the :title filter selected, one has the :body, one has the :tagged filter selected (from params)' do
      assert_html @html, 'fieldset[class=set] select[id=selected_filter_0] option[value=title][selected=selected]'
      assert_html @html, 'fieldset[class=set] select[id=selected_filter_1] option[value=body][selected=selected]'
      assert_html @html, 'fieldset[class=set] select[id=selected_filter_2] option[value=tagged][selected=selected]'
    end

    test 'fieldsets have a select box for selecting the filter' do
      assert_html @html, 'select[id=selected_filter_0]' do
        assert_select 'option[value=title]'
        assert_select 'option[value=body]'
        assert_select 'option[value=excerpt]'
        assert_select 'option[value=tagged]'
        assert_select 'option[value=state]'
      end
    end

    test 'fieldsets have a nested fieldset for each filter' do
      assert_html @html, 'fieldset[class=set] fieldset[class~=filter][id=filter_title_0]'
      assert_html @html, 'fieldset[class=set] fieldset[class~=filter][id=filter_tagged_0]'
      assert_html @html, 'fieldset[class=set] fieldset[class~=filter][id=filter_state_0]'
      assert_html @html, 'fieldset[class=set] fieldset[class~=filter][id=filter_categorized_0]'
    end

    test 'one fieldset has the :title fieldset selected, one has the :body fieldset selected (from params)' do
      assert_html @html, 'fieldset[class=set] fieldset[class~=selected][id=filter_title_0]'
      assert_html @html, 'fieldset[class=set] fieldset[class~=selected][id=filter_body_1]'
    end

    test 'text filter has a select box for selecting the scope and a query input' do
      assert_html @html, 'select[id=filter_body_scope_0][name=?]', 'filters[][body][scope]' do
        assert 'option[value=contains]'
        assert 'option[value=starts_with]'
        assert 'option[value=ends_with]'
        assert 'option[value=is]'
        assert 'option[value=is_not]'
      end
      assert_html @html, 'input[id=filter_body_query_0][name=?]', 'filters[][body][query]'
    end

    test 'title text filter has the :starts_with scope selected and query set to "foo" (from params)' do
      assert_html @html, 'select[id=filter_title_scope_0] option[value=starts_with][selected=selected]'
      assert_html @html, 'input[id=filter_title_query_0][value=foo]'
    end

    test 'body text filter has the :contains scope selected and query set to "bar" (from params)' do
      assert_html @html, 'select[id=filter_body_scope_1] option[value=contains][selected=selected]'
      assert_html @html, 'input[id=filter_body_query_1][value=bar]'
    end

    test 'tag filter has a query input set to "baz"' do
      assert_html @html, 'input[id=filter_tagged_query_2][name=?][value=baz]', 'filters[][tagged]'
    end

    test 'state filter has checkboxes for possible states' do
      assert_html @html, 'input[type=checkbox][id=?][name=?][value=?][checked=checked]', 
        "filter_state_published_3", 'filters[][state][]', 'published'
      assert_html @html, 'input[type=checkbox][id=?][name=?][value=?]', 
        "filter_state_unpublished_3", 'filters[][state][]', 'unpublished'
    end

    test 'categorized filter has a select box selecting a category' do
      assert_html @html, 'select[id=filter_categorized_id_4][name=?]', 'filters[][categorized][]' do
        assert_select 'option[value=?][selected=selected]', @categories.first.id, @categories.first.title
      end
    end
  end
end