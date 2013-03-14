# encoding: utf-8
class SearchController < ApplicationController
  before_filter :authenticate_user!
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
      format.json { render json: UploadFileDatatable.new(view_context) }
    end
  end

  def deleted_files
    respond_to do |format|
      format.json { render json: DeletedFileDatatable.new(view_context) }
    end
  end


end
