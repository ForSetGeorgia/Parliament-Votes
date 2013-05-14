class Admin::ParliamentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:lower_admin])
  end

  # GET /parliaments
  # GET /parliaments.json
  def index
    @parliaments = Parliament.sorted_name

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parliaments }
    end
  end

  # GET /parliaments/1
  # GET /parliaments/1.json
  def show
    @parliament = Parliament.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @parliament }
    end
  end

  # GET /parliaments/new
  # GET /parliaments/new.json
  def new
    @parliament = Parliament.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@parliament.parliament_translations.build(:locale => locale)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @parliament }
    end
  end

  # GET /parliaments/1/edit
  def edit
    @parliament = Parliament.find(params[:id])
  end

  # POST /parliaments
  # POST /parliaments.json
  def create
    @parliament = Parliament.new(params[:parliament])

    respond_to do |format|
      if @parliament.save
        format.html { redirect_to admin_parliaments_path, notice: t('app.msgs.success_created', :obj => t('activerecord.models.parliament')) }
        format.json { render json: @parliament, status: :created, location: @parliament }
      else
        format.html { render action: "new" }
        format.json { render json: @parliament.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /parliaments/1
  # PUT /parliaments/1.json
  def update
    @parliament = Parliament.find(params[:id])

    respond_to do |format|
      if @parliament.update_attributes(params[:parliament])
        format.html { redirect_to admin_parliaments_path, notice: t('app.msgs.success_updated', :obj => t('activerecord.models.parliament')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @parliament.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parliaments/1
  # DELETE /parliaments/1.json
  def destroy
    @parliament = Parliament.find(params[:id])
    @parliament.destroy

    respond_to do |format|
      format.html { redirect_to admin_parliaments_url }
      format.json { head :ok }
    end
  end
end
