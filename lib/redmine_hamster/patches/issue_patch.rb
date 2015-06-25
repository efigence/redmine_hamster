require_dependency 'issue'

module RedmineHamster
  module Patches
    module IssuePatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          has_one :hamster_issue
          scope :my_open, -> {  visible.open.
                                where(assigned_to_id: ([User.current.id] + User.current.group_ids),
                                      projects: { status: Project::STATUS_ACTIVE }).
                                includes(:status, :project, :tracker, :priority).
                                references(:status, :project, :tracker, :priority).
                                order("#{IssuePriority.table_name}.position DESC, #{Issue.table_name}.updated_on DESC")
                             }

          def has_hamster_issue?
            self.hamster_issue.blank?
          end
        end
      end

      module InstanceMethods
        # ..
      end
    end
  end
end
