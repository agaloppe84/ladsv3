class AdminV2::EventScheduleController < AdminV2::EventScopedController
  def update
    if @event.update(event_params)
      render_event_streams(
        header_status_stream,
        drawer_summary_stream,
        preview_panel_stream,
        level: :success,
        message: "Event##{@event.id} schedule updated"
      )
    else
      render_event_streams(
        schedule_panel_stream,
        level: :warning,
        message: @event.errors.full_messages.to_sentence.presence || "Event schedule invalid",
        status: :unprocessable_entity
      )
    end
  end

  private

  def event_params
    params.require(:event).permit(:start_date, :end_date)
  end
end
