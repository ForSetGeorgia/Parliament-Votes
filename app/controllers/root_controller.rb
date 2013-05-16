class RootController < ApplicationController

  def index
    if request.post?
      if params[:law_title].present?
        redirect_to laws_path(:q => params[:law_title], 
          :parliament => params[:parliament].present? && params[:parliament].class == Array ? params[:parliament].join(",") : nil)
      elsif params[:member_name].present?
        redirect_to members_path(:q => params[:member_name], 
          :parliament => params[:parliament].present?  && params[:parliament].class == Array ? params[:parliament].join(",") : nil)
      end
    end
  end

  def laws_index
    gon.passed_laws_filter = true
    gon.initial_search = params[:q]
    @parl_ids = params[:parliament].present? ? params[:parliament].split(',') : nil
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
    gon.initial_search = params[:q]
    @parl_ids = params[:parliament].present? ? params[:parliament].split(',') : nil
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
