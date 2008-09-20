require 'uri'
require 'cgi'

module UrlMatchers
  def have_parameter(*expected)
    HaveParameter.new(expected)
  end
  alias_method :have_parameters, :have_parameter

  class HaveParameter
    def initialize(expected)
      @expected = expected
    end

    def matches?(target)
      @target = target
      uri = target =~ /^http:/ ? "http://test.host#{target}" : target
      query = URI.parse(uri).query || ''
      params = CGI.parse(query)

      # when expected is empty, that means that we expect any parameters to be present
      return !params.empty? if @expected.empty?

      present = @expected.collect do |expected|
        expected if params.keys.include? expected.to_s
      end.compact
      present.size == @expected.size
    end

    def failure_message
      if @expected.empty?
        "expected #{@target} to have GET parameters"
      else
        expected = @expected.map(&:to_s).to_sentence
        "expected #{@target} to have the GET parameters: #{expected}"
      end
    end

    def negative_failure_message
      if @expected.empty?
        "expected #{@target} to not have any GET parameters"
      else
        expected = @expected.map(&:to_s).to_sentence
        "expected #{@target} to not have the GET parameters: #{expected}"
      end
    end
  end
end