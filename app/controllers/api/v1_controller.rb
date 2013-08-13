class Api::V1Controller < ApplicationController

  def index
	  respond_to do |format|
	    format.html # index.html.erb
	  end
  end
  
  def q
    if params[:member_id].present?
      # if with_laws provided, convert to boolean
      with_laws = params[:with_laws].present? && params[:with_laws] =~ (/(true|t|yes|y|1)$/i) ? true : false
      respond_to do |format|
        format.json { 
          render json: AllDelegate.api_v1_by_member(params[:member_id], with_laws)
        }
      end
    else
      # member id not provided, go back to index page
      redirect_to :action => 'index'
    end
  end

end
