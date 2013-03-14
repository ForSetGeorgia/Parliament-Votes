class DeletedFileDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: UploadFile.deleted.with_conference.count,
      iTotalDisplayRecords: upload_files.total_entries,
      aaData: data
    }
  end

private

  def data
    upload_files.map do |upload_file|
      [
        I18n.l(upload_file.deleted_at, :format => :no_zone),
        upload_file.conference.name,
        I18n.l(upload_file.conference.start_date, :format => :no_zone),
        upload_file.number_possible_members,
        upload_file.conference.number_laws,
        upload_file.conference.number_sessions,
        upload_file.xml_file_name,
        I18n.l(upload_file.created_at, :format => :no_zone),
        link_to(I18n.t("helpers.links.restore"), restore_file_path(:id => upload_file.id, :locale => I18n.locale), 
          :data => { :confirm => I18n.t('.confirm', :default => I18n.t("helpers.links.confirm")) },
          :class => 'btn btn-mini btn-primary')
      ]
    end
  end

  def upload_files
    @upload_files ||= fetch_upload_files
  end

  def fetch_upload_files
    upload_files = UploadFile.deleted.with_conference.order("#{sort_column} #{sort_direction}")
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
    columns = %w[upload_files.deleted_at conferences.name conferences.start_date upload_files.number_possible_members conferences.number_laws conferences.number_sessions upload_files.xml_file_name upload_files.created_at upload_file.deleted_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
