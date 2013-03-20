# encoding: UTF-8

class LawsDatatable
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
      iTotalRecords: Agenda.not_deleted.final_laws.count,
      iTotalDisplayRecords: agendas.total_entries,
      aaData: data
    }
  end

private

  def data
    agendas.map do |agenda|
      [
        link_to(agenda.official_law_title.present? ? agenda.official_law_title : agenda.name, 
          agenda_path(:id => agenda.id, :locale => I18n.locale)),
        agenda.law_title,
        agenda.law_description,
        agenda.session_number,
        agenda.voting_session.nil? ? nil : "#{agenda.voting_session.passed_formatted} (#{agenda.total_yes} / #{agenda.total_no} / #{agenda.total_abstain})",
        has_law_ids(agenda),
        has_session1(agenda),
        has_session2(agenda),
        can_publish(agenda)
      ]
    end
  end

  def has_law_ids(agenda)
    if agenda.law_id.present? && agenda.law_url.present?
      link_to agenda.law_id, agenda.law_url, :target => :blank
    else
      link_to(I18n.t('helpers.links.add'), 
        edit_agenda_path(:id => agenda.id, :return_to => Agenda::MAKE_PUBLIC_PARAM, :locale => I18n.locale), 
        :class => 'btn btn-mini btn-danger fancybox')
    end
  end

  def has_session1(agenda)
    if agenda.session_number.index(Agenda::FINAL_VERSION[0]).nil?
      if agenda.session_number1_id.present?
        link_to(I18n.t('helpers.links.view'), agenda_path(:id => agenda.session_number1_id, :locale => I18n.locale), :class => 'btn btn-mini')
      else
        link_to(I18n.t('helpers.links.add'), "#", :class => 'btn btn-mini btn-danger')
      end
    end
  end

  def has_session2(agenda)
    if agenda.session_number.index(Agenda::FINAL_VERSION[0]).nil?
      if agenda.session_number2_id.present?
        link_to(I18n.t('helpers.links.view'), agenda_path(:id => agenda.session_number2_id, :locale => I18n.locale), :class => 'btn btn-mini')
      else
        link_to(I18n.t('helpers.links.add'), "#", :class => 'btn btn-mini btn-danger')
      end
    end
  end

  def can_publish(agenda)
    if agenda.law_id.present? && agenda.law_url.present? && (agenda.session_number.index(Agenda::FINAL_VERSION[0]).present? ||
      (agenda.session_number1_id.present? && agenda.session_number2_id.present?))
      link_to(I18n.t('helpers.links.publish'), "#", :class => 'btn btn-mini btn-success')
    end
  end



  def agendas
    @agendas ||= fetch_agendas
  end

  def fetch_agendas
    agendas = Agenda.not_deleted.final_laws.order("#{sort_column} #{sort_direction}")
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
    columns = %w[agendas.official_law_title agendas.law_title agendas.law_description agendas.session_number voting_sessions.passed agendas.law_id agendas.session_number1_id agendas.session_number2_id agendas.official_law_title]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
