Rbac.define do
  role :anonymous,
       :grant => true

  role :user,
       :grant => :registered?,
       :parent => :anonymous,
       :message => 'You need to be logged in to perform this action.'

  role :author,
       :require_context => Content,
       :grant => lambda{|context, user| context && !!context.try(:is_author?, user) },
       :parent => :user,
       :message => 'You need to be the author of this object to perform this action.'

  role :moderator,
       :require_context => Section,
       :parent => :author,
       :message => 'You need to be a moderator to perform this action.'

  role :admin,
       :require_context => Site,
       :parent => :moderator,
       :message => 'You need to be an admin to perform this action.'

  role :superuser,
       :parent => :admin,
       :message => 'You need to be a superuser to perform this action.'

  permissions :'create site'        => :superuser,
              :'update site'        => :admin,
              :'destroy site'       => :superuser,
              :'manage site'        => :admin,

              :'create section'     => :admin,
              :'update section'     => :admin,
              :'destroy section'    => :admin,
              :'manage section'     => :admin,

              :'create theme'       => :admin,
              :'update theme'       => :admin,
              :'destroy theme'      => :admin,
              :'manage theme'       => :admin,

              :'manage cached_page' => :admin,

              :'create user'        => :admin,
              :'update user'        => :admin,
              :'destroy user'       => :admin,
              :'manage user'        => :admin,

              :'manage roles'       => :admin,

              :'create category'    => :moderator,
              :'update category'    => :moderator,
              :'destroy category'   => :moderator,
              :'manage category'    => :moderator,

              :'create article'     => :moderator,
              :'update article'     => :moderator,
              :'destroy article'    => :moderator,
              :'manage article'     => :moderator,

              :'create wikipage'    => :user,
              :'update wikipage'    => :user,
              :'destroy wikipage'   => :moderator,
              :'manage wikipage'    => :moderator,

              :'create topic'       => :user,
              :'update topic'       => :author,
              :'destroy topic'      => :moderator,
              :'moderate topic'     => :moderator,

              :'create comment'     => :user,
              :'update comment'     => :author,
              :'destroy comment'    => :moderator,
              :'manage comment'     => :admin
end

