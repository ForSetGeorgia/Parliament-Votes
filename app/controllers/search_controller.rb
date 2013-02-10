# encoding: utf-8
class SearchController < ApplicationController
  
  def voting_results
    respond_to do |format|
      format.json { render json: VotingResultDatatable.new(view_context, params[:voting_session_id]) }
    end
  end

  def agendas
    respond_to do |format|
      format.json { render json: AgendaDatatable.new(view_context, params[:conference_id]) }
    end
  end


end
