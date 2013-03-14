class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:lower_admin])
  end

  def index

  end

  def deleted_files

  end

  def restore_file
    file = UploadFile.deleted.find_by_id(params[:id])

    if file.present?
      file.restore(current_user)

		  flash[:notice] =  t('app.msgs.success_restored', :obj => t('activerecord.models.upload_file'))
		  redirect_to deleted_files_path
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
    end
  end


end
