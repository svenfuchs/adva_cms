ActionController::Dispatcher.to_prepare do
  # Multisite (default is false)
  # to run more than one website with your adva_cms installation set this value to true
  Site.multi_sites_enabled = false

  # How many mails should adva send out per process? (default is 150)
  #
  # Current delivery implementation runs each minute new process until all mails are send out, after
  # that Adva mailer cleans out it's cronjob.
  # 
  # However, if you have huge amount of outgoing mails, you better consider to use some dedicated mailer. 
  # Adva is saiving outgoing mails to table "adva_emails" except urgent mails like account activisation mails etc.
  # Registry.instance[:number_of_outgoing_mails_per_process] = 150

  # Outgoing email header
  #
  # When you need custom outgoing email header then uncomment following and add missing info:
  # Registry.instance[:email_header]["Return-path"] = "site@example.org"
  # Registry.instance[:email_header]["Sender"]      = "site@example.org"
  # Registry.instance[:email_header]["Reply-To"]    = "site@example.org"
  # Registry.instance[:email_header]["Errors-To"]   = "errors@example.org"
  # Registry.instance[:email_header]["X-Originator-IP"] = "0.0.0.0"

  # turn this on to get detailed cache sweeper logging in production mode
  # Site.cache_sweeper_logging = true
end
