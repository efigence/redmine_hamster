require_dependency 'my_controller'

module RedmineHamster
  module Patches
    module MyControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          after_filter :save_work_time, only: [:account]

          private

          def save_work_time
            if request.post? && params[:user] && params[:user][:work_time]
              work_time = @user.work_time || @user.build_work_time
              work_time.safe_attributes = params[:user][:work_time]
              unless work_time.save
                flash[:error] = work_time.errors.full_messages.first
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
 