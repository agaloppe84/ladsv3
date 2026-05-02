class AdminV2::ProductDetailsController < AdminV2::ProductScopedController
  def update
    if @product.update(product_params)
      render_product_streams(
        details_panel_stream,
        drawer_summary_stream,
        level: :success,
        message: "Product##{@product.id} details updated"
      )
    else
      render_product_streams(
        details_panel_stream,
        level: :warning,
        message: @product.errors.full_messages.to_sentence.presence || "Product details invalid"
      )
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :category_id, :description, :infos, :warranty)
  end
end
