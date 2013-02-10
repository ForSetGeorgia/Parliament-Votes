BootstrapStarter::Application.routes.draw do
	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users
		namespace :admin do
			resources :users
		end

    # root controller
    match '/process_file', :to => 'root#process_file', :as => :process_file, :via => :post
    match '/conference/:id', :to => 'root#conference', :as => :conference, :via => :get
    match '/agenda/:id', :to => 'root#agenda', :as => :agenda, :via => :get

    # search controller
    match '/search/voting_results/:voting_session_id', :to => 'search#voting_results', :as => :search_voting_results, :via => :get, :defaults => {:format => 'json'}
    match '/search/agendas/:conference_id', :to => 'search#agendas', :as => :search_agendas, :via => :get, :defaults => {:format => 'json'}

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
