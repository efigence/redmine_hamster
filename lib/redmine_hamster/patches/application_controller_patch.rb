require_dependency 'my_controller'
require 'pry'

module RedmineHamster
  module Patches
    module ApplicationControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          before_action :find_menu

          def find_menu
            if User.current.logged? && (User.current.admin? || User.current.has_access_to_hamster?) && HamsterIssue.my.any?
              @my_current_issue = HamsterIssue.my.first.issue
              @show_current = WorkTime.find_by(user: User.current)
            end
          end
        end
      end

      module InstanceMethods
        # ..
      end
    end
  end
end
