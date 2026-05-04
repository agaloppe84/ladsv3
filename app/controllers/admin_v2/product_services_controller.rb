class AdminV2::ProductServicesController < AdminV2::ProductScopedController
  def update
    service = @product.service || @product.build_service

    if service.update(service_params)
      render_product_streams(
        service_panel_stream,
        level: :success,
        message: "Product##{@product.id} service updated",
        event_type: :autosave
      )
    else
      render_product_streams(
        service_panel_stream,
        level: :warning,
        message: service.errors.full_messages.to_sentence.presence || "Service invalid",
        event_type: :error
      )
    end
  end

  private

  def service_params
    params.require(:service).permit(:warranty, :custom_dimensions, :made_in_france, :free_quote, :anti_fire, :anti_uv, :rge, :wind_resistance)
  end
end
