class AdminV2::EventScopedController < AdminV2::BaseController
  before_action :set_event

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def render_event_streams(*streams, level: :success, message:, event_type: :update, status: :ok)
    render turbo_stream: [
      *streams,
      *admin_v2_feedback_streams(
        level,
        message,
        event_type: event_type,
        resource: @event,
        status_code: Rack::Utils.status_code(status)
      )
    ], status: status
  end

  def details_panel_stream
    turbo_stream.replace(
      "admin_v2_event_details",
      partial: "admin_v2/events/panels/details",
      locals: { event: @event }
    )
  end

  def schedule_panel_stream
    turbo_stream.replace(
      "admin_v2_event_schedule",
      partial: "admin_v2/events/panels/schedule",
      locals: { event: @event }
    )
  end

  def preview_panel_stream
    turbo_stream.replace(
      "admin_v2_event_preview",
      partial: "admin_v2/events/panels/preview",
      locals: { event: @event }
    )
  end

  def drawer_summary_stream
    turbo_stream.replace(
      "admin_v2_event_drawer_summary",
      partial: "admin_v2/events/drawer_summary",
      locals: { event: @event }
    )
  end

  def drawer_header_stream
    turbo_stream.replace(
      "admin_v2_event_drawer_header",
      partial: "admin_v2/events/drawer_header",
      locals: { event: @event, eyebrow: "Event edit" }
    )
  end

  def event_row_stream
    turbo_stream.replace(
      "admin_v2_event_#{@event.id}",
      partial: "admin_v2/events/row",
      locals: { event: @event }
    )
  end

  def schedule_status_stream
    turbo_stream.replace(
      "admin_v2_event_schedule_status",
      partial: "admin_v2/events/schedule_status",
      locals: { event: @event }
    )
  end

end
