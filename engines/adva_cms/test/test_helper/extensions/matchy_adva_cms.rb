module Matchy
  module Expectations
    module TestCaseExtensions
      def filter_attributes(options)
        Matchy::Expectations::FilterAttributes.new(options, self)
      end

      def act_as_nested_set
        Matchy::Expectations::ActAsNestedSet.new(nil, self)
      end
      
      def act_as_taggable
        Matchy::Expectations::ActAsTaggable.new(nil, self)
      end

      def act_as_role_context(options)
        Matchy::Expectations::ActAsRoleContext.new(options, self)
      end

      def act_as_versioned
        Matchy::Expectations::ActAsVersioned.new(nil, self)
      end

      def instantiate_with_sti
        Matchy::Expectations::InstantiateWithSti.new(nil, self)
      end

      def have_permalink(column)
        Matchy::Expectations::HavePermalink.new(column, self)
      end

      def filter_column(column)
        Matchy::Expectations::FilterColumn.new(column, self)
      end

      def have_counter(name)
        Matchy::Expectations::HaveCounter.new(name, self)
      end

      def have_many_comments
        Matchy::Expectations::HaveManyComments.new(nil, self)
      end

      def have_many_themes
        Matchy::Expectations::HaveManyThemes.new(nil, self)
      end

      def have_url_params(*names)
        Matchy::Expectations::HaveUrlParams.new(names, self)
      end

      def act_as_authenticated_user
        Matchy::Expectations::ActAsAuthenticatedUser.new(nil, self)
      end
      
      def have_authorized_tag(*args)
        have_tag('.visible_for') { |tag| tag.should have_tag(*args) }
      end
    end

    matcher "ActAsAuthenticatedUser", 
            "Expected %s to act as an authenticated user.", 
            "Expected %s not to act as an authenticated user." do |receiver|
      @receiver = receiver
      @receiver.included_modules.include? Authentication::InstanceMethods
    end

    matcher "ActAsNestedSet", 
            "Expected %s to act as a nested set.", 
            "Expected %s not act as a nested set." do |receiver|
      @receiver = receiver
      @receiver.included_modules.include? SymetrieCom::Acts::NestedSet::InstanceMethods
    end

    matcher "ActAsRoleContext", 
            "Expected %s to act as a role context.", 
            "Expected %s not act as a role context." do |receiver|
      @receiver = receiver
      @receiver.acts_as_role_context? # FIXME match options
    end

    matcher "ActAsTaggable", 
            "Expected %s to act as taggable.", 
            "Expected %s not act as a taggable." do |receiver|
      @receiver = receiver
      @receiver.included_modules.include? ActiveRecord::Acts::Taggable::InstanceMethods
    end

    matcher "ActAsVersioned", 
            "Expected %s to act as versioned.", 
            "Expected %s not act as versioned." do |receiver|
      @receiver = receiver
      @receiver.included_modules.include? ActiveRecord::Acts::Versioned::ActMethods
    end

    matcher "FilterAttributes", 
            "Expected %s to filter the attributes %s.", 
            "Expected %s not filter the attributes %s." do |receiver|
      @receiver = receiver
      @receiver.included_modules.include?(XssTerminate::InstanceMethods) &&
      @receiver.xss_terminate_options.values_at(*@expected.keys).flatten == @expected.values.flatten
    end

    matcher "FilterColumn", 
            "Expected %s to filter the column %s.", 
            "Expected %s not filter the column %s." do |receiver|
      @receiver = receiver
      
      column = @expected
      receiver.send "#{column}=", '*strong*'
      RR.stub(receiver).filter.returns 'textile_filter'
      receiver.send :process_filters
      
      result = receiver.send("#{column}_html")
      result == '<p><strong>strong</strong></p>'
    end

    matcher "HavePermalink", 
            "Expected %s to have a permalink generated from %s.", 
            "Expected %s not to have a permalink generated from %s." do |receiver|
      @receiver = receiver
      @receiver.respond_to?(:attribute_to_urlify) && @receiver.attribute_to_urlify == @expected
    end

    matcher "HaveCounter", 
            "Expected %s to have a counter named %s.", 
            "Expected %s not to have a counter named %s." do |receiver|
      @receiver = receiver.is_a?(Class) ? receiver : receiver.class
      !!@receiver.reflect_on_all_associations(:has_one).find { |a| a.name == :"#{@expected}_counter" }
    end

    matcher "HaveManyComments", 
            "Expected %s to have many comments.", 
            "Expected %s not have many comments." do |receiver|
      @receiver = receiver
      @receiver.has_many_comments?
    end

    matcher "HaveManyThemes", 
            "Expected %s to have many themes.", 
            "Expected %s not have many themes." do |receiver|
      @receiver = receiver
      @receiver.has_many_themes?
    end

    matcher "InstantiateWithSti", 
            "Expected %s to instantiate with sti.", 
            "Expected %s not instantiate with sti." do |receiver|
      @receiver = receiver
      @receiver.instantiates_with_sti?
    end
    
    class HaveUrlParams < Base
      def matches?(receiver)
        @receiver = receiver
        uri = receiver =~ /^http:/ ? "http://test.host#{receiver}" : receiver
        query = URI.parse(uri).query || ''
        params = CGI.parse(query)

        # when expected is empty, that means that we expect any parameters to be present
        return !params.empty? if @expected.empty?

        present = @expected.collect do |expected|
          expected if params.keys.include?(expected.to_s)
        end.compact
        present.size == @expected.size
      end

      def failure_message
        if @expected.empty?
          "expected #{@receiver} to have GET parameters"
        else
          expected = @expected.map(&:to_s).to_sentence
          "expected #{@receiver} to have the GET parameters: #{expected}"
        end
      end

      def negative_failure_message
        if @expected.empty?
          "expected #{@receiver} to not have any GET parameters"
        else
          expected = @expected.map(&:to_s).to_sentence
          "expected #{@receiver} to not have the GET parameters: #{expected}"
        end
      end
    end
  end
end