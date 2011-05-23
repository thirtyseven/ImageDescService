DiagramRailsApp::Application.routes.draw do
  get "daisy_book/upload"
  post "daisy_book/submit"
  get "daisy_book/edit"
  get "daisy_book/top_bar"
  post "daisy_book/get_xml_with_descriptions"

  resources :dynamic_descriptions

  resources :dynamic_images

  resources :descriptions

  resources :images do
    resources :descriptions
  end

  resources :libraries
  
  match "update_descriptions_in_book/upload" => "update_descriptions_in_book#upload", :via => "post"
  match "update_descriptions_in_book" => "update_descriptions_in_book#index", :via => "get"

  get "home/index"

  # match 'imageDesc' => "dynamic_images#show"
  match "imageDesc", :to => "dynamic_images#show", :via => "get"
  # match "imageDesc/uid/:uid/image_location/:image_location", :to => "dynamic_images#show", :via => "get"
  match "imageDesc", :to => "dynamic_descriptions#create", :via => "post"

  get "daisy_book/content"
  match "daisy_book/images/*image", :controller => 'daisy_book', :action => 'image'
  
  # match 'imageDesc/uid/:uid => 'dynamic_image#show'

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

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
