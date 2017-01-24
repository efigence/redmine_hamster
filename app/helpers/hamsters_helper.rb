module HamstersHelper
  def activity_collection_for_select_options(time_entry=nil, project=nil)
    project ||= @project
    project.nil? ? TimeEntryActivity.shared.active : project.activities
  end
end
