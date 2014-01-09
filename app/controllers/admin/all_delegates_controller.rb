class Admin::AllDelegatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:lower_admin])
  end

  # GET /all_delegates
  # GET /all_delegates.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @all_delegates }
    end
  end

  # GET /all_delegates/1
  # GET /all_delegates/1.json
  def show
    @all_delegate = AllDelegate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @all_delegate }
    end
  end

  # GET /all_delegates/new
  # GET /all_delegates/new.json
  def new
    @all_delegate = AllDelegate.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
#    I18n.available_locales.each do |locale|
#			@all_delegate.all_delegate_translations.build(:locale => locale)
#		end

		gon.edit_all_delegate = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @all_delegate }
    end
  end

  # GET /all_delegates/1/edit
  def edit
    @all_delegate = AllDelegate.find(params[:id])

		gon.edit_all_delegate = true
		gon.started_at = @all_delegate.started_at.strftime('%m/%d/%Y') if @all_delegate.started_at.present?
		gon.ended_at = @all_delegate.ended_at.strftime('%m/%d/%Y') if @all_delegate.ended_at.present?
  end

  # POST /all_delegates
  # POST /all_delegates.json
  def create
    @all_delegate = AllDelegate.new(params[:all_delegate])

    respond_to do |format|
      if @all_delegate.save
        format.html { redirect_to admin_all_delegates_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.all_delegates')) }
        format.json { render json: @all_delegate, status: :created, location: @all_delegate }
      else
		    gon.edit_all_delegate = true
		    gon.started_at = @all_delegate.started_at.strftime('%m/%d/%Y') if @all_delegate.started_at.present?
		    gon.ended_at = @all_delegate.ended_at.strftime('%m/%d/%Y') if @all_delegate.ended_at.present?
        format.html { render action: "new" }
        format.json { render json: @all_delegate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /all_delegates/1
  # PUT /all_delegates/1.json
  def update
    @all_delegate = AllDelegate.find(params[:id])

    respond_to do |format|
      if @all_delegate.update_attributes(params[:all_delegate])
        format.html { redirect_to admin_all_delegates_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.all_delegates')) }
        format.json { head :ok }
      else
		    gon.edit_all_delegate = true
		    gon.started_at = @all_delegate.started_at.strftime('%m/%d/%Y') if @all_delegate.started_at.present?
		    gon.ended_at = @all_delegate.ended_at.strftime('%m/%d/%Y') if @all_delegate.ended_at.present?
        format.html { render action: "edit" }
        format.json { render json: @all_delegate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /all_delegates/1
  # DELETE /all_delegates/1.json
  def destroy
    @all_delegate = AllDelegate.find(params[:id])
    @all_delegate.destroy

    respond_to do |format|
      format.html { redirect_to admin_all_delegates_url }
      format.json { head :ok }
    end
  end
end
