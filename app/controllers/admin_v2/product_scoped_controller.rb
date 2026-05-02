class AdminV2::ProductScopedController < AdminV2::BaseController
  before_action :set_product

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def render_product_streams(*streams, level: :success, message:)
    render turbo_stream: [
      *streams,
      turbo_stream_flash(level, message)
    ]
  end

  def media_panel_stream
    turbo_stream.replace(
      "admin_v2_product_media",
      partial: "admin_v2/products/panels/media",
      locals: { product: @product }
    )
  end

  def documentations_panel_stream
    turbo_stream.replace(
      "admin_v2_product_documentations",
      partial: "admin_v2/products/panels/documentations",
      locals: { product: @product }
    )
  end

  def options_panel_stream
    turbo_stream.replace(
      "admin_v2_product_options",
      partial: "admin_v2/products/panels/options",
      locals: { product: @product }
    )
  end

  def service_panel_stream
    turbo_stream.replace(
      "admin_v2_product_service",
      partial: "admin_v2/products/panels/service",
      locals: { product: @product }
    )
  end

  def associations_panel_stream
    turbo_stream.replace(
      "admin_v2_product_associations",
      partial: "admin_v2/products/panels/associations",
      locals: { product: @product }
    )
  end

  def details_panel_stream
    turbo_stream.replace(
      "admin_v2_product_details",
      partial: "admin_v2/products/panels/details",
      locals: { product: @product, categories: Category.order(:name) }
    )
  end

  def configurator_panel_stream
    turbo_stream.replace(
      "admin_v2_product_configurator",
      partial: "admin_v2/products/panels/configurator",
      locals: configurator_locals
    )
  end

  def drawer_summary_stream
    turbo_stream.replace(
      "admin_v2_product_drawer_summary",
      partial: "admin_v2/products/drawer_summary",
      locals: { product: @product }
    )
  end

  def configurator_locals
    {
      product: @product,
      product_color_parts: @product.product_color_parts.includes(color_palette: { color_palette_items: [:ral, :finish] }).order(:created_at),
      rals: Ral.order(:collection, :ref),
      finishes: Finish.order(:label)
    }
  end
end
