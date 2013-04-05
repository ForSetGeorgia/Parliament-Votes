class AgendaDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :conference_id, to: :@conference_id
  delegate :laws_only, to: :@laws_only
  delegate :current_user, to: :@current_user

  def initialize(view, current_user, conference_id, laws_only)
    @view = view
    @conference_id = conference_id
    @laws_only = laws_only == "true" ? true : false
    @current_user = current_user
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Agenda.not_deleted.by_conference(@conference_id).laws_only(@laws_only).count,
      iTotalDisplayRecords: agendas.total_entries,
      aaData: data
    }
  end

private

  def data
    agendas.map do |agenda|
      [
        agenda.sort_order,
        link_to(agenda.official_law_title.present? ? agenda.official_law_title : agenda.name, 
          admin_agenda_path(:id => agenda.id, :locale => I18n.locale, :laws_only => params[:laws_only])),
        agenda.law_title,
        agenda.law_description,
        agenda.session_number,
        agenda.registration_number,
        agenda.voting_session.nil? ? nil : "#{agenda.voting_session.passed_formatted} (#{agenda.total_yes} / #{agenda.total_no} / #{agenda.total_abstain})",
        agenda.voting_session.nil? ? nil : "#{agenda.voting_session.quorum_formatted} (#{agenda.voting_session.result5})",
        is_public_text(agenda),
        change_status_link(agenda)
      ]
    end
  end

  def is_public_text(agenda)
    if agenda.is_public
      return "<span class=\"law_is_public\">#{I18n.t('helpers.boolean.y')}</span>"
    end
  end

  def change_status_link(agenda)
    if agenda.is_law && @current_user.role?(User::ROLES[:process_files]) 
      link_to(I18n.t('helpers.links.unmake_law'), admin_not_law_path(:id => agenda.id, :locale => I18n.locale), 
             :class => 'btn btn-mini')  
    elsif !agenda.is_law && @current_user.role?(User::ROLES[:process_files]) 
      link_to(I18n.t('helpers.links.make_law'), admin_edit_agenda_path(:id => agenda.id, :locale => I18n.locale), 
             :class => 'btn btn-mini fancybox_live')  
    end
  end

  def agendas
    @agendas ||= fetch_agendas
  end

  def fetch_agendas
    agendas = Agenda.not_deleted.by_conference(@conference_id).laws_only(@laws_only).order("#{sort_column} #{sort_direction}")
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
    columns = %w[agendas.sort_order agendas.official_law_title agendas.law_title agendas.law_description agendas.session_number agendas.registration_number voting_sessions.passed voting_sessions.quorum agendas.is_public agendas.sort_order]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
