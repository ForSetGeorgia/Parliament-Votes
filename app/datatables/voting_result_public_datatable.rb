class VotingResultPublicDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :agenda_public_url_id, to: :@agenda_public_url_id
  delegate :get_all_3_sessions, to: :@get_all_3_sessions

  def initialize(view, agenda_public_url_id, get_all_3_sessions="true")
    @view = view
    @agenda_public_url_id = agenda_public_url_id
    @get_all_3_sessions = get_all_3_sessions
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: AllDelegate.votes_for_passed_law(@agenda_public_url_id, @get_all_3_sessions).count,
      iTotalDisplayRecords: all_delegates.length,
      aaData: data
    }
  end

private

  def data
    if @get_all_3_sessions == "true"
      all_delegates.map do |all_delegate|
        [
          link_to(all_delegate.first_name, member_path(:id => all_delegate.id, :locale => I18n.locale)),
          all_delegate.session1_vote_formatted,
          all_delegate.session2_vote_formatted,
          all_delegate.session3_vote_formatted
        ]
      end
    else
      all_delegates.map do |all_delegate|
        [
          link_to(all_delegate.first_name, member_path(:id => all_delegate.id, :locale => I18n.locale)),
          all_delegate.session3_vote_formatted
        ]
      end
    end
  end

  def all_delegates
    @all_delegates ||= fetch_all_delegates
  end

  def fetch_all_delegates
    search = nil
    if params[:sSearch].present?
      search = params[:sSearch]
    end
    
    AllDelegate.votes_for_passed_law(@agenda_public_url_id, @get_all_3_sessions, search, sort_column, sort_direction, per_page, page)
  end

  def page
    params[:iDisplayStart].to_i/per_page
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    if @get_all_3_sessions == "true"
      columns = %w[ad.first_name s1.vote s2.vote s3.vote]
    else
      columns = %w[ad.first_name s3.vote]
    end
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
