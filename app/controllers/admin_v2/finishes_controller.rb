class AdminV2::FinishesController < AdminV2::ProductScopedController
  def create
    finish = Finish.create!(finish_params)
    render_product_streams(
      configurator_panel_stream,
      level: :success,
      message: "Finish##{finish.id} created",
      event_type: :create
    )
  rescue ActiveRecord::RecordInvalid => e
    render_product_streams(
      configurator_panel_stream,
      level: :warning,
      message: e.record.errors.full_messages.to_sentence,
      event_type: :error
    )
  end

  private

  def finish_params
    params.require(:finish).permit(:code, :label)
  end
end
