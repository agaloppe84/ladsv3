class AdminV2::ProductDocumentationsController < AdminV2::ProductScopedController
  def drawer; end

  def create
    attach_product_upload(
      field: :documentation,
      attachments: @product.documentations,
      success_message: "Product##{@product.id} documentation attached"
    ) do
      [documentations_panel_stream, drawer_summary_stream]
    end
  end

  def destroy
    attachment = @product.documentations.attachments.find(params[:id])
    attachment.purge
    render_product_streams(
      documentations_panel_stream,
      drawer_summary_stream,
      level: :success,
      message: "Product##{@product.id} documentation removed",
      event_type: :delete
    )
  end
end
