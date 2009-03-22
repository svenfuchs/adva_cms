require File.dirname(__FILE__) + "/../test_helper"

module TableBuilder
  class TagTest < Test::Unit::TestCase
    def test_render
      tag = Tag.new
      tag.tag_name = 'foo'
      html = tag.render { |html| html << 'bar' }
      assert_html html, 'foo', 'bar'
    end
  end
  
  class CellTest < Test::Unit::TestCase
    def test_render
      html = Cell.new(Row.new(Table.new), 'foo').render
      assert_html html, 'td', 'foo'
    end
  
    def test_picks_th_when_contained_in_head
      html = Cell.new(Row.new(Head.new(Table.new)), 'foo').render
      assert_html html, 'th', 'foo'
    end
  end
  
  class RowTest < Test::Unit::TestCase
    include TableTestHelper
  
    def test_render
      row = build_body_row
      row.cell 'foo'
      assert_html row.render, 'tr td', 'foo'
    end
  end
  
  class HeadTest < Test::Unit::TestCase
    include TableTestHelper
  
    def test_adds_a_column_headers_row
      head = build_table.head
      assert_html head.render, 'thead' do
        assert_select 'tr th[scope=col]', 'foo'
        assert_select 'tr th[scope=col]', 'bar'
      end
    end
    
    def test_column_html_options
      head = build_table(build_column('foo', :class => 'foo')).head
      assert_html head.render, 'th[scope=col]', 'foo'
    end
    
    def test_translates_head_cell_content
      TableBuilder.options[:i18n_scope] = 'foo'
      head = build_table(build_column(:foo)).head
      assert_html head.render, 'th', 'translation missing: en, foo, strings, columns, foo'
    end
    
    def test_head_with_total_row
      head = build_table.head
      head.row { |r| r.cell "foo", :colspan => :all }
      assert_html head.render, 'thead tr th[colspan=2]', 'foo'
    end
  end
  
  class BodyTest < Test::Unit::TestCase
    include TableTestHelper
  
    def test_render
      body = build_table.body
      body.row { |row, record| row.cell(record) }
      assert_html body.render, 'tbody' do
        assert_select 'tr td', 'foo'
        assert_select 'tr[class=alternate] td', 'bar'
      end
    end
  
    def test_cell_html_options
      body = build_table.body
      body.row { |row, record| row.cell(record, :class => 'baz') }
      assert_html body.render, 'td[class=baz]', 'foo'
    end
  end
  
  class TableTest < Test::Unit::TestCase
    def test_render_basic
      table = Table.new %w(a b) do |table|
        table.column('a'); table.column('b')
        table.row { |row, record| row.cell(record); row.cell(record) }
      end
      assert_html table.render, 'table[id=strings][class=list]' do
        assert_select 'thead tr th[scope=col]', 'a'
        assert_select 'tbody tr td', 'a'
        assert_select 'tbody tr[class=alternate] td', 'b'
      end
    end
  
    def test_render_calling_column_and_cell_shortcuts
      table = Table.new %w(a b) do |table|
        table.column 'a', 'b'
        table.row { |row, record| row.cell record, record }
      end
      assert_html table.render, 'table[id=strings][class=list]' do
        assert_select 'thead tr th[scope=col]', 'a'
        assert_select 'tbody tr td', 'a'
        assert_select 'tbody tr[class=alternate] td', 'b'
      end
    end
      
    def test_block_can_access_view_helpers_and_instance_variables
      @foo = 'foo'
      table = Table.new %w(a) do |table|
        table.column 'a'
        table.row { |row, record, index| row.cell @foo + bar }
      end
      html = ''
      assert_nothing_raised { html = table.render }
      assert_match %r(foobar), html
    end
      
    def test_column_html_class_inherits_to_tbody_cells
      table = Table.new %w(a) do |table|
        table.column 'a', :class => 'foo'
        table.row { |row, record, index| row.cell 'bar' }
      end
      assert_html table.render, 'tbody tr td[class=foo]', 'bar'
    end
      
    def test_table_collection_name
      assert_equal 'objects', Table.new([Object.new]).collection_name
    end
  
    protected
  
      def bar
        'bar'
      end
  end
  
  class Record
    attr_reader :id, :title
    def initialize(id, title); @id = id; @title = title; end
    def attribute_names; ['id', 'title']; end
  end
  
  class RenderTest < ActionView::TestCase
    def setup
      articles = [Record.new(1, 'foo'), Record.new(2, 'bar')]
      @view = ActionView::Base.new([File.dirname(__FILE__) + '/../fixtures/templates'], { :articles => articles })
      @view.extend(TableBuilder)
      TableBuilder.options[:i18n_scope] = :test
      I18n.backend.send :merge_translations,
        :en, :test => { :'table_builder_records' => { :columns => { :id => 'ID', :title => 'Title' } } }
    end
  
    def test_render_simple
      html = @view.render(:file => 'table_simple')
      assert_html html, 'table[id=table_builder_records][class=list]' do
        assert_select 'thead tr' do
          assert_select 'th[scope=col]', 'ID'
          assert_select 'th[scope=col]', 'Title'
        end
        assert_select 'tbody' do
          assert_select 'tr' do
            assert_select 'td', '1'
            assert_select 'td', 'foo'
          end
          assert_select 'tr[class=alternate]' do
            assert_select 'td', '2'
            assert_select 'td', 'bar'
          end
        end
      end
    end
      
    def test_render_auto_body
      assert_equal @view.render(:file => 'table_simple'), @view.render(:file => 'table_auto_body')
    end
      
    def test_render_auto_columns
      html = @view.render(:file => 'table_auto_columns')
      assert_html html, 'table[id=table_builder_records][class=list]' do
        assert_select 'thead tr' do
          assert_select 'th[scope=col]', 'Id'
          assert_select 'th[scope=col]', 'Title'
        end
        assert_select 'tbody' do
          assert_select 'tr' do
            assert_select 'td', '1'
            assert_select 'td', 'foo'
          end
          assert_select 'tr[class=alternate]' do
            assert_select 'td', '2'
            assert_select 'td', 'bar'
          end
        end
      end
    end
      
    def test_render_all
      html = @view.render(:file => 'table_all')
      assert_html html, 'table[id=table_builder_records][class=list]' do
        assert_select 'thead tr' do
          assert_select 'th[colspan=2][class=total]', 'total: 2'
        end
        assert_select 'thead tr' do
          assert_select 'th[scope=col]', 'ID'
          assert_select 'th[scope=col]', 'Title'
          assert_select 'th[scope=col][class=action]', 'Action'
        end
        assert_select 'tbody' do
          assert_select 'tr' do
            assert_select 'td', '1'
            assert_select 'td', 'foo'
          end
          assert_select 'tr[class=alternate]' do
            assert_select 'td', '2'
            assert_select 'td', 'bar'
          end
        end
        assert_select 'tfoot tr td', 'foo'
      end
    end
  
    def test_render_all_with_empty
      view = ActionView::Base.new([File.dirname(__FILE__) + '/../fixtures/templates'], { :articles => [] })
      view.extend(TableBuilder)
      html = view.render(:file => 'table_all')
      assert_html html, 'p[class=empty]', 'no records!'
    end
  end
end