class AdminV2::SessionStorageController < AdminV2::BaseController
  def prune
    result = AdminV2::SessionPruner.new(
      user: current_user,
      current_session: current_admin_v2_session
    ).prune!

    feedback_streams = admin_v2_feedback_streams(
      :success,
      "Session storage pruned #{result.sessions_pruned} sessions / #{result.events_pruned} events",
      event_type: :delete,
      metadata: { source: "maintenance", type: "prune" },
      status_code: 200
    )

    render turbo_stream: [
      session_storage_panel_stream,
      *feedback_streams
    ]
  end

  private

  def session_storage_panel_stream
    turbo_stream.replace(
      "admin_v2_session_storage_panel",
      partial: "admin_v2/session_storage/panel",
      locals: {
        current_user: current_user,
        admin_v2_session: current_admin_v2_session
      }
    )
  end
end
