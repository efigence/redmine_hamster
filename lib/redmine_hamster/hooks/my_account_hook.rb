class RedmineHamsterHookListener < Redmine::Hook::ViewListener
  render_on :view_my_account, :partial => "my/account_settings"
end