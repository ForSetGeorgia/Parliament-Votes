class RootController < ApplicationController

  def index
    @upload_file = UploadFile.new

    if request.post?
      @upload_file = UploadFile.new(params[:upload_file])

      respond_to do |format|
        if @upload_file.save
          format.html { redirect_to root_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.upload_file')) }
          format.json { render json: @upload_file, status: :created, location: @upload_file }
        else
          format.html { render action: "index" }
          format.json { render json: @upload_file.errors, status: :unprocessable_entity }
        end
      end
      
    end
  end


end
