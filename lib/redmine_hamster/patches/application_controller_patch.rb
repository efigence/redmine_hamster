require_dependency 'application_controller'

module RedmineHamster
  module Patches
    module ApplicationControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          before_action :find_menu

          def find_menu
            if active_issues_visible? && HamsterIssue.my.any?
              @my_current_issue = HamsterIssue.my.first.issue
              @show_current = WorkTime.find_by(user: User.current)
            end
          end

          private

          def active_issues_visible?
            user = User.current
            user.logged? && user.has_access_to_hamster? && user.work_time.try(:show_current_issue)
          end
        end
      end

      module InstanceMethods
        # ..
      end
    end
  end
end
