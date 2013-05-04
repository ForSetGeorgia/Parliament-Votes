class UsersDatatable
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
      iTotalRecords: user_query.count,
      iTotalDisplayRecords: users.total_entries,
      aaData: data
    }
  end

private

  def data
    users.map do |user|
      [
        user.email,
        user.role_name.humanize,
        user.provider.present? ? user.provider.humanize : '',
        action_links(user)
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def action_links(user)
    x = ''
    x << link_to(I18n.t('.edit', :default => I18n.t("helpers.links.edit")),
                      edit_admin_user_path(user, :locale => I18n.locale), :class => 'btn btn-mini')
    x << "  "
    x << link_to(I18n.t('.destroy', :default => I18n.t("helpers.links.destroy")),
                      admin_user_path(user, :locale => I18n.locale),
                      :method => :delete,
											:data => { :confirm => I18n.t('.confirm', :default => I18n.t("helpers.links.confirm")) },
                      :class => 'btn btn-mini btn-danger')
    return x
  end

  def user_query
    if @current_user.present? && @current_user.role == User::ROLES[:admin]
Rails.logger.debug "++++++++++++++++++++++++ all users"
      User
    else
Rails.logger.debug "++++++++++++++++++++++++ no admins"
      User.no_admins
    end
  end

  def fetch_users
    users = user_query.order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("users.email like :search", search: "%#{params[:sSearch]}%")
    end
    users
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[users.email users.role users.provider users.email]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
