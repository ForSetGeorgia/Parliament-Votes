class AdminSearchController < ApplicationController
  before_filter :authenticate_user!
  before_filter :except => [:delete_files] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:process_files])
  end
  before_filter :only => [:delete_files] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:lower_admin])
  end
  
  def voting_results
    respond_to do |format|
      format.json { render json: VotingResultDatatable.new(view_context, current_user, params[:voting_session_id]) }
    end
  end

  def agendas
    respond_to do |format|
      format.json { render json: AgendaDatatable.new(view_context, current_user, params[:conference_id], params[:laws_only]) }
    end
  end

  def files
    respond_to do |format|
      format.json { render json: UploadFileDatatable.new(view_context, current_user) }
    end
  end

  def deleted_files
    respond_to do |format|
      format.json { render json: DeletedFileDatatable.new(view_context) }
    end
  end

  def laws
    respond_to do |format|
      format.json { render json: LawsDatatable.new(view_context, current_user) }
    end
  end

  def sessions
    respond_to do |format|
      format.json { render json: SessionsDatatable.new(view_context, current_user, params[:session], params[:agenda_id], params[:match_only]) }
    end
  end

  def users
    respond_to do |format|
      format.json { render json: UsersDatatable.new(view_context, current_user) }
    end
  end


end
