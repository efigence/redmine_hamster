get "hamsters/index", path: 'hamster'
post 'hamsters/start'
post 'hamsters/stop'
post 'hamsters/raport_time', as: 'raport_time'

resources :hamsters, :only => [:update, :destroy]