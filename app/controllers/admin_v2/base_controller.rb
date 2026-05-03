class AdminV2::BaseController < ActionController::Base
  before_action :authenticate_user!
  before_action :consume_boot_panel

  layout "admin_v2"

  private

  def consume_boot_panel
    @show_boot_panel = session.delete(:admin_v2_boot_panel)
  end

  def turbo_stream_flash(level, message)
    turbo_stream.append(
      "admin_v2_server_events",
      partial: "admin_v2/shared/server_event",
      locals: { level: level, message: message, timestamp: Time.current }
    )
  end
end
