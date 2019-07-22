module RedmineIncomingEmails
  module Patches
    module MailHandlerPatch
      def self.apply
        unless MailHandler < self
          MailHandler.prepend self
        end
      end

      def target_project
        target_project_id = Setting.plugin_redmine_incoming_emails[user.mail].to_i
        target = Project.find(target_project_id) if target_project_id > 0
        target || super
      end
    end
  end
end

