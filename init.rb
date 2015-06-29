Redmine::Plugin.register :redmine_hamster do
  name 'Redmine Hamster plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :top_menu,
    :hamster, { controller: 'hamsters', action: 'index'},
    caption: :label_hamster, :after => :help,
    :if => proc { User.current.logged? }
  
  settings :default => {
    'group' => [],
    'start_at' => '09:00',
    'end_at' => '17:00'
  }, :partial => 'settings/redmine_hamster_settings'

  ActionDispatch::Callbacks.to_prepare do
    require 'redmine_hamster/hooks/my_account_hook'
    Issue.send(:include, RedmineHamster::Patches::IssuePatch)
    User.send(:include, RedmineHamster::Patches::UserPatch)
    MyController.send(:include, RedmineHamster::Patches::MyControllerPatch)
  end
end
