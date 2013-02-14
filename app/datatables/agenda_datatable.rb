class AgendaDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :conference_id, to: :@conference_id

  def initialize(view, conference_id)
    @view = view
    @conference_id = conference_id
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Agenda.by_conference(@conference_id).count,
      iTotalDisplayRecords: agendas.total_entries,
      aaData: data
    }
  end

private

  def data
    agendas.map do |agenda|
      [
        link_to(agenda.name, agenda_path(:id => agenda.id, :locale => I18n.locale)),
        agenda.session_number,
        agenda.registration_number,
        agenda.voting_session.nil? ? nil : "#{agenda.voting_session.passed_formatted} (#{agenda.voting_session.result1} / #{agenda.voting_session.result3})",
        agenda.voting_session.nil? ? nil : "#{agenda.voting_session.quorum_formatted} (#{agenda.voting_session.result5})"
      ]
    end
  end

  def agendas
    @agendas ||= fetch_agendas
  end

  def fetch_agendas
    agendas = Agenda.by_conference(@conference_id).order("#{sort_column} #{sort_direction}")
    agendas = agendas.page(page).per_page(per_page)
    if params[:sSearch].present?
      agendas = agendas.where("agendas.name like :search or agendas.session_number like :search or agendas.registration_number like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[agendas.name agendas.session_number agendas.registration_number voting_sessions.passed voting_sessions.quorum]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
