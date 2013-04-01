class SearchController < ApplicationController
  
  def passed_laws
    respond_to do |format|
      format.json { render json: PassedLawsDatatable.new(view_context) }
    end
  end

  def members
    respond_to do |format|
      format.json { render json: MembersDatatable.new(view_context) }
    end
  end
end
