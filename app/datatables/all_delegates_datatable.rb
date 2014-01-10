class AllDelegatesDatatable
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
      iTotalRecords: AllDelegate.with_parliament(@parliament).count,
      iTotalDisplayRecords: all_delegates.total_entries,
      aaData: data
    }
  end

private

  def data
    all_delegates.map do |all_delegate|
      [
        all_delegate.first_name,
        all_delegate.started_at,
        all_delegate.ended_at,
        action_links(all_delegate)
      ]
    end
  end

  def all_delegates
    @all_delegates ||= fetch_all_delegates
  end

  def action_links(all_delegate)
    x = ''
    x << link_to(I18n.t('.edit', :default => I18n.t("helpers.links.edit")),
                      edit_admin_all_delegate_path(all_delegate, :locale => I18n.locale), :class => 'btn btn-mini')
    return x
  end

  def fetch_all_delegates
    all_delegates = AllDelegate.with_parliament(@parliament).order("#{sort_column} #{sort_direction}")
    all_delegates = all_delegates.page(page).per_page(per_page)
    if params[:sSearch].present?
      all_delegates = all_delegates.where("all_delegates.first_name like :search", search: "%#{params[:sSearch]}%")
    end
    all_delegates
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[all_delegates.first_name all_delegates.started_at all_delegates.ended_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
