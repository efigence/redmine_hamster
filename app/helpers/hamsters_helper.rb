module HamstersHelper
  def activity_collection_for_select_options(time_entry=nil, project=nil)
    project ||= @project
    if project.nil?
      activities = TimeEntryActivity.shared.active
    else
      activities = project.activities
    end
    activities
  end
end
