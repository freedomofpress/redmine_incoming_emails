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

      def cleanup_body(body)
        super.tap do |text|
          unless user.logged?
            sender = email.from.to_a.first.to_s.strip
            text.prepend "From: #{sender}\n\n"
          end
        end
      end
    end
  end
end

