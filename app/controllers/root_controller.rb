class RootController < ApplicationController

  def index
  end

  def law
    @agenda = Agenda.final_laws.not_deleted.find_by_id(params[:id])
    if !@agenda.present?
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end

  def member
    @member = AllDelegate.find_by_id(params[:id])

    if @member.present?
      @agendas = AllDelegate.passed_laws_voting_history(@member.first_name)
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end


end
