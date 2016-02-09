module RedmineHamster
  module Hooks
    class LayoutHook < Redmine::Hook::ViewListener
      render_on(:view_layouts_base_html_head, :partial => 'my/current_issue', :layout => false)
    end
  end
end
