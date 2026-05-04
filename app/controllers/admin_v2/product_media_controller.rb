class AdminV2::ProductMediaController < AdminV2::ProductScopedController
  def drawer; end

  def create
    @product.images.attach(params[:image])
    render_product_streams(
      media_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Product##{@product.id} image attached",
      event_type: :upload
    )
  end

  def destroy
    attachment = @product.images.attachments.find(params[:id])
    attachment.purge
    render_product_streams(
      media_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Product##{@product.id} image removed",
      event_type: :delete
    )
  end

  def reorder
    Array(params[:attachments]).each_with_index do |attachment_id, index|
      @product.images.attachments.where(id: attachment_id).update_all(position: index + 1)
    end

    render_product_streams(
      media_panel_stream,
      level: :success,
      message: "Product##{@product.id} image order saved",
      event_type: :reorder
    )
  end
end
