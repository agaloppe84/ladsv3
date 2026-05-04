class AdminV2::EventScheduleController < AdminV2::EventScopedController
  def update
    if @event.update(event_params)
      render_event_streams(
        event_row_stream,
        drawer_header_stream,
        preview_panel_stream,
        schedule_status_stream,
        level: :success,
        message: "Event##{@event.id} schedule updated",
        event_type: :autosave
      )
    else
      render_event_streams(
        schedule_panel_stream,
        level: :warning,
        message: @event.errors.full_messages.to_sentence.presence || "Event schedule invalid",
        event_type: :error,
        status: :unprocessable_entity
      )
    end
  end

  private

  def event_params
    params.require(:event).permit(:start_date, :end_date)
  end
end
