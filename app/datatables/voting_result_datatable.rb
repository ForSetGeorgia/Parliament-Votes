class VotingResultDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :voting_session_id, to: :@voting_session_id

  def initialize(view, voting_session_id)
    @view = view
    @voting_session_id = voting_session_id
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: VotingResult.by_session(@voting_session_id).count,
      iTotalDisplayRecords: voting_results.total_entries,
      aaData: data
    }
  end

private

  def data
    voting_results.map do |voting_result|
      [
        vote_link(voting_result),
        voting_result.delegate.first_name,
        voting_result.delegate.title,
        voting_result.delegate.group.present? ? voting_result.delegate.group.short_name : nil,
        voting_result.present_formatted,
        vote_text(voting_result)
      ]
    end
  end

  def vote_text(voting_result)
    x = voting_result.vote_formatted

    if voting_result.is_manual_add
      x << "<span class=\"manually_added_vote\">#{I18n.t('app.common.manually_added')}</span>"
    end

    if voting_result.is_edited
      x << "<span class=\"edited_vote\">#{I18n.t('app.common.edited')}</span>"
    end

    return x
  end

  def vote_link(voting_result)
    if voting_result.voting_session.agenda.is_law && current_user.role?(User::ROLES[:process_files]) 
      link_to(I18n.t('helpers.links.edit'), edit_vote_path(:id => voting_result.id, :locale => I18n.locale), 
             :class => 'btn btn-mini fancybox')  
    end
  end

  def voting_results
    @voting_results ||= fetch_voting_results
  end

  def fetch_voting_results
    voting_results = VotingResult.by_session(@voting_session_id).order("#{sort_column} #{sort_direction}")
    voting_results = voting_results.page(page).per_page(per_page)
    if params[:sSearch].present?
      voting_results = voting_results.where("delegates.first_name like :search", search: "%#{params[:sSearch]}%")
    end
    voting_results
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[edit delegates.first_name delegates.title groups.short_name voting_results.present voting_results.vote]
    index = params[:iSortCol_0].to_i == 0 ? 1 : params[:iSortCol_0].to_i
    columns[index]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
