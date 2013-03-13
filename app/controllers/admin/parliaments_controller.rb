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
		gon.edit_parliament = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @parliament }
    end
  end

  # GET /parliaments/1/edit
  def edit
    @parliament = Parliament.find(params[:id])
		gon.edit_parliament = true
		gon.start_date = @parliament.start_date.strftime('%m/%d/%Y') if !@parliament.start_date.nil?
		gon.end_date = @parliament.end_date.strftime('%m/%d/%Y') if !@parliament.end_date.nil?
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
    		gon.edit_parliament = true
		    gon.start_date = @parliament.start_date.strftime('%m/%d/%Y') if !@parliament.start_date.nil?
		    gon.end_date = @parliament.end_date.strftime('%m/%d/%Y') if !@parliament.end_date.nil?
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
    		gon.edit_parliament = true
		    gon.start_date = @parliament.start_date.strftime('%m/%d/%Y') if !@parliament.start_date.nil?
		    gon.end_date = @parliament.end_date.strftime('%m/%d/%Y') if !@parliament.end_date.nil?
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
