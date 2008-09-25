require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::ActivityObserver do
  include SpecActivityHelper
  include Stubby

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @activity = Activity.new
    @activity.stub!(:site).and_return(stub_site)
    @activity.stub!(:section).and_return(stub_section)

    # set up a mock mail
    @mail = TMail::Mail.new
    @mail.set_content_type('text', 'plain', { 'charset' => 'utf-8' })
    @mail.mime_version = '1.0'
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "for articles" do
    it "sets the mail up correctly" do
      @mail.subject = "[#{stub_site.name} / #{stub_section.title}] New Article posted"
      @mail.from    = "#{stub_site.name} <#{stub_site.email}>"
      # TODO: include recipients
      @mail.body    = "#{stub_article.author_name} just posted a new Article on #{stub_site.name} in section #{stub_section.title}."

      @activity.stub!(:object).and_return(stub_article)
      @activity.stub!(:author_name).and_return(stub_article.author_name)

      ActivityNotifier.create_new_content_notification(@activity).encoded.should == @mail.encoded
    end
  end

  describe "for comments" do
    it "sets the mail up correctly" do
      @mail.subject = "[#{stub_site.name} / #{stub_section.title}] New Comment posted"
      @mail.from    = "#{stub_site.name} <#{stub_site.email}>"
      # TODO: include recipients
      @mail.body    = "#{stub_comment.author_name} just posted a new Comment on #{stub_site.name} in section #{stub_section.title}."

      @activity.stub!(:object).and_return(stub_comment)
      @activity.stub!(:author_name).and_return(stub_comment.author_name)

      ActivityNotifier.create_new_content_notification(@activity).encoded.should == @mail.encoded
    end
  end

  describe "for wikipages" do
    it "sets the mail up correctly" do
      @mail.subject = "[#{stub_site.name} / #{stub_section.title}] New Wikipage posted"
      @mail.from    = "#{stub_site.name} <#{stub_site.email}>"
      # TODO: include recipients
      @mail.body    = "#{stub_wikipage.author_name} just posted a new Wikipage on #{stub_site.name} in section #{stub_section.title}."

      @activity.stub!(:object).and_return(stub_wikipage)
      @activity.stub!(:author_name).and_return(stub_wikipage.author_name)

      ActivityNotifier.create_new_content_notification(@activity).encoded.should == @mail.encoded
    end
  end

end