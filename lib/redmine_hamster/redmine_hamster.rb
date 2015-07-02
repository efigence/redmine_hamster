module RedmineHamster
  class LoadData
    class << self
      
      def my_issues
        Issue.my_open.to_a
      end

      def my_active_hamsters
        HamsterIssue.my
      end

      def my_ready_to_raport_hamsters
        Hamster.my.group_by {|h| h.start_at.to_date }
      end

      def mru
        Issue.joins(:time_entries).
              where(time_entries: {user_id: User.current.id,
                                  updated_on: date_from..DateTime.now}).
              group('issue_id') - my_issues
      end

      private

      def date_from
        User.current.raported_days_count.business_days.ago.beginning_of_day
      end
    end
  end
end