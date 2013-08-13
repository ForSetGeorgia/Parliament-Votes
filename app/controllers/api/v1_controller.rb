class Api::V1Controller < ApplicationController

  def index
	  respond_to do |format|
	    format.html # index.html.erb
	  end
  end
  
  def members
      respond_to do |format|
        format.json { 
          render json: AllDelegate.api_v1_members()
        }
      end
  end
  
  def member_votes
    if params[:member_id].present?
      # if with_laws provided, convert to boolean
      with_laws = params[:with_laws].present? && params[:with_laws] =~ (/(true|t|yes|y|1)$/i) ? true : false
      # if dates provided, make sure they are valid dates
      if params[:passed_after].present?
        passed_after = Date.parse(params[:passed_after]) rescue nil
      end
      if params[:passed_before].present?
        passed_before = Date.parse(params[:passed_before]) rescue nil
      end
      if params[:made_public_after].present?
        made_public_after = Date.parse(params[:made_public_after]) rescue nil
      end
      if params[:made_public_before].present?
        made_public_before = Date.parse(params[:made_public_before]) rescue nil
      end
      respond_to do |format|
        format.json { 
          render json: AllDelegate.api_v1_member_votes(params[:member_id], with_laws, 
            passed_after, passed_before, made_public_after, made_public_before)
        }
      end
    else
      # member id not provided, go back to index page
      redirect_to :action => 'index'
    end
  end

end
