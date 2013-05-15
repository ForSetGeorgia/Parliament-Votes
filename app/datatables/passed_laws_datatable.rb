class PassedLawsDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :parliament, to: :@parliament

  def initialize(view, parliament)
    @view = view
    @parliament = parliament.class == String ? parliament.split(",") : parliament
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Agenda.includes(:conference).public_laws.with_parliament(@parliament).count,
      iTotalDisplayRecords: agendas.total_entries,
      aaData: data
    }
  end

private

  def data
    agendas.map do |agenda|
      [
        agenda.conference.start_date,
        link_to(agenda.official_law_title.present? ? agenda.official_law_title : agenda.name, 
          law_path(:id => agenda.public_url_id, :locale => I18n.locale)),
        agenda.parliament.name_formatted,
        agenda.total_yes,
        agenda.total_no,
        agenda.total_abstain,
        agenda.total_not_present
      ]
    end
  end

  def agendas
    @agendas ||= fetch_agendas
  end

  def fetch_agendas
    agendas = Agenda.includes(:conference).public_laws.with_parliament(@parliament).order("#{sort_column} #{sort_direction}")
    agendas = agendas.page(page).per_page(per_page)
    if params[:sSearch].present?
      agendas = agendas.where("agendas.official_law_title like :search or agendas.name like :search or agendas.law_description like :search", search: "%#{params[:sSearch]}%")
    end
    agendas
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[conferences.start_date agendas.official_law_title parliaments.start_year voting_sessions.result1 voting_sessions.result3 voting_sessions.result0 voting_sessions.not_present]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
