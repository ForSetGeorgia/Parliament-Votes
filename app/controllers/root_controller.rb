class RootController < ApplicationController

  def index
  end

  def laws_index
    gon.passed_laws_filter = true
  end

  def laws_show
    @agenda = Agenda.public_laws.find_by_public_url_id(params[:id])
    if @agenda.present?
		  respond_to do |format|
		    format.html # index.html.erb
		    format.json { render json: @agenda }
		  end

      # update the view count
      impressionist(@agenda)
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end

  def members_index
  end

  def members_show
    @member = AllDelegate.find_by_id(params[:id])

    if @member.present?
		  respond_to do |format|
		    format.html # index.html.erb
		    format.json { render json: @member }
		  end

      # update the view count
      impressionist(@member)
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end

  def laws_all
    @agendas = Agenda.public_laws.map{|x| x.public_url_id}
  end

  def members_all
    @members = AllDelegate.select("id").map{|x| x.id}
  end


end
