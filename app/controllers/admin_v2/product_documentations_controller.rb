class AdminV2::ProductDocumentationsController < AdminV2::ProductScopedController
  def drawer; end

  def create
    @product.documentations.attach(params[:documentation])
    render_product_streams(
      documentations_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Product##{@product.id} documentation attached"
    )
  end

  def destroy
    attachment = @product.documentations.attachments.find(params[:id])
    attachment.purge
    render_product_streams(
      documentations_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Product##{@product.id} documentation removed"
    )
  end
end
