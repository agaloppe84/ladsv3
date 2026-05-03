class AdminV2::ProductCategoriesController < AdminV2::ProductScopedController
  def update
    if @product.update(product_params)
      render_product_streams(
        header_category_stream,
        drawer_summary_stream,
        level: :success,
        message: "Product##{@product.id} category updated"
      )
    else
      render_product_streams(
        category_panel_stream,
        level: :warning,
        message: @product.errors.full_messages.to_sentence.presence || "Product category invalid"
      )
    end
  end

  private

  def product_params
    params.require(:product).permit(:category_id)
  end
end
