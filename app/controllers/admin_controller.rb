class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :only => [:delete_file, :process_file, :add_url, :add_vote, :edit_vote, :is_law, :not_law, :edit_agenda, :edit_conference, :laws, :session_match] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:process_files])
  end
  before_filter :only => [:deleted_files, :restore_file] do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:lower_admin])
  end

  def index
  end

  def upload_files
    @upload_file = UploadFile.new
    @upload_file.number_possible_members = Agenda.default_number_possible_members
  end

  def delete_file
    upload_file = UploadFile.find_by_id(params[:id])

    if upload_file.present?
      upload_file.mark_as_deleted(current_user)
    end

		flash[:notice] =  t('app.msgs.success_deleted', :obj => t('activerecord.models.upload_file'))
		redirect_to admin_upload_files_path(:locale => I18n.locale)    
  end

  def process_file
    @upload_file = UploadFile.new
    @upload_file.xml = params[:xml]
    @upload_file.parliament_id = params[:parliament_id]
    @upload_file.number_possible_members = params[:number_possible_members]

    respond_to do |format|
      if @upload_file.save
        format.html { redirect_to admin_conference_path(@upload_file.conference.id), notice: t('app.msgs.success_created', :obj => t('activerecord.models.upload_file')) }
        format.json { render json: @upload_file, status: :created, location: @upload_file }
      else
        @upload_files = UploadFile.order("created_at desc")
        format.html { render action: "index" }
        format.json { render json: @upload_file.errors, status: :unprocessable_entity }
      end
    end
  end


  def conference
    @conference = Conference.not_deleted.find_by_id(params[:id])

    if !@conference.present?
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end

  def edit_conference
    @conference = Conference.not_deleted.find_by_id(params[:id])
    if @conference.present? 
      @upload_file = UploadFile.not_deleted.readonly(false).find_by_id(@conference.upload_file_id)

      if @upload_file && request.post? 
        @upload_file.update_data(params[:upload_file][:number_possible_members], params[:upload_file][:parliament_id])
        redirect_to admin_conference_path(params[:id]), 
            notice: t('app.msgs.success_updated', :obj => t('activerecord.models.conference'))
      end
    else 
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end

  def agenda
    @agenda = Agenda.not_deleted.find_by_id(params[:id])

    if !@agenda.present?
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end

  def edit_agenda
    @agenda = Agenda.not_deleted.readonly(false).find_by_id(params[:id])
    
    if @agenda.present?  
      @agenda.generate_missing_data
      
      if request.post?
        @agenda.update_attributes(params[:agenda])
        if params[:return_to].present? && params[:return_to] == Agenda::MAKE_PUBLIC_PARAM
          redirect_to admin_laws_path, 
              notice: t('app.msgs.success_updated', :obj => t('activerecord.models.agenda'))
        else
          redirect_to admin_agenda_path(@agenda.id), 
              notice: t('app.msgs.success_updated', :obj => t('activerecord.models.agenda'))
        end
      end
    else 
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end

  def add_vote
    @agenda = Agenda.not_deleted.readonly(false).find_by_id(params[:id])
    @groups = Group.by_conference(@agenda.conference_id)
    @available_delegates = AllDelegate.available_delegates(params[:id])
    if @agenda.present?
      if request.post?
        params[:delegates].keys.each do |key|
          delegate = params[:delegates][key]
          if delegate["vote"].present?

            # first create delegate record
            del = Delegate.create(:conference_id => @agenda.conference_id, :xml_id => delegate["xml_id"], 
              :group_id => delegate["group_id"],
              :first_name => delegate["first_name"])
            # now save voting result record
            VotingResult.create(:voting_session_id => @agenda.voting_session.id, 
                      :delegate_id => del.id,
                      :present => true,
                      :vote => delegate["vote"],
                      :is_manual_add => true)
          end
        end


        # update the voting session results
        @agenda.voting_session.update_results      

        redirect_to admin_agenda_path(@agenda.id), 
          notice: t('app.msgs.success_created', :obj => t('activerecord.models.voting_result'))
      end
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end

  def edit_vote
    @voting_result = VotingResult.not_deleted.readonly(false).find_by_id(params[:id])

    if @voting_result 
      if request.post?
        if @voting_result.vote.to_s != params[:voting_result][:vote]
          # the vote chagned, save it
          @voting_result.vote = params[:voting_result][:vote]
          @voting_result.is_edited = true
          @voting_result.save  

          # update the voting session results
          @voting_result.voting_session.update_results      
        end
        redirect_to admin_agenda_path(@voting_result.voting_session.agenda.id), 
            notice: t('app.msgs.success_updated', :obj => t('activerecord.models.voting_result'))
      end
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end

  def not_law
    @agenda = Agenda.not_deleted.readonly(false).find_by_id(params[:id])

    if @agenda.present?
      @agenda.is_law = false
      @agenda.save
      flash[:notice] = t('app.msgs.not_law', :name => @agenda.name)
      redirect_to admin_conference_path(@agenda.conference_id)
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end

  end


  def laws
  end

  def session_match
    @agenda = Agenda.not_deleted.readonly(false).find_by_id(params[:agenda_id])

    if !@agenda.present?
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end


  def save_session_match
    @agenda = Agenda.not_deleted.readonly(false).find_by_id(params[:agenda_id])
    @session_agenda = Agenda.not_deleted.find_by_id(params[:match_id])
    
    if @agenda.present? && @session_agenda.present?
      if params[:session] == "#{Agenda::PREFIX[3]} #{Agenda::CONSISTENT_SESSION_NAME[1]}"
        # first session
        @agenda.session_number1_id = @session_agenda.id
        @agenda.save
        flash[:notice] = t('app.msgs.assigned_session', :session => params[:session])
      elsif params[:session] == "#{Agenda::PREFIX[2]} #{Agenda::CONSISTENT_SESSION_NAME[1]}"
        # second session
        @agenda.session_number2_id = @session_agenda.id
        @agenda.save
        flash[:notice] = t('app.msgs.assigned_session', :session => params[:session])
      end
    end

		redirect_to admin_laws_path
  end

  def deleted_files

  end

  def restore_file
    file = UploadFile.deleted.find_by_id(params[:id])

    if file.present?
      file.restore(current_user)

		  flash[:notice] =  t('app.msgs.success_restored', :obj => t('activerecord.models.upload_file'))
		  redirect_to admin_deleted_files_path
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_upload_files_path(:locale => I18n.locale)
    end
  end


end
