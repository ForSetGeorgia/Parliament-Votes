class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  protect_from_forgery

	before_filter :set_locale
  before_filter :preload_global_variables
  before_filter :initialize_gon
	before_filter :store_location

	layout :layout_by_resource

	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_url, :alert => exception.message
    end
	end

	def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
	end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

	def preload_global_variables
    # only load if not using the api
	  if params[:controller].present? && params[:controller].index('api') != 0
      @parliaments = Parliament.sorted_start_year
    end
	end

	def initialize_gon
    # only load if not using the api
	  if params[:controller].present? && params[:controller].index('api') != 0
		  gon.set = true

      gon.highlight_first_form_field = true if params[:controller].index('devise/').present?

		  if I18n.locale == :ka
		    gon.datatable_i18n_url = "/datatable_ka.txt"
		  else
		    gon.datatable_i18n_url = ""
		  end

      gon.table_cell_yes = I18n.t('helpers.boolean.y')
      gon.table_cell_no = I18n.t('helpers.boolean.n')
      gon.table_cell_abstain = I18n.t('helpers.boolean.abstain')
      gon.table_cell_not_started = I18n.t('helpers.not_started')
      gon.table_cell_left_early = I18n.t('helpers.left_early')

      if @parliaments.present?
        gon.parl_start_year = @parliaments.first.start_year.to_s
        gon.parl_end_year = @parliaments.first.end_year > Time.now.year ? Time.now.year.to_s : @parliaments.first.end_year.to_s
      else
        gon.parl_start_year = "2010"
        gon.parl_end_year = Time.now.year.to_s
      end
    end
	end

	# after user logs in, go to admin page
	def after_sign_in_path_for(resource)
		session[:previous_urls].present? ? session[:previous_urls].last : root_path
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end


	# store the current path so after login, can go back
	def store_location
		session[:previous_urls] ||= []
		# only record path if page is not for users (sign in, sign up, etc) and not for reporting problems
		if session[:previous_urls].first != request.fullpath && 
        params[:format] != 'js' && params[:format] != 'json' && 
        request.fullpath.index("/users/").nil?

			session[:previous_urls].unshift request.fullpath
		end
		session[:previous_urls].pop if session[:previous_urls].count > 1

#    Rails.logger.debug "****************** prev urls session = #{session[:previous_urls]}"
	end

	FB_ACTIONS = ['edit_vote', 'add_vote', 'edit_agenda', 'edit_conference', 'session_match']
  FB_CONTROLLER = 'admin'
	def layout_by_resource
    if FB_CONTROLLER == params[:controller] && FB_ACTIONS.index(params[:action]).present? 
      "fancybox"
    else
      "application"
    end
  end


  #######################
	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
