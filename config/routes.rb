get "hamsters/index", path: 'hamster'
post 'hamsters/start'
post 'hamsters/stop'
post 'hamsters/raport_time', as: 'raport_time'
post 'hamsters/destroy_all', as: 'remove_hamsters'

resources :hamsters, :only => [:update, :destroy]
resources :hamster_journals, :only => [:destroy, :update]

namespace :api do
  get 'hamster/index', to: 'hamsters#index'
  get 'hamster/my_issues', to: 'hamsters#my_issues'
  get 'hamster/mru', to: 'hamsters#mru'
  get 'hamster/my_active_hamsters', to: 'hamsters#my_active_hamsters'
  get 'hamster/my_ready_to_report_hamsters', to: 'hamsters#my_ready_to_raport_hamsters'
  post 'hamster/start', to: 'hamsters#start'
  post 'hamster/stop', to: 'hamsters#stop'
  patch 'hamster/update', to: 'hamsters#update'
  delete 'hamster/delete', to: 'hamsters#destroy'
  post 'hamster/report_time', to: 'hamsters#raport_time'

  get 'hamster_journals/hamster_journals', to: 'hamster_journals#hamster_journals'
  patch 'hamster_journals/update', to: 'hamster_journals#update'
  delete 'hamster_journals/delete', to: 'hamster_journals#destroy'
end
