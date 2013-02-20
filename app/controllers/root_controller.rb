class RootController < ApplicationController
  before_filter :authenticate_user!
  before_filter :only => [:process_file] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:process_files])
  end

  def index
    @upload_file = UploadFile.new
  end

  def process_file
    @upload_file = UploadFile.new
    @upload_file.xml = params[:xml]
    @upload_file.number_possible_members = params[:number_possible_members]

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

  def edit_vote
    @voting_result = VotingResult.find_by_id(params[:id])

    if request.post?
      if @voting_result.vote.to_s != params[:voting_result][:vote]
        # the vote chagned, save it
        @voting_result.vote = params[:voting_result][:vote]
        @voting_result.save        
      end
      redirect_to agenda_path(@voting_result.voting_session.agenda.id), 
          notice: t('app.msgs.success_updated', :obj => t('activerecord.models.voting_result'))
    end
  end

end
