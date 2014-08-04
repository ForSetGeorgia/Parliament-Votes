class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	def facebook
		user = User.from_omniauth(request.env["omniauth.auth"])
		if user.persisted?
			flash.notice = I18n.t('devise.sessions.signed_in')
			sign_in_and_redirect user
		else
			session["devise.user_attributes"] = user.attributes
			redirect_to new_user_registration_url
		end
	end

  def failure
    set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to after_omniauth_failure_path_for(resource_name)
  end  

end
