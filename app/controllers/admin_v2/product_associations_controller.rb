class AdminV2::ProductAssociationsController < AdminV2::ProductScopedController
  def update
    if @product.update(association_params)
      render_product_streams(
        associations_panel_stream,
        drawer_summary_stream,
        level: :success,
        message: "Product##{@product.id} associations updated",
        event_type: :autosave
      )
    else
      render_product_streams(
        associations_panel_stream,
        level: :warning,
        message: @product.errors.full_messages.to_sentence.presence || "Associations invalid",
        event_type: :error
      )
    end
  end

  private

  def association_params
    params.require(:product).permit(manufacturer_ids: [], motorist_ids: [])
  end
end
