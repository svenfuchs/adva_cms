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

      def be_primary
        Matchy::Expectations::BePrimary.new(nil, self)
      end

      def have_excerpt
        Matchy::Expectations::HaveExcerpt.new(nil, self)
      end

      def accept_comments
        Matchy::Expectations::AcceptComments.new(nil, self)
      end

      def be_draft
        Matchy::Expectations::BeDraft.new(nil, self)
      end

      def be_published
        Matchy::Expectations::BePublished.new(nil, self)
      end

      def save_version
        Matchy::Expectations::SaveVersion.new(nil, self)
      end

      def be_in_single_article_mode
        Matchy::Expectations::BeInSingleArticleMode.new(nil, self)
      end

      def be_root_section
        Matchy::Expectations::BeRootSection.new(nil, self)
      end

      def be_approved
        Matchy::Expectations::BeApproved.new(nil, self)
      end

      def be_first
        Matchy::Expectations::BeFirst.new(nil, self)
      end

      def be_last
        Matchy::Expectations::BeLast.new(nil, self)
      end

      def be_owned_by(owner)
        Matchy::Expectations::BeOwnedBy.new(owner, self)
      end

      def be_paged
        Matchy::Expectations::BePaged.new(nil, self)
      end

      def have_valid_extension
        Matchy::Expectations::HaveValidExtension.new(nil, self)
      end

      def be_delivered
        Matchy::Expectations::BeDelivered.new(nil, self)
      end

      def be_queued
        Matchy::Expectations::BeQueued.new(nil, self)
      end

      def be_editable
        Matchy::Expectations::BeEditable.new(nil, self)
      end

      def be_pending
        Matchy::Expectations::BePending.new(nil, self)
      end

      def be_active
        Matchy::Expectations::BeActive.new(nil, self)
      end

      def be_anonymous
        Matchy::Expectations::BeAnonymous.new(nil, self)
      end

      def be_registered
        Matchy::Expectations::BeRegistered.new(nil, self)
      end

      def be_verified
        Matchy::Expectations::BeVerified.new(nil, self)
      end

      def have_role(*args)
        Matchy::Expectations::HaveRole.new(args, self)
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
      @receiver.included_modules.include? ActiveRecord::NestedSet::InstanceMethods
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
      @receiver.acts_as_taggable?
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

    matcher "HaveExcerpt",
            "Expected %s to have an excerpt.",
            "Expected %s not to have an excerpt." do |receiver|
      @receiver = receiver
      @receiver.has_excerpt?
    end

    matcher "AcceptComments",
            "Expected %s to accept comments.",
            "Expected %s not to accept comments." do |receiver|
      @receiver = receiver
      @receiver.accept_comments?
    end

    matcher "BePrimary",
            "Expected %s to be primary.",
            "Expected %s not to be primary." do |receiver|
      @receiver = receiver
      @receiver.primary?
    end

    matcher "BeDraft",
            "Expected %s to be a draft.",
            "Expected %s not to be a draft." do |receiver|
      @receiver = receiver
      @receiver.draft?
    end

    matcher "BePublished",
            "Expected %s to be published.",
            "Expected %s not to be published." do |receiver|
      @receiver = receiver
      @receiver.published?
    end

    matcher "SaveVersion",
            "Expected %s to indicate to save a new version.",
            "Expected %s not to indicate to save a new version." do |receiver|
      @receiver = receiver
      @receiver.save_version?
    end

    matcher "BeInSingleArticleMode",
            "Expected %s to be in single article mode.",
            "Expected %s not to be in single article mode." do |receiver|
      @receiver = receiver
      @receiver.single_article_mode
    end

    matcher "BeRootSection",
            "Expected %s to be a root section.",
            "Expected %s not to be a root section." do |receiver|
      @receiver = receiver
      @receiver.root_section?
    end

    matcher "BeApproved",
            "Expected %s to be approved.",
            "Expected %s not to be approved." do |receiver|
      @receiver = receiver
      @receiver.approved?
    end

    matcher "BeFirst",
            "Expected %s to be first.",
            "Expected %s not to be first." do |receiver|
      @receiver = receiver
      @receiver.first?
    end

    matcher "BeLast",
            "Expected %s to be last.",
            "Expected %s not to be last." do |receiver|
      @receiver = receiver
      @receiver.last?
    end

    matcher "BeOwnedBy",
            "Expected %s to be owned by %s.",
            "Expected %s not to be owned by %s." do |receiver|
      @receiver = receiver
      @receiver.owner == @expected
    end

    matcher "BePaged",
            "Expected %s to be paged.",
            "Expected %s not to be paged." do |receiver|
      @receiver = receiver
      @receiver.paged?
    end

    matcher "HaveValidExtension",
            "Expected %s to have a valid extension.",
            "Expected %s not to have a valid extension." do |receiver|
      @receiver = receiver
      @receiver.valid_extension?
    end

    matcher "BeDelivered",
            "Expected %s to be delivered.",
            "Expected %s not to be delivered." do |receiver|
      @receiver = receiver
      @receiver.delivered?
    end

    matcher "BeQueued",
            "Expected %s to be queued.",
            "Expected %s not to be queued." do |receiver|
      @receiver = receiver
      @receiver.queued?
    end

    matcher "BeEditable",
            "Expected %s to be editable.",
            "Expected %s not to be editable." do |receiver|
      @receiver = receiver
      @receiver.editable?
    end

    matcher "BePending",
            "Expected %s to be pending.",
            "Expected %s not to be pending." do |receiver|
      @receiver = receiver
      @receiver.pending?
    end

    matcher "BeActive",
            "Expected %s to be active.",
            "Expected %s not to be active." do |receiver|
      @receiver = receiver
      @receiver.active?
    end

    matcher "BeAnonymous",
            "Expected %s to be anonymous.",
            "Expected %s not to be anonymous." do |receiver|
      @receiver = receiver
      @receiver.anonymous?
    end

    matcher "BeRegistered",
            "Expected %s to be registered.",
            "Expected %s not to be registered." do |receiver|
      @receiver = receiver
      @receiver.registered?
    end

    matcher "BeVerified",
            "Expected %s to be verified.",
            "Expected %s not to be verified." do |receiver|
      @receiver = receiver
      @receiver.verified?
    end

    matcher "HaveRole",
            "Expected %s to have role %s.",
            "Expected %s not to have role %s." do |receiver|
      @receiver = receiver
      @receiver.has_role?(*@expected) # urgs
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