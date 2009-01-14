require 'i18n'

module LaterDude
  module CalendarHelper
    def calendar_for(year, month, options={}, &block)
      Calendar.new(year, month, options, &block).to_html
    end
  end

  # TODO: Maybe make output prettier?
  class Calendar
    include ActionView::Helpers::TagHelper

    def initialize(year, month, options={}, &block)
      @year, @month = year, month
      @options = options.symbolize_keys.reverse_merge(Calendar.default_calendar_options)

      @days = Date.civil(@year, @month, 1)..Date.civil(@year, @month, -1)
      @block = block
    end

    def to_html
      <<-EOF
        <table class="#{@options[:calendar_class]}">
          <thead>
            #{show_month_names}
            #{show_day_names}
          </thead>
          <tbody>
            #{show_days}
          </tbody>
        </table>
      EOF
    end

    private
    def show_days
      "<tr>#{show_previous_month}#{show_current_month}#{show_following_month}</tr>"
    end

    def show_previous_month
      return if @days.first.wday == first_day_of_week # don't display anything if the first day is the first day of a week

      returning "" do |output|
        beginning_of_week(@days.first).upto(@days.first - 1) { |d| output << show_day(d) }
      end
    end

    def show_current_month
      returning "" do |output|
        @days.first.upto(@days.last) { |d| output << show_day(d) }
      end
    end

    def show_following_month
      return if @days.last.wday == last_day_of_week # don't display anything if the last day is the last day of a week

      returning "" do |output|
        (@days.last + 1).upto(beginning_of_week(@days.last + 1.week) - 1) { |d| output << show_day(d) }
      end
    end

    def show_day(day)
      options = { :class => "day" }
      options[:class] << " otherMonth" if day.month != @days.first.month
      options[:class] << " weekend" if Calendar.weekend?(day)
      options[:class] << " today" if day.today?

      # block is only called for current month
      if @block && day.month == @days.first.month
        content, options_from_block = Array(@block.call(day))

        # passing options is optional
        if options_from_block.is_a?(Hash)
          options[:class] << " #{options_from_block.delete(:class)}" if options_from_block[:class]
          options.merge!(options_from_block)
        end
      else
        content = day.day
      end

      returning content_tag(:td, content, options) do |output|
        if day < @days.last && day.wday == last_day_of_week # opening and closing tag for the first and last week are included in #show_days
          output << "</tr><tr>" # close table row at the end of a week and start a new one
        end
      end
    end

    def beginning_of_week(day)
      diff = day.wday - first_day_of_week
      diff += 7 if first_day_of_week > day.wday # hackish ;-)
      day - diff
    end

    def month_names
      @month_names ||= @options[:use_full_month_names] ? full_month_names : abbreviated_month_names
    end

    def full_month_names
      @full_month_names ||= I18n.translate(:'date.month_names')
    end

    def abbreviated_month_names
      @abbreviated_month_names ||= I18n.translate(:'date.abbr_month_names')
    end

    def show_month_names
      return if @options[:hide_month_name]

      %(<tr>
        <th colspan="7">#{I18n.localize(@days.first, :format => @options[:header_date_format])}</th>
      </tr>)
    end

    def day_names
      @day_names ||= @options[:use_full_day_names] ? full_day_names : abbreviated_day_names
    end

    def full_day_names
      @full_day_names ||= I18n.translate(:'date.day_names')
    end

    def abbreviated_day_names
      @abbreviated_day_names ||= I18n.translate(:'date.abbr_day_names')
    end

    def show_day_names
      return if @options[:hide_day_names]

      returning "<tr>" do |output|
        apply_first_day_of_week(day_names).each do |day|
          output << %(<th scope="col">#{include_day_abbreviation(day)}</th>)
        end
        output << "</tr>"
      end
    end

    # => <abbr title="Sunday">Sun</abbr>
    def include_day_abbreviation(day)
      return day if @options[:use_full_day_names]

      %(<abbr title="#{full_day_names[abbreviated_day_names.index(day)]}">#{day}</abbr>)
    end

    def apply_first_day_of_week(day_names)
      names = day_names.dup
      first_day_of_week.times { names.push(names.shift) }
      names
    end

    def first_day_of_week
      @options[:first_day_of_week]
    end

    def last_day_of_week
      @options[:first_day_of_week] > 0 ? @options[:first_day_of_week] - 1 : 6
    end

    class << self
      def weekend?(day)
        [0,6].include?(day.wday) # 0 = Sunday, 6 = Saturday
      end

      def default_calendar_options
        {
          :calendar_class => "calendar",
          :first_day_of_week => I18n.translate(:'date.first_day_of_week', :default => "0").to_i,
          :hide_day_names => false,
          :hide_month_name => false,
          :use_full_day_names => false,
          :use_full_month_names => true,
          :header_date_format => I18n.translate(:'date.formats.calendar_header', :default => "%B")
        }
      end
    end
  end
end