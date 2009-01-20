# Adva config

# How many mails should adva send out per process? (default is 150)
#
# Current delivery implementation runs each minute new process until all mails are send out, after
# that Adva mailer cleans out it's cronjob.
# 
# However, if you have huge amount of outgoing mails, you better consider to use some dedicated mailer. 
# Adva is saiving outgoing mails to table "emails" except urgent mails like account activisation mails etc.
Adva::Config.number_of_outgoing_mails_per_process = 150


# Multisite (default is false)
# to run more than one website with your adva_cms installation set this value to true

Site.multi_sites_enabled = false

