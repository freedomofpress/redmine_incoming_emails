Redmine::Plugin.register :redmine_incoming_emails do
  name 'Incoming Emails plugin'
  author 'Mark Whitfeld'
  description 'This is a plugin for Redmine that allows for the configuration of the default project used when a user logs a new issue using email.'
  version '0.1.0'
  url 'https://github.com/markwhitfeld/redmine_incoming_emails'
  author_url 'https://github.com/markwhitfeld/redmine_incoming_emails'

  requires_redmine version_or_higher: '4.0.0'

  settings(:partial => 'settings/incoming_emails_settings',
           :default => {} )
end

Rails.configuration.to_prepare do
  RedmineIncomingEmails::Patches::MailHandlerPatch.apply
end

