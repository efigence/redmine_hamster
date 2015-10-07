module RedmineHamster
  class LoadData
    class << self
      
      def my_issues opt = nil
        opt = opt || 'DESC'
        Issue.my_only_open.order("#{Issue.table_name}.updated_on #{opt}").to_a
      end

      def my_active_hamsters
        HamsterIssue.my
      end

      def my_ready_to_raport_hamsters
        Hamster.my.group_by {|h| h.start_at.to_date }
      end

      def mru
        Issue.joins(:time_entries).merge(TimeEntry.order(updated_on: :desc)).
              where(time_entries: {user_id: User.current.id,
                                  updated_on: date_from..DateTime.now}).
              group('issue_id') - my_issues
      end

      def raported_time
        TimeEntry.
          where("#{TimeEntry.table_name}.user_id = ? AND #{TimeEntry.table_name}.spent_on BETWEEN ? AND ?", User.current.id, Date.today - 6, Date.today).
          order("#{TimeEntry.table_name}.spent_on DESC").
          to_a
      end

      private

      def date_from
        User.current.raported_days_count.business_days.ago.beginning_of_day
      end
    end
  end
end