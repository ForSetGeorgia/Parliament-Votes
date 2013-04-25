class RootController < ApplicationController

  def index
  end

  def law
    @agenda = Agenda.public_laws.find_by_public_url_id(params[:id])
    if !@agenda.present?
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end

  def member
    @member = AllDelegate.find_by_id(params[:id])

    if !@member.present?
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end


end
