require 'rubygems'
begin
  require 'diff/lcs'
rescue MissingSourceFile => e
end

module HtmlDiff
  class << self
    def diff(str1, str2)
      return 'gem diff/lcs is not installed' unless defined?(Diff::LCS)
      format = Formatter.new
      Diff::LCS.traverse_sequences(str1, str2, format)
      format.finish
    end
  end

  class Formatter
    def initialize
      @html = ''
    end

    def match(event)
      start(:match) unless @state == :match
      @html << event.old_element
    end

    def discard_a(event)
      start(:"diff-delete") unless @state == :"diff-delete"
      @html << event.old_element
    end

    def discard_b(event)
      start(:"diff-add") unless @state == :"diff-add"
      @html << event.new_element
    end

    def start(state)
      finish unless @state == state
      @state = state
      @html << %Q(<span class="#{state}">)
    end

    def finish
      @html << '</span>' if @state
      @html
    end
  end
end
