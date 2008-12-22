= ar_mailer

A two-phase delivery agent for ActionMailer.  This fork of the ar_mailer gem is a setup-friendlier version of the original created Eric Hodel.

Alternative versions of this gem:

* http://rubyforge.org/projects/seattlerb (The Original)
* http://github.com/adzap/ar_mailer/wikis


== About

Even delivering email to the local machine may take too long when you have to
send hundreds of messages.  ar_mailer allows you to store messages into the
database for later delivery by a separate process, ar_sendmail.


== Installing ar_mailer

Add this to your environment.rb:

  config.gem 'cyu-ar_mailer', :version => '1.4.4', :lib => 'ar_mailer', :source => 'http://gems.github.com'

And install the gem using rake:

  $ sudo rake gems:install

Alternatively, you do a manual install:

  $ sudo gem sources -a http://gems.github.com
  $ sudo gem install cyu-ar_mailer

See ActionMailer::ARMailer for instructions on converting to ARMailer.

See ar_sendmail -h for options to ar_sendmail.


=== init.d/rc.d scripts

For Linux both script and demo config files are in share/linux. 
See ar_sendmail.conf for setting up your config. Copy the ar_sendmail file 
to /etc/init.d/ and make it executable. Then for Debian based distros run
'sudo update-rc.d ar_sendmail defaults' and it should work. Make sure you have 
the config file /etc/ar_sendmail.conf in place before starting.

For FreeBSD or NetBSD script is share/bsd/ar_sendmail. This is old and does not
support the config file unless someone wants to submit a patch.
