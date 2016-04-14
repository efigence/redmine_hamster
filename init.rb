# encoding: utf-8
require_relative 'app/models/hamster_issue'

Redmine::Plugin.register :redmine_hamster do
  name 'Redmine Hamster plugin'
  author 'Marcin Świątkiewicz'
  description "Plugin helps users to control spent time on issue."
  version '0.0.1'
  url 'https://github.com/efigence/redmine_hamster'
  author_url 'http://www.efigence.com/'

  menu :top_menu,
       :hamster, {controller: 'hamsters', action: 'index'},
       caption: :label_hamster, :after => :help,
       :if => proc { User.current.logged? && (User.current.admin? || User.current.has_access_to_hamster?) }

  settings :default => {
      'groups' => []
  }, :partial => 'settings/redmine_hamster_settings'

  ActionDispatch::Callbacks.to_prepare do
    require 'redmine_hamster/hooks/layout_hook'
    require 'redmine_hamster/hooks/my_account_hook'
    require 'redmine_hamster/hooks/redmine_search_hook'
    require 'redmine_hamster/redmine_hamster'
    Issue.send(:include, RedmineHamster::Patches::IssuePatch)
    User.send(:include, RedmineHamster::Patches::UserPatch)
    MyController.send(:include, RedmineHamster::Patches::MyControllerPatch)
    ApplicationController.send(:include, RedmineHamster::Patches::ApplicationControllerPatch)
  end
end