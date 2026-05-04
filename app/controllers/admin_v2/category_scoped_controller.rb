class AdminV2::CategoryScopedController < AdminV2::BaseController
  before_action :set_category

  private

  def set_category
    @category = Category.find(params[:category_id])
    track_admin_v2_context(@category)
  end

  def render_category_streams(*streams, level: :success, message:, event_type: :update, status: :ok)
    render turbo_stream: [
      *streams,
      *admin_v2_feedback_streams(
        level,
        message,
        event_type: event_type,
        resource: @category,
        status_code: Rack::Utils.status_code(status)
      )
    ], status: status
  end

  def category_row_stream
    turbo_stream.replace(
      "admin_v2_category_#{@category.id}",
      partial: "admin_v2/categories/row",
      locals: { category: category_with_count }
    )
  end

  def drawer_summary_stream
    turbo_stream.replace(
      "admin_v2_category_drawer_summary",
      partial: "admin_v2/categories/drawer_summary",
      locals: { category: @category }
    )
  end

  def drawer_header_stream
    turbo_stream.replace(
      "admin_v2_category_drawer_header",
      partial: "admin_v2/categories/drawer_header",
      locals: { category: @category }
    )
  end

  def details_panel_stream
    turbo_stream.replace(
      "admin_v2_category_details",
      partial: "admin_v2/categories/panels/details",
      locals: { category: @category }
    )
  end

  def appearance_panel_stream
    turbo_stream.replace(
      "admin_v2_category_appearance",
      partial: "admin_v2/categories/panels/appearance",
      locals: { category: @category }
    )
  end

  def category_with_count
    Category
      .left_joins(:products)
      .select("categories.*, COUNT(products.id) FILTER (WHERE products.type IS NULL) AS admin_v2_products_count")
      .where(categories: { id: @category.id })
      .group("categories.id")
      .first || @category
  end
end
