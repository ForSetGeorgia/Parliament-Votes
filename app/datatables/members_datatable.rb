class MembersDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, to: :@view
  delegate :parliament, to: :@parliament
  delegate :law_title, to: :@law_title

  def initialize(view, parliament, law_title=nil)
    @view = view
    @parliament = parliament.class == String ? parliament.split(",") : parliament
    @law_title = law_title
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: AllDelegate.with_parliament(@parliament).count,
      iTotalDisplayRecords: members.total_entries,
      aaData: data
    }
  end

private
  
  def data
    members.map do |member|
      [
        link_to(member.first_name, member_path(:id => member.id, :locale => I18n.locale, :q => @law_title)),
        member.parliament.name_formatted,
        member.vote_count,
        member.yes_count,
        member.no_count,
        member.abstain_count,
        member.absent_count
      ]
    end
  end

  def members
    @members ||= fetch_members
  end

  def fetch_members
    members = AllDelegate.with_parliament(@parliament).order("#{sort_column} #{sort_direction}")
    members = members.page(page).per_page(per_page)
    if params[:sSearch].present?
      members = members.where("all_delegates.first_name like :search", search: "%#{params[:sSearch]}%")
    end
    members
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[all_delegates.first_name parliaments.start_year all_delegates.vote_count all_delegates.yes_count all_delegates.no_count all_delegates.abstain_count all_delegates.absent_count]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
