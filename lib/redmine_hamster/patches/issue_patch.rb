require_dependency 'issue'
module RedmineHamster
  module Patches
    module IssuePatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_many :hamster_issues
          has_many :hamsters
          scope :my_open, -> {  visible.open.
                                where(assigned_to_id: ([User.current.id] + User.current.group_ids),
                                      projects: { status: Project::STATUS_ACTIVE }).
                                includes(:status, :project, :tracker, :priority).
                                references(:status, :project, :tracker, :priority).
                                order("#{IssuePriority.table_name}.position DESC")
                             }

          def has_hamster_issue?
            self.hamster_issues.find_by(user_id: User.current.id).blank? ? false : true
          end

          def change_issue_status action
            if self.assigned_to_id == User.current.id && action
              status = User.current.work_time.try(action)
              if status.blank? || !self.new_statuses_allowed_to(User.current).map(&:id).include?(status)
                self.touch
              else
                self.update_attributes(status_id: status)
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
