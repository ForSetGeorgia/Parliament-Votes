class SessionsDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :current_user, to: :@current_user
  delegate :matches_only, to: :@matches_only
  delegate :session, to: :@session
  delegate :agenda_id, to: :@agenda_id

  def initialize(view, current_user, session, agenda_id, matches_only = false)
    @view = view
    @current_user = current_user
    @session = session
    @matches_only = matches_only
    @agenda_id = agenda_id
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: agenda_query.count,
      iTotalDisplayRecords: agendas.total_entries,
      aaData: data
    }
  end

private

  def data
    agendas.map do |agenda|
      [
        link_to(I18n.t('helpers.links.assign_session'), admin_save_session_match_path(:locale => I18n.locale, :agenda_id => @agenda_id, :session => @session, :match_id => agenda.id),
            :class => 'btn btn-mini btn-success'),
        I18n.l(agenda.conference.start_date, :format => :no_zone),
        agenda.official_law_title.present? ? agenda.official_law_title : agenda.name,
        agenda.law_title,
        agenda.law_description,
        agenda.session_number,
        agenda.registration_number,
        agenda.voting_session.nil? ? nil : "#{agenda.voting_session.passed_formatted} (#{agenda.total_yes} / #{agenda.total_no} / #{agenda.total_abstain})"
      ]
    end
  end


  def agendas
    @agendas ||= fetch_agendas
  end

  def agenda_query
    if @matches_only == "true"
Rails.logger.debug "++++++++++++++++++++++++ getting sessions that match"
      Agenda.not_deleted.passed_laws_by_session_matching(@session, @agenda_id)
    else
Rails.logger.debug "++++++++++++++++++++++++ getting all sessions"
      Agenda.not_deleted.passed_laws_by_session(@session, @agenda_id)
    end
  end

  def fetch_agendas
    agendas = agenda_query.order("#{sort_column} #{sort_direction}")
    agendas = agendas.page(page).per_page(per_page)
    if params[:sSearch].present?
      agendas = agendas.where("agendas.name like :search or agendas.description like :search", search: "%#{params[:sSearch]}%")
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
    columns = %w[conferences.start_date conferences.start_date agendas.official_law_title agendas.law_title agendas.law_description agendas.session_number agendas.registration_number voting_sessions.passed]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
