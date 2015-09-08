get "hamsters/index", path: 'hamster'
post 'hamsters/start'
post 'hamsters/stop'
post 'hamsters/raport_time', as: 'raport_time'
post 'hamsters/destroy_all', as: 'remove_hamsters'

resources :hamsters, :only => [:update, :destroy]