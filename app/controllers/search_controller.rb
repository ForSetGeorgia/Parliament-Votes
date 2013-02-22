# encoding: utf-8
class SearchController < ApplicationController
  before_filter :authenticate_user!
  
  def voting_results
    respond_to do |format|
      format.json { render json: VotingResultDatatable.new(view_context, current_user, params[:voting_session_id]) }
    end
  end

  def agendas
    respond_to do |format|
      format.json { render json: AgendaDatatable.new(view_context, params[:conference_id], params[:laws_only]) }
    end
  end

  def files
    respond_to do |format|
      format.json { render json: UploadFileDatatable.new(view_context) }
    end
  end


end
