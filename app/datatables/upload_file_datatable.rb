class UploadFileDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :current_user, to: :@current_user

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: UploadFile.not_deleted.with_conference.count,
      iTotalDisplayRecords: upload_files.total_entries,
      aaData: data
    }
  end

private

  def data
    upload_files.map do |upload_file|
      [
        upload_file.conference.present? ? link_to(upload_file.conference.name, admin_conference_path(:id => upload_file.conference.id, :locale => I18n.locale)) : nil,
        upload_file.conference.present? ? I18n.l(upload_file.conference.start_date, :format => :no_zone) : nil,
        upload_file.parliament.present? ? upload_file.parliament.name : nil,
        upload_file.number_possible_members,
        upload_file.conference.present? ? upload_file.conference.number_laws : nil,
        upload_file.conference.present? ? upload_file.conference.number_sessions : nil,
        upload_file.xml_file_name == 'transfer' ? upload_file.xml_file_name : link_to(upload_file.xml_file_name, upload_file.xml.url, :target => '_blank'),
        I18n.l(upload_file.created_at, :format => :no_zone),
        delete_link(upload_file)
      ]
    end
  end

  def delete_link(upload_file)
    if @current_user.role?(User::ROLES[:process_files])
      link_to(I18n.t("helpers.links.destroy"), admin_delete_file_path(:id => upload_file.id, :locale => I18n.locale),
          :data => { :confirm => I18n.t('.confirm', :default => I18n.t("helpers.links.confirm")) },
          :class => 'btn btn-mini btn-danger')
    end
  end

  def upload_files
    @upload_files ||= fetch_upload_files
  end

  def fetch_upload_files
    upload_files = UploadFile.not_deleted.with_conference.with_parliament.order("#{sort_column} #{sort_direction}")
    upload_files = upload_files.page(page).per_page(per_page)
    upload_files
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[conferences.name conferences.start_date upload_file.parliament_id upload_files.number_possible_members conferences.number_laws conferences.number_sessions upload_files.xml_file_name upload_files.created_at conferences.name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
