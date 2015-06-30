require_dependency 'user'
module RedmineHamster
  module Patches
    module UserPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_one :work_time
          has_many :hamster_issues

          def working_hours
            if self.work_time.blank?
              WorkTime::DEFAULT
            else
              TimeDifference.between(self.work_time.start_at, self.work_time.end_at).in_hours
            end
          end

          def start_at
            User.current.work_time.blank? ? '09:00' : User.current.work_time.start_at.strftime('%H:%M')
          end

          def end_at
            User.current.work_time.blank? ? '17:00' : User.current.work_time.end_at.strftime('%H:%M')
          end

          def multi_start_enabled?
            User.current.work_time.blank? ? false : User.current.work_time.multi_start
          end

        end
      end

      module InstanceMethods
        # ..
      end
    end
  end
end