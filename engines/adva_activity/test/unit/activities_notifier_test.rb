require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ActivitiesNotifierTest < ActiveSupport::TestCase
  def setup
    super
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    # set up a mock mail
    @mail = TMail::Mail.new
    @mail.set_content_type('text', 'plain', { 'charset' => 'utf-8' })
    @mail.mime_version = '1.0'

    # need to stub out Time.now and set mail date in order to avoid automatic setting
    # see http://github.com/rails/rails/commit/f73d34c131c1e371c76c5a146aac2c2bffbf96e5
    stub(Time).now { Time.local(2009, 10, 8, 12, 0, 0) }
    @mail.date = Time.now

    @site = Site.first
    @section = Section.first
    @user = User.first
  end

  def teardown
    super
    ActionMailer::Base.deliveries.clear
  end

  test "sets the mail up correctly for articles" do
    article = Article.first
    activity = activity_for(article)

    @mail.subject = "[#{@site.name} / #{@section.title}] New Article posted"
    @mail.from    = "#{@site.name} <#{@site.email}>"
    @mail.body    = "#{article.author_name} <#{article.author_email}> just posted a new Article on #{@site.name} in section #{@section.title}."
    @mail.to      = "#{@user.email}"

    ActivityNotifier.create_new_content_notification(activity, @user).encoded.should == @mail.encoded
  end

  test "sets the mail up correctly for comments" do
    comment = Comment.first
    activity = activity_for(comment)

    @mail.subject = "[#{@site.name} / #{@section.title}] New Comment posted"
    @mail.from    = "#{@site.name} <#{@site.email}>"
    @mail.body    = "#{comment.author_name} <#{comment.author_email}> just posted a new Comment on #{@site.name} in section #{@section.title}."
    @mail.to      = "#{@user.email}"

    ActivityNotifier.create_new_content_notification(activity, @user).encoded.should == @mail.encoded
  end

  if Rails.plugin?(:adva_wiki)
    test "sets the mail up correctly for wikipages" do
      wikipage = Wikipage.first
      activity = activity_for(wikipage)

      @mail.subject = "[#{@site.name} / #{@section.title}] New Wikipage posted"
      @mail.from    = "#{@site.name} <#{@site.email}>"
      @mail.body    = "#{wikipage.author_name} <#{wikipage.author_email}> just posted a new Wikipage on #{@site.name} in section #{@section.title}."
      @mail.to      = "#{@user.email}"

      ActivityNotifier.create_new_content_notification(activity, @user).encoded.should == @mail.encoded
    end
  end

  def activity_for(object)
    returning Activity.new(:site => @site, :section => @section) do |activity|
      activity.object = object
      activity.author_name = object.author_name
      activity.author_email = object.author_email
    end
  end
end