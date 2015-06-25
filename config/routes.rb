get "hamsters/index", path: 'hamster'
post 'hamsters/start'
post 'hamsters/stop'
resources :hamsters, :only => [:update, :destroy]