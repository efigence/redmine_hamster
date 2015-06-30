require_dependency 'my_controller'

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
            multi = params[:multi_start].blank? ? false : true
            if params[:start_at] && params[:end_at] || multi
              if WorkTime.find_by(user_id: User.current.id).blank?
                create_working_hours(multi)
              else
                update_working_hours(multi)
              end
            end
          end

          def create_working_hours multi = nil
            w = WorkTime.create(user_id: User.current.id, start_at: params[:start_at], end_at: params[:end_at],
                multi_start: multi, start_status_to: params[:start_status_to], stop_status_to: params[:stop_status_to])
            flash[:error] = w.errors.full_messages.first if w.errors.any?
          end

          def update_working_hours multi = nil
            w = WorkTime.find_by(user_id: User.current.id)
            w.start_at = params[:start_at]
            w.end_at = params[:end_at]
            w.multi_start = multi
            w.start_status_to = params[:start_status_to]
            w.stop_status_to = params[:stop_status_to]
            if w.save
              true
            else
              flash[:error] = w.errors.full_messages.first
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
 