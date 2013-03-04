BootstrapStarter::Application.routes.draw do
	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

		namespace :admin do
			resources :users
		end

    # root controller
    match '/process_file', :to => 'root#process_file', :as => :process_file, :via => :post
    match '/conference/:id', :to => 'root#conference', :as => :conference, :via => :get
    match '/edit_number_members/:id', :to => 'root#edit_number_members', :as => :edit_number_members, :via => :get
    match '/edit_number_members/:id', :to => 'root#edit_number_members', :as => :edit_number_members, :via => :post
    match '/agenda/:id', :to => 'root#agenda', :as => :agenda, :via => :get
    match '/edit_agenda/:id', :to => 'root#edit_agenda', :as => :edit_agenda, :via => :get
    match '/edit_agenda/:id', :to => 'root#edit_agenda', :as => :edit_agenda, :via => :post
    match '/edit_vote/:id', :to => 'root#edit_vote', :as => :edit_vote, :via => :get
    match '/edit_vote/:id', :to => 'root#edit_vote', :as => :edit_vote, :via => :post
    match '/add_vote/:id', :to => 'root#add_vote', :as => :add_vote, :via => :get
    match '/add_vote/:id', :to => 'root#add_vote', :as => :add_vote, :via => :post
    match '/not_law/:id', :to => 'root#not_law', :as => :not_law, :via => :get

    # search controller
    match '/search/voting_results/:voting_session_id', :to => 'search#voting_results', :as => :search_voting_results, :via => :get, :defaults => {:format => 'json'}
    match '/search/agendas/:conference_id(/:laws_only)', :to => 'search#agendas', :as => :search_agendas, :via => :get, :defaults => {:format => 'json'}
    match '/search/files', :to => 'search#files', :as => :search_files, :via => :get, :defaults => {:format => 'json'}

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
