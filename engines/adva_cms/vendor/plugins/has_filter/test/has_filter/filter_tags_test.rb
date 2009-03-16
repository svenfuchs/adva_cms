require File.dirname(__FILE__) + '/../test_helper.rb'

module HasFilter
  class FilterTagsTest < ActiveSupport::TestCase
    include HasFilter
    include HasFilter::TestHelper

    test 'text filter formfields include an input for the query and a select for the scope' do
      html = text_filter.to_form_fields.join
      assert_html html, 'select[id=filter_text_body_scope][name=?]', 'filters[text][body][][scope]' do
        assert 'option[value=does_not_contain]'
        assert 'option[value=starts_with]'
        assert 'option[value=ends_with]'
        assert 'option[value=is]'
        assert 'option[value=is_not]'
      end
      assert_html html, 'input[id=filter_text_body_query][name=?]', 'filters[text][body][][query]'
    end

    test 'tag filter formfields include an input for the tags query' do
      html = tags_filter.to_form_fields.join
      assert_html html, 'input[id=filter_tags_query][name=?]', 'filters[tags][][query]'
    end

    test 'tag state formfields include checkboxes for possible states' do
      html = state_filter.to_form_fields.join
      [:published, :unpublished].each do |state|
        assert_html html, 'input[type=checkbox][id=filter_state][name=?][value=?]', 'filters[state][]', state
      end
    end
  
    test 'filter chain to_form_fields wraps filter formfields into fieldsets' do
      html = filter_chain.to_form_fields
      assert_html html, 'fieldset[class=filters]' do
        assert_select 'select[id=selected_filter]' do
          assert_select 'option[value=text]'
          assert_select 'option[value=tags]'
          assert_select 'option[value=state]'
        end
        assert_select 'fieldset[id=filter_text][class=?]', 'filter first' do
          assert_select 'select[id=filter_text_body_scope]'
          assert_select 'input[id=filter_text_body_query]'
        end
        assert_select 'fieldset[id=filter_tags][class=filter]' do
          assert_select 'input[id=filter_tags_query]'
        end
        assert_select 'fieldset[id=filter_state][class=filter]' do
          assert_select 'input[id=filter_state][type=checkbox][value=published]'
          assert_select 'input[id=filter_state][type=checkbox][value=unpublished]'
        end
      end
    end
  end
end