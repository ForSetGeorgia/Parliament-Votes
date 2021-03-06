class SearchController < ApplicationController
  
  def passed_laws
    respond_to do |format|
      format.json { render json: PassedLawsDatatable.new(view_context, params[:parliament], params[:start_date], params[:end_date]) }
    end
  end

  def members
    respond_to do |format|
      format.json { render json: MembersDatatable.new(view_context, params[:parliament], params[:law_title], params[:start_date], params[:end_date]) }
    end
  end

  def voting_results
    respond_to do |format|
      format.json { render json: VotingResultPublicDatatable.new(view_context, params[:agenda_public_url_id], params[:get_all_3_sessions].present? ? params[:get_all_3_sessions] : "true") }
    end
  end

  def member_votes
    respond_to do |format|
      format.json { render json: MemberVotesDatatable.new(view_context, params[:id], params[:start_date], params[:end_date]) }
    end
  end


end
