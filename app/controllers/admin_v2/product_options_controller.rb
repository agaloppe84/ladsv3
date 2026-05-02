class AdminV2::ProductOptionsController < AdminV2::ProductScopedController
  def create
    @product.options.create!(content: "Nouvelle option", order: next_order)
    render_product_streams(
      options_panel_stream,
      level: :success,
      message: "Product##{@product.id} option created"
    )
  end

  def update
    option = @product.options.find(params[:id])

    if option.update(option_params)
      render_product_streams(
        options_panel_stream,
        level: :success,
        message: "Option##{option.id} updated"
      )
    else
      render_product_streams(
        options_panel_stream,
        level: :warning,
        message: option.errors.full_messages.to_sentence.presence || "Option invalid"
      )
    end
  end

  def destroy
    option = @product.options.find(params[:id])
    option.destroy
    render_product_streams(
      options_panel_stream,
      level: :success,
      message: "Option##{option.id} removed"
    )
  end

  def reorder
    Array(params[:options]).each_with_index do |option_id, index|
      @product.options.where(id: option_id).update_all(order: index + 1)
    end

    render_product_streams(
      options_panel_stream,
      level: :success,
      message: "Product##{@product.id} option order saved"
    )
  end

  private

  def option_params
    params.require(:option).permit(:content)
  end

  def next_order
    @product.options.maximum(:order).to_i + 1
  end
end
