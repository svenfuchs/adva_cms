user = User.find_by_first_name('a user')
admin = User.find_by_first_name('an admin')

site_with_forums =
Site.create!     :name  => 'site with forum',
                 :title => 'site with forum title',
                 :host  => 'site-with-forum.com'

admin.roles.create!(:name => 'admin', :context => site_with_forums)

forum_without_boards =
Forum.create!    :site        => site_with_forums,
                 :title       => 'a forum without boards',
                 :permalink   => 'a-forum-without-boards',
                 :comment_age => 0,
                 :published_at => Time.parse('2008-01-01 12:00:00')

forum_with_boards =
Forum.create!    :site        => site_with_forums,
                 :title       => 'a forum with boards',
                 :permalink   => 'a-forum-with-boards',
                 :comment_age => 0,
                 :published_at => Time.parse('2008-01-01 12:00:00')

forum_with_one_board =
Forum.create!   :site        => site_with_forums,
                :title       => 'a forum with one board',
                :permalink   => 'a-forum-with-one-board',
                :comment_age => 0,
                :published_at => Time.parse('2008-01-01 12:00:00')

forum_with_two_topics =
Forum.create!   :site        => site_with_forums,
                :title       => 'a forum with two topics',
                :permalink   => 'a-forum-with-two-topics',
                :comment_age => 0,
                :published_at => Time.parse('2008-01-01 12:00:00')

a_board =
Board.create!    :site    => site_with_forums,
                 :section => forum_with_boards,
                 :title   => 'a board'

another_board =
Board.create!    :site    => site_with_forums,
                 :section => forum_with_boards,
                 :title   => 'another board'

topicless_board =
Board.create!    :site    => site_with_forums,
                 :section => forum_with_boards,
                 :title   => 'a topicless board'

lone_board =
Board.create!    :site    => site_with_forums,
                 :section => forum_with_one_board,
                 :title   => 'a lone board'

board_topic_attrs = {  :site      => site_with_forums,
                       :section   => forum_with_boards,
                       :author    => user,
                       :board     => a_board,
                       :title     => 'a board topic',
                       :body      => 'a board topic body',
                       :permalink => 'a-board-topic' }

board_topic = Topic.post user, board_topic_attrs
board_topic.save!

board_topic_reply = board_topic.reply user, :body => 'a reply'
board_topic_reply.save!

board_topic_reply = board_topic.reply user, :body => 'another reply'
board_topic_reply.save!

board_topic_reply = board_topic.reply user, :body => 'yet another reply'
board_topic_reply.save!


another_board_topic =
Topic.post       admin, board_topic_attrs.merge(:title     => 'another board topic',
                                                :body      => 'another board topic body',
                                                :permalink => 'another-board-topic')
another_board_topic.save!

topic_attrs = {  :site      => site_with_forums,
                 :section   => forum_without_boards,
                 :author    => user,
                 :title     => 'a topic',
                 :body      => 'a topic body',
                 :permalink => 'a-topic' }

first_topic =
Topic.post user, topic_attrs.merge(:section => forum_with_two_topics,
                                   :title => 'first topic',
                                   :body  => 'first topic body',
                                   :permalink => 'first-topic')
first_topic.save!

last_topic =
Topic.post user, topic_attrs.merge(:section => forum_with_two_topics,
                                   :title => 'last topic',
                                   :body  => 'last topic body',
                                   :permalink => 'last-topic')
last_topic.save!

topic =
Topic.post user, topic_attrs
topic.save!

topic_reply =
topic.reply user, :body => 'a reply'
topic_reply.save!
