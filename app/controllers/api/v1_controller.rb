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

    # record call to google analytics
    record_analytics("members")
  end
  
  def member_votes
    if params[:member_id].present?
      # convert string into boolean
      with_laws = params[:with_laws].present? && params[:with_laws] =~ (/(true|t|yes|y|1)$/i) ? true : false
      with_law_vote_summary = params[:with_law_vote_summary].present? && params[:with_law_vote_summary] =~ (/(true|t|yes|y|1)$/i) ? true : false

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
          render json: AllDelegate.api_v1_member_votes(params[:member_id], with_laws, with_law_vote_summary,
            passed_after, passed_before, made_public_after, made_public_before)
        }
      end
      
      # record call to google analytics
      record_analytics("member_votes")
    else
      # member id not provided, go back to index page
      redirect_to :action => 'index'
    end
  end

protected

  # record call to google analytics
  def record_analytics(api_method)
    ga_id = nil
    domain = nil
    if Rails.env.production?
      ga_id = 'UA-12801815-23'
      domain = 'votes.parliament.ge'
    elsif Rails.env.staging?
      ga_id = 'UA-12801815-15'
      domain = 'dev-parlvote.jumpstart.ge'
    end
    # page view format is (title, url)
    if ga_id.present?
      g = Gabba::Gabba.new(ga_id, domain)
      g.referer(request.env['HTTP_REFERER'])
      g.ip(request.remote_ip)
      g.page_view("api:v1:#{api_method}", request.fullpath) 
    end
  end  
  

end
