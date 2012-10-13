Leader::Application.routes.draw do
  mount Ckeditor::Engine => "/ckeditor"

  resources(:quoted_prices, :only => [:search, :show]) do
    collection do
      get 'search'
      post 'search'
    end

    member do
      get 'show'
    end
  end
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  resources :users, :only => [:show]

  resources :bills, :only => [:search] do
    collection do
      post 'search'
    end
  end

  resources :news, :only => [:show, :index]

  get "static_pages/home"
  get "static_pages/products"
  get "static_pages/about"
  
  namespace :admin do
    resources :bills, :except => :show
    resources :news, :except => [:show, :index]
    resources :users, :except => [:show]
    resources :quoted_prices do
      collection do
        post 'download'
        get 'search'
        post 'search'
        post 'create_all'
        post 'update_all'
        get 'edit_all'
      end
       
      resources :attachments, :only => [:new, :create, :show], :path => "pricetable"
    end

  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'static_pages#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
