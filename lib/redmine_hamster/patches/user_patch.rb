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
          has_many :hamsters

          def working_hours
            if self.work_time.blank?
              WorkTime::DEFAULT
            else
              TimeDifference.between(self.work_time.start_at, self.work_time.end_at).in_hours
            end
          end

          def start_at
            return '09:00' if User.current.work_time.blank? || User.current.work_time.try(:start_at).blank?
            User.current.work_time.start_at.strftime('%H:%M')
          end

          def end_at
            return '17:00' if User.current.work_time.blank? || User.current.work_time.try(:end_at).blank?
            User.current.work_time.end_at.strftime('%H:%M')
          end

          def raported_days_count
            return 7 if User.current.work_time.blank? || User.current.work_time.try(:days_ago).blank?
            User.current.work_time.days_ago
          end

          def multi_start_enabled?
            return false if User.current.work_time.blank? || User.current.work_time.try(:multi_start).blank?
            User.current.work_time.multi_start
          end

          def has_access_to_hamster?
            !(hamster_user_ids & hamster_groups_with_access).blank?
          end

          def hamster_user_ids
            User.current.groups.select('id').collect{|el| el.id.to_s}
          end

          def hamster_groups_with_access
            Setting.plugin_redmine_hamster["groups"] || []
          end

        end
      end

      module InstanceMethods
        # ..
      end
    end
  end
end