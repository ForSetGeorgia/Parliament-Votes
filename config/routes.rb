BootstrapStarter::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'},
											 :controllers => {:omniauth_callbacks => "omniauth_callbacks"}

		namespace :admin do
			resources :users
      resources :parliaments
      resources :all_delegates
		end

    # root controller
    match '/laws/', :to => 'root#laws_index', :as => :laws, :via => :get
    match '/laws/:id', :to => 'root#laws_show', :as => :law, :via => :get
    match '/laws_all/', :to => 'root#laws_all', :as => :laws_all, :via => :get
    match '/members/', :to => 'root#members_index', :as => :members, :via => :get
    match '/members/:id', :to => 'root#members_show', :as => :member, :via => :get
    match '/members_all/', :to => 'root#members_all', :as => :members_all, :via => :get

    # admin
    match '/admin/upload_files', :to => 'admin#upload_files', :as => :admin_upload_files, :via => :get
    match '/admin/process_file', :to => 'admin#process_file', :as => :admin_process_file, :via => :post
    match '/admin/delete_file/:id', :to => 'admin#delete_file', :as => :admin_delete_file, :via => :get
    match '/admin/conference/:id', :to => 'admin#conference', :as => :admin_conference, :via => :get
    match '/admin/edit_conference/:id', :to => 'admin#edit_conference', :as => :admin_edit_conference, :via => [:get, :post]
    match '/admin/agenda/:id', :to => 'admin#agenda', :as => :admin_agenda, :via => :get
    match '/admin/edit_agenda/:id', :to => 'admin#edit_agenda', :as => :admin_edit_agenda, :via => [:get, :post]
    match '/admin/edit_vote/:id', :to => 'admin#edit_vote', :as => :admin_edit_vote, :via => [:get, :post]
    match '/admin/add_vote/:id', :to => 'admin#add_vote', :as => :admin_add_vote, :via => [:get, :post]
    match '/admin/not_law/:id', :to => 'admin#not_law', :as => :admin_not_law, :via => :get
    match '/admin/laws', :to => 'admin#laws', :as => :admin_laws, :via => :get
    match '/admin/make_public/:id', :to => 'admin#make_public', :as => :admin_make_public, :via => :get
    match '/admin/unpublish/:id', :to => 'admin#unpublish', :as => :admin_unpublish, :via => :get
    match '/admin/session_match/:agenda_id/:session', :to => 'admin#session_match', :as => :admin_session_match, :via => :get
    match '/admin/session_match/:agenda_id/:session/:match_id', :to => 'admin#save_session_match', :as => :admin_save_session_match, :via => :get
    match '/admin/deleted_files', :to => 'admin#deleted_files', :as => :admin_deleted_files, :via => :get
    match '/admin/restore_file/:id', :to => 'admin#restore_file', :as => :admin_restore_file, :via => :get

    # admin search controller
    match '/admin/search/voting_results/:voting_session_id', :to => 'admin_search#voting_results', :as => :admin_search_voting_results, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/agendas/:conference_id(/:laws_only)', :to => 'admin_search#agendas', :as => :admin_search_agendas, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/files', :to => 'admin_search#files', :as => :admin_search_files, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/deleted_files', :to => 'admin_search#deleted_files', :as => :admin_search_deleted_files, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/laws', :to => 'admin_search#laws', :as => :admin_search_laws, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/sessions/:session/:agenda_id/:match_only', :to => 'admin_search#sessions', :as => :admin_search_sessions, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/users', :to => 'admin_search#users', :as => :admin_search_users, :via => :get, :defaults => {:format => 'json'}
    match '/admin/search/all_delegates', :to => 'admin_search#all_delegates', :as => :admin_search_all_delegates, :via => :get, :defaults => {:format => 'json'}

    # search controller
    match '/search/voting_results/:agenda_public_url_id', :to => 'search#voting_results', :as => :search_voting_results, :via => :get, :defaults => {:format => 'json'}
    match '/search/passed_laws', :to => 'search#passed_laws', :as => :search_passed_laws, :via => :get, :defaults => {:format => 'json'}
    match '/search/members', :to => 'search#members', :as => :search_members, :via => :get, :defaults => {:format => 'json'}
    match '/search/member_votes/:id', :to => 'search#member_votes', :as => :search_member_votes, :via => :get, :defaults => {:format => 'json'}
    
		# notifications
		match '/notifications', :to => 'notifications#index', :as => :notifications, :via => [:get, :post]


    # api
		match '/api', :to => 'api#index', :as => :api, :via => :get
		namespace :api do
			#v1
	    match '/v1' => 'v1#index', :via => :get
	    match '/v1/members' => 'v1#members', :via => :get, :defaults => {:format => 'json'}
	    match '/v1/member_votes' => 'v1#member_votes', :via => :get, :defaults => {:format => 'json'}
	    match '/v1/all_member_votes' => 'v1#all_member_votes', :via => :get, :defaults => {:format => 'json'}
      #v2
      match '/v2' => 'v2#index', :via => :get
      match '/v2/parliaments' => 'v2#parliaments', :via => :get, :defaults => {:format => 'json'}
      match '/v2/members' => 'v2#members', :via => :get, :defaults => {:format => 'json'}
      match '/v2/member_votes' => 'v2#member_votes', :via => :get, :defaults => {:format => 'json'}
      match '/v2/all_member_votes' => 'v2#all_member_votes', :via => :get, :defaults => {:format => 'json'}
		end




		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
