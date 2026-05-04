class AdminV2::ColorPaletteItemsController < AdminV2::ProductScopedController
  before_action :set_part

  def create
    @part.color_palette.color_palette_items.create!(item_params)
    render_product_streams(
      configurator_panel_stream,
      level: :success,
      message: "Color added to #{@part.code}",
      event_type: :create
    )
  rescue ActiveRecord::RecordInvalid => e
    render_product_streams(
      configurator_panel_stream,
      level: :warning,
      message: e.record.errors.full_messages.to_sentence,
      event_type: :error
    )
  end

  def update
    item = @part.color_palette.color_palette_items.find(params[:id])
    item.update!(paid_option: ActiveModel::Type::Boolean.new.cast(params.dig(:color_palette_item, :paid_option)))
    render_product_streams(
      *color_palette_item_streams,
      level: :success,
      message: "PaletteItem##{item.id} updated",
      event_type: :autosave
    )
  rescue ActiveRecord::RecordInvalid => e
    render_product_streams(
      configurator_panel_stream,
      level: :warning,
      message: e.record.errors.full_messages.to_sentence,
      event_type: :error
    )
  end

  def destroy
    item = @part.color_palette.color_palette_items.find(params[:id])
    item.destroy!
    render_product_streams(
      *color_palette_item_streams,
      level: :success,
      message: "PaletteItem##{item.id} removed",
      event_type: :delete
    )
  rescue ActiveRecord::RecordNotDestroyed => e
    render_product_streams(
      configurator_panel_stream,
      level: :error,
      message: e.record.errors.full_messages.to_sentence.presence || "Palette item remove failed",
      event_type: :error
    )
  end

  private

  def set_part
    @part = @product.product_color_parts.includes(:color_palette).find(params[:color_part_id])
  end

  def item_params
    attrs = params.require(:color_palette_item).permit(:ral_id, :finish_id, :paid_option).to_h.symbolize_keys
    attrs[:finish_id] = attrs[:finish_id].presence
    attrs[:paid_option] = ActiveModel::Type::Boolean.new.cast(attrs[:paid_option])
    attrs
  end

  def color_palette_item_streams
    streams = [configurator_panel_stream]
    streams << color_part_drawer_stream if drawer_context?
    streams
  end

  def color_part_drawer_stream
    turbo_stream.replace(
      "admin_v2_drawer",
      partial: "admin_v2/product_color_parts/drawer_frame",
      locals: { product: @product, part: @part }
    )
  end

  def drawer_context?
    params[:admin_v2_drawer_context] == "color_part"
  end
end
