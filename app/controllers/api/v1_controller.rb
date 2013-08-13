class Api::V1Controller < ApplicationController

  def index
	  respond_to do |format|
	    format.html # index.html.erb
	  end
  end
  
  def q
    respond_to do |format|
      format.json { render json: ["this is the query"] }
    end
  end

end
