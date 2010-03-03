# Role hierarchy, predefined by rbac gem:
# superuser -> admin -> designer -> moderator -> author -> user
#
# Everything a author can do, can be done by his masters (superuser, admin, designer, moderator).
# E.g., if the permission :'show site' => [:author] is defined in the default_permissions,
# a superuser, admin, designer and moderator have permission for the action 'show site', too.

ActionController::Dispatcher.to_prepare do
  Rbac::Context.default_permissions = {
    :'show site'          => [:privileged_account_member],
    :'create site'        => [:superuser],
    :'update site'        => [:superuser],
    :'destroy site'       => [:superuser],
    :'manage site'        => [:superuser],

    :'show section'       => [:author],
    :'create section'     => [:designer],
    :'update section'     => [:designer],
    :'destroy section'    => [:designer],
    :'manage section'     => [:designer],

    # article permissions (except 'update article') are only checked by the Admin::ArticlesController
    :'show article'       => [:author],
    :'create article'     => [:author],
    :'update article'     => [:author], # important for live site, if article is a draft, it will be shown only if user has this permission
    :'destroy article'    => [:author],
    :'manage article'     => [:author],

    :'show comment'       => [:author], # not guarded on live site
    :'create comment'     => [:anonymous], # used on the live site
    :'update comment'     => [:moderator],
    :'destroy comment'    => [:moderator],
    :'manage comment'     => [:moderator],

    :'show newsletter'    => [:author],
    :'create newsletter'  => [:moderator],
    :'update newsletter'  => [:moderator],
    :'destroy newsletter' => [:moderator],

    # only used in admin area = newsletter issues
    :'show issue'                 => [:author],
    :'create issue'               => [:author],
    :'update issue'               => [:author],
    :'destroy issue'              => [:author],

    :'update deleted_issue'       => [:author],
    :'destroy deleted_issue'      => [:author],

    :'show newsletter_subscription'    => [:author],
    :'create newsletter_subscription'  => [:moderator],
    :'update newsletter_subscription'  => [:moderator],
    :'destroy newsletter_subscription' => [:moderator],

    :'show asset'         => [:author],
    :'create asset'       => [:author],
    :'update asset'       => [:author],
    :'destroy asset'      => [:author],
    :'manage asset'       => [:author],

    :'show theme'         => [:designer],
    :'create theme'       => [:designer],
    :'update theme'       => [:designer],
    :'destroy theme'      => [:designer],
    :'manage theme'       => [:designer],

    :'show user'          => [:admin],
    :'create user'        => [:admin],
    :'update user'        => [:admin],
    :'destroy user'       => [:admin],
    :'manage user'        => [:admin],

    :'manage cached_page' => [:admin],

    :'manage roles'       => [:admin],

    :'show category'      => [:author],
    :'create category'    => [:author],
    :'update category'    => [:author],
    :'destroy category'   => [:author],
    :'manage category'    => [:author],

    :'show wikipage'      => [:user], # not guarded on live site
    :'create wikipage'    => [:user],
    :'update wikipage'    => [:user],
    :'destroy wikipage'   => [:moderator],
    :'manage wikipage'    => [:moderator],

    # live
    :'show topic'         => [:user], # not guarded on the website (topics_controller: guards_permissions :topic, :except => [:show, :index])
    :'create topic'       => [:user],
    :'update topic'       => [:moderator],
    :'destroy topic'      => [:moderator],
    :'moderate topic'     => [:moderator], # needed to create sticky or locked topics on the website

    # only used in admin area (on live site a forums_controller is used)
    :'show board'         => [:author],
    :'create board'       => [:moderator],
    :'update board'       => [:moderator],
    :'destroy board'      => [:moderator],
    :'moderate board'     => [:moderator],

    # only used on live site
    :'show post'          => [:user], # = forum posts,
    :'create post'        => [:user],
    :'update post'        => [:author],
    :'destroy post'       => [:author],
    :'manage post'        => [:author],

    :'show calendar_event'        => [:author],
    :'create calendar_event'      => [:author],
    :'update calendar_event'      => [:author],
    :'destroy calendar_event'     => [:author],
    :'manage calendar_event'      => [:author],

    # only used in admin area (on live site a albums_controller is used)
    :'show photo'                 => [:author],
    :'create photo'               => [:author],
    :'update photo'               => [:author], # important for live site, unpublished photos will be shown only if user has this permission
    :'destroy photo'              => [:author],
    :'manage photo'               => [:author],

    :'update deleted_newsletter'  => [:author],
    :'destroy deleted_newsletter' => [:author],

    :'show document'              => [:author],
    :'create document'            => [:author],
    :'update document'            => [:author],
    :'destroy document'           => [:author],
    :'manage document'            => [:author],

    :'show project'    => [:author],
    :'create project'  => [:author],
    :'update project'  => [:author],
    :'destroy project' => [:author],

    :'all ticket'     => [:author],
    :'show ticket'    => [:author],
    :'create ticket'  => [:author],
    :'update ticket'  => [:author],
    :'destroy ticket' => [:author],

    :'show ticket_state'    => [:author],
    :'create ticket_state'  => [:author],
    :'update ticket_state'  => [:author],
    :'destroy ticket_state' => [:author]
  }

  # Rbac.define do
    # role :anonymous,
    #      :grant => true
    #
    # role :user,
    #      :grant => :registered?,
    #      :parent => :anonymous,
    #      :message => :'adva.roles.errors.messages.not_logged_in'
    #
    # role :author,
    #      :require_context => Content,
    #      :grant => lambda{|context, user| context && !!context.try(:is_author?, user) },
    #      :parent => :user,
    #      :message => :'adva.roles.errors.messages.not_an_author'
    #
    # role :moderator,
    #      :require_context => Section,
    #      :parent => :author,
    #      :message => :'adva.roles.errors.messages.not_a_moderator'
    #
    # role :admin,
    #      :require_context => Site,
    #      :parent => :moderator,
    #      :message => :'adva.roles.errors.messages.not_an_admin'
    #
    # role :superuser,
    #      :parent => :admin,
    #      :message => :'adva.roles.errors.messages.not_a_superuser'
  # end
end
