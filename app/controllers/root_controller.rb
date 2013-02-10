class RootController < ApplicationController

  def index
    @upload_file = UploadFile.new
    @upload_files = UploadFile.order("created_at desc")
  end

  def process_file
    @upload_file = UploadFile.new
    @upload_file.xml = params[:xml]

    respond_to do |format|
      if @upload_file.save
        format.html { redirect_to conference_path(@upload_file.conference.id), notice: t('app.msgs.success_created', :obj => t('activerecord.models.upload_file')) }
        format.json { render json: @upload_file, status: :created, location: @upload_file }
      else
        @upload_files = UploadFile.order("created_at desc")
        format.html { render action: "index" }
        format.json { render json: @upload_file.errors, status: :unprocessable_entity }
      end
    end
  end


  def conference
    @conference = Conference.find(params[:id])
  end

  def agenda
    @agenda = Agenda.find(params[:id])
  end

end
