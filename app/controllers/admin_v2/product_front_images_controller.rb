class AdminV2::ProductFrontImagesController < AdminV2::ProductScopedController
  def create
    attach_product_single_upload(
      field: :product_front_image,
      attachment: @product.front_image,
      success_message: "Product##{@product.id} front image attached"
    ) do
      [front_image_panel_stream, drawer_summary_stream]
    end
  end

  def destroy
    @product.front_image.purge if @product.front_image.attached?

    render_product_streams(
      front_image_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Product##{@product.id} front image removed",
      event_type: :delete
    )
  end
end
