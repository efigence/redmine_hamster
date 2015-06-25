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

  ActionDispatch::Callbacks.to_prepare do
    Issue.send(:include, RedmineHamster::Patches::IssuePatch)
  end
end
