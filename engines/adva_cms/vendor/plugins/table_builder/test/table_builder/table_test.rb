require File.dirname(__FILE__) + "/../test_helper"

module TableBuilder
  class TagTest < Test::Unit::TestCase
    def test_to_html
      tag = Tag.new :foo
      html = tag.to_html { |html| html << 'bar' }
      assert_html html, 'foo', 'bar'
    end
  end

  class CellTest < Test::Unit::TestCase
    def test_to_html
      html = Cell.new(Row.new(Table.new), 'foo').to_html
      assert_html html, 'td', 'foo'
    end

    def test_picks_th_when_contained_in_head
      html = Cell.new(Row.new(Head.new), 'foo').to_html
      assert_html html, 'th', 'foo'
    end
  end

  class RowTest < Test::Unit::TestCase
    def test_to_html
      columns = [Column.new(nil, 'foo')]
      row = Row.new(Body.new, columns)
      row.cell 'foo'
      assert_html row.to_html, 'tr td', 'foo'
    end
  end

  class HeadTest < Test::Unit::TestCase
    def setup
      @scope = TableBuilder.options[:i18n_scope]
    end

    def teardown
      TableBuilder.options[:i18n_scope] = @scope
    end

    def test_to_html
      head = Head.new(nil, Column.new(nil, 'foo'), Column.new(nil, 'bar'))
      assert_html head.to_html, 'thead' do
        assert_select 'tr th[scope=col]', 'foo'
        assert_select 'tr th[scope=col]', 'bar'
      end
    end

    def test_column_html_options
      head = Head.new(nil, Column.new(nil, 'foo', :class => 'foo'))
      assert_html head.to_html, 'th[scope=col]', 'foo'
    end

    def test_translates_head_cell_content
      TableBuilder.options[:i18n_scope] = 'foo'
      head = Head.new(Table.new([Object.new]), Column.new(nil, :foo))
      assert_html head.to_html, 'th', 'translation missing: en, foo, objects, columns, foo'
    end
  end

  class BodyTest < Test::Unit::TestCase
    def test_to_html
      body = Body.new(nil, [Column.new(nil, 'foo')], %w(foo bar)) do |row, record, index|
          row.cell record
      end
      assert_html body.to_html, 'tbody' do
        assert_select 'tr td', 'foo'
        assert_select 'tr[class=alternate] td', 'bar'
      end
    end

    def test_cell_html_options
      body = Body.new(nil, [Column.new(nil, 'foo')], %w(foo bar)) do |row, record, index|
          row.cell record, :class => 'baz'
      end
      assert_html body.to_html, 'td[class=baz]', 'foo'
    end
  end

  class TableTest < Test::Unit::TestCase
    def test_to_html_basic
      table = Table.new %w(a b) do |t|
        t.column('a'); t.column('b')
        t.body { |row, record, index| row.cell(record); row.cell(record) }
      end
      assert_html table.to_html, 'table[id=strings_table][class=list]' do
        assert_select 'thead tr th[scope=col]', 'a'
        assert_select 'tbody tr td', 'a'
        assert_select 'tbody tr[class=alternate] td', 'b'
      end
    end

    def test_to_html_calling_columns_and_cells_shortcuts
      table = Table.new %w(a b) do |t|
        t.columns 'a', 'b'
        t.body { |row, record, index| row.cells record, record }
      end
      assert_html table.to_html, 'table[id=strings_table][class=list]' do
        assert_select 'thead tr th[scope=col]', 'a'
        assert_select 'tbody tr td', 'a'
        assert_select 'tbody tr[class=alternate] td', 'b'
      end
    end

    def test_block_can_access_view_helpers_and_instance_variables
      @foo = 'foo'
      table = Table.new %w(a) do |t|
        t.column 'a'
        t.body { |row, record, index| row.cell @foo + bar }
      end
      html = ''
      assert_nothing_raised { html = table.to_html }
      assert_match %r(foobar), html
    end

    def test_column_html_class_inherits_to_tbody_cells
      table = Table.new %w(a) do |t|
        t.column 'a', :class => 'foo'
        t.body { |row, record, index| row.cell 'bar' }
      end
      assert_html table.to_html, 'tbody tr td[class=foo]', 'bar'
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
      assert_html html, 'table[id=table_builder_records_table][class=list]' do
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
      assert_html html, 'table[id=table_builder_records_table][class=list]' do
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
  end
end