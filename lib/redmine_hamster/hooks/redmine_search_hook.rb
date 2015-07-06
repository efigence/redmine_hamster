class RedmineHamsterHookListener < Redmine::Hook::ViewListener
  render_on :redmine_search_issue_actions, :partial => "redmine_search/issue_action"
  render_on :view_layouts_base_html_head, :partial => "redmine_search/headers"
end