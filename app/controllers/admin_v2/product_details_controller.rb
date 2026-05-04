class AdminV2::ProductDetailsController < AdminV2::ProductScopedController
  def update
    permitted_params = product_params

    if @product.update(permitted_params)
      render_product_streams(
        *success_streams(permitted_params),
        level: :success,
        message: detail_message(permitted_params),
        event_type: :autosave
      )
    else
      render_product_streams(
        level: :warning,
        message: @product.errors.full_messages.to_sentence.presence || "Product details invalid",
        event_type: :error,
        status: :unprocessable_entity
      )
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :infos, :warranty)
  end

  def success_streams(permitted_params)
    return [] unless permitted_params.key?(:name) || permitted_params.key?("name")

    [header_title_stream, drawer_summary_stream]
  end

  def detail_message(permitted_params)
    field = permitted_params.keys.first.to_s.presence || "details"
    "Product##{@product.id} #{field} updated"
  end
end
