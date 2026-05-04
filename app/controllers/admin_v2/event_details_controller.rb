class AdminV2::EventDetailsController < AdminV2::EventScopedController
  def update
    permitted_params = event_params

    if @event.update(permitted_params)
      render_event_streams(
        event_row_stream,
        drawer_header_stream,
        preview_panel_stream,
        level: :success,
        message: detail_message(permitted_params)
      )
    else
      render_event_streams(
        details_panel_stream,
        level: :warning,
        message: @event.errors.full_messages.to_sentence.presence || "Event details invalid",
        status: :unprocessable_entity
      )
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :content)
  end

  def detail_message(permitted_params)
    field = permitted_params.keys.first.to_s.presence || "details"
    "Event##{@event.id} #{field} updated"
  end
end
