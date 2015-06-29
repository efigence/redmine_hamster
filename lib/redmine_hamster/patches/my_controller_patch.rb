require_dependency 'my_controller'
require 'pry'

module RedmineHamster
  module Patches
    module MyControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          after_filter :set_working_hours, only: [:account]

          private

          def set_working_hours
            if params[:start_at] && params[:end_at]
              if WorkTime.find_by(user_id: User.current.id).blank?
                WorkTime.create(user_id: User.current.id, start_at: params[:start_at], end_at: params[:end_at])
              else
                WorkTime.find_by(user_id: User.current.id).update_attributes(start_at: params[:start_at], end_at: params[:end_at])
              end
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
