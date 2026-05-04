class AdminV2::BaseController < ActionController::Base
  before_action :authenticate_user!
  before_action :track_admin_v2_session
  before_action :consume_boot_panel

  helper_method :current_admin_v2_session, :admin_v2_pagination_params

  layout "admin_v2"

  private

  def consume_boot_panel
    @show_boot_panel = session.delete(:admin_v2_boot_panel)
  end

  def turbo_stream_flash(level, message)
    track_admin_v2_event(level: level, event_type: :server, message: message)

    server_event_stream(level, message, event_type: :server)
  end

  def admin_v2_feedback_streams(level, message, event_type: :server, resource: nil, metadata: {}, status_code: nil)
    track_admin_v2_event(
      level: level,
      event_type: event_type,
      message: message,
      resource: resource,
      metadata: metadata,
      status_code: status_code
    )

    [
      server_event_stream(
        level,
        message,
        event_type: event_type,
        resource: resource,
        status_code: status_code,
        metadata: metadata
      ),
      admin_v2_session_report_stream
    ].compact
  end

  def server_event_stream(level, message, event_type: :server, resource: nil, status_code: nil, metadata: {})
    turbo_stream.append(
      "admin_v2_server_events",
      partial: "admin_v2/shared/server_event",
      locals: {
        level: level,
        message: message,
        timestamp: Time.current,
        source: metadata[:source] || metadata["source"] || "server",
        event_type: event_type,
        request_method: request.request_method,
        request_path: request.path,
        status_code: status_code,
        resource_label: admin_v2_resource_label(resource)
      }
    )
  end

  def store_nav_stream(active)
    turbo_stream.replace(
      "admin_v2_store_nav",
      partial: "admin_v2/shared/store_nav",
      locals: { active: active }
    )
  end

  def track_admin_v2_session
    @admin_v2_session = admin_v2_session_tracker.touch!(area: admin_v2_active_key)
  end

  def track_admin_v2_context(resource)
    @admin_v2_session = admin_v2_session_tracker.touch!(area: admin_v2_active_key, resource: resource)
  end

  def current_admin_v2_session
    @admin_v2_session ||= admin_v2_session_tracker.current_session
  end

  def track_admin_v2_event(level:, event_type:, message:, resource: nil, metadata: {}, status_code: nil)
    track_admin_v2_context(resource) if resource

    event = admin_v2_session_tracker.track!(
      level: level,
      event_type: event_type,
      message: message,
      resource: resource,
      metadata: metadata,
      status_code: status_code
    )
    @admin_v2_session = admin_v2_session_tracker.current_session if event
    event
  end

  def admin_v2_session_report_stream
    return unless current_admin_v2_session

    turbo_stream.replace(
      "admin_v2_session_report",
      partial: "admin_v2/sessions/report",
      locals: {
        current_user: current_user,
        admin_v2_session: current_admin_v2_session,
        active: admin_v2_active_key
      }
    )
  end

  def admin_v2_session_tracker
    @admin_v2_session_tracker ||= AdminV2::SessionTracker.new(self)
  end

  def paginate_admin_v2(scope, per_page: AdminV2::Pagination::DEFAULT_PER_PAGE, total_count: nil)
    pagination = AdminV2::Pagination.new(scope: scope, page: params[:page], per_page: per_page, total_count: total_count)

    [pagination.records, pagination]
  end

  def admin_v2_pagination_params(*keys)
    request.query_parameters.slice(*keys.map(&:to_s)).compact_blank
  end

  def admin_v2_active_key
    case controller_path.delete_prefix("admin_v2/")
    when /\Aproduct/
      :products
    when /\Aevent/
      :events
    when /\Acategor/
      :categories
    when /\Aquote/
      :quotes
    else
      controller_name
    end
  end

  def admin_v2_resource_label(resource)
    return if resource.blank?

    [resource.class.name.demodulize, resource.try(:id)].compact.join("#")
  end
end
