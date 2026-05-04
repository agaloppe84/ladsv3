class AdminV2::ProductColorPartsController < AdminV2::ProductScopedController
  def create
    attrs = color_part_params.to_h.symbolize_keys
    palette_name = attrs.delete(:palette_name)

    ActiveRecord::Base.transaction do
      palette = ColorPalette.create!(name: palette_name.presence || "#{@product.name} - #{attrs[:label].presence || "Part"}")
      @product.product_color_parts.create!(attrs.merge(color_palette: palette))
    end

    render_product_streams(
      configurator_panel_stream,
      level: :success,
      message: "Product##{@product.id} color part created",
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
    part = @product.product_color_parts.includes(:color_palette).find(params[:id])
    attrs = color_part_params.to_h.symbolize_keys
    palette_name = attrs.delete(:palette_name)

    ActiveRecord::Base.transaction do
      part.update!(attrs)
      part.color_palette.update!(name: palette_name) if palette_name.present?
    end

    render_product_streams(
      configurator_panel_stream,
      level: :success,
      message: "ColorPart##{part.id} updated",
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
    part = @product.product_color_parts.includes(:color_palette).find(params[:id])
    palette = part.color_palette

    ActiveRecord::Base.transaction do
      part.destroy!
      palette.destroy! if palette.product_color_parts.reload.empty?
    end

    render_product_streams(
      configurator_panel_stream,
      level: :success,
      message: "ColorPart##{part.id} removed",
      event_type: :delete
    )
  rescue ActiveRecord::RecordNotDestroyed => e
    render_product_streams(
      configurator_panel_stream,
      level: :error,
      message: e.record.errors.full_messages.to_sentence.presence || "Color part remove failed",
      event_type: :error
    )
  end

  private

  def color_part_params
    params.require(:product_color_part).permit(:code, :label, :palette_name)
  end
end
