# frozen_string_literal: true

module AdminV2
  class SessionTracker
    TOUCH_INTERVAL = 30.seconds
    SESSION_TIMEOUT = 8.hours
    EVENT_RETENTION_LIMIT = 1_000
    EVENT_PRUNE_BATCH_SIZE = 200

    def initialize(controller)
      @controller = controller
      @request = controller.request
      @session = controller.session
      @user = controller.current_user
    end

    def current_session
      return unless enabled?

      @current_session ||= find_or_create_session
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    def touch!(area: nil, resource: nil)
      admin_session = current_session
      return unless admin_session

      attrs = context_attributes(area: area, resource: resource)
      attrs = attrs.select { |key, value| admin_session.public_send(key) != value }

      if touch_due?
        attrs[:last_seen_at] = Time.current
        @session[:admin_v2_session_last_seen_at] = Time.current.to_i
      end

      if attrs.any?
        admin_session.update_columns(attrs.merge(updated_at: Time.current))
        admin_session.assign_attributes(attrs)
      end

      admin_session
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    def track!(level:, event_type:, message:, resource: nil, metadata: {}, status_code: nil)
      admin_session = current_session
      return unless admin_session

      event = admin_session.session_events.create!(
        user: @user,
        level: level.to_s,
        event_type: event_type.to_s,
        resource_type: resource_type_for(resource),
        resource_id: resource_id_for(resource),
        request_method: @request.request_method,
        request_path: @request.path,
        status_code: status_code,
        message: message.to_s,
        metadata: metadata.presence || {}
      )

      admin_session.register_event_counters!(event)
      admin_session.reload
      prune_events!(admin_session)
      event
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    private

    def enabled?
      @user.present? &&
        defined?(::AdminV2Session) &&
        ::AdminV2Session.table_exists? &&
        ::AdminV2SessionEvent.table_exists?
    end

    def find_or_create_session
      admin_session = find_active_session
      unless admin_session
        close_stale_sessions!
        admin_session = create_session
      end
      @session[:admin_v2_session_id] = admin_session.id
      admin_session
    end

    def find_active_session
      session_id = @session[:admin_v2_session_id]
      return if session_id.blank?

      admin_session = ::AdminV2Session.active.find_by(id: session_id, user: @user)
      return unless admin_session

      if admin_session.last_seen_at < SESSION_TIMEOUT.ago
        close_session!(admin_session, status: "stale")
        @session.delete(:admin_v2_session_id)
        @session.delete(:admin_v2_session_last_seen_at)
        return
      end

      admin_session
    end

    def create_session
      now = Time.current
      admin_session = ::AdminV2Session.create!(
        user: @user,
        started_at: now,
        last_seen_at: now,
        ip_address: @request.remote_ip,
        user_agent: @request.user_agent,
        status: "active"
      )

      event = admin_session.session_events.create!(
        user: @user,
        level: "system",
        event_type: "session",
        request_method: @request.request_method,
        request_path: @request.path,
        message: "Admin V2 session started"
      )
      admin_session.register_event_counters!(event)
      @session[:admin_v2_session_last_seen_at] = now.to_i
      admin_session.reload
    end

    def close_stale_sessions!
      ::AdminV2Session
        .active
        .where(user: @user)
        .where("last_seen_at < ?", SESSION_TIMEOUT.ago)
        .update_all(status: "stale", ended_at: Time.current, updated_at: Time.current)
    end

    def close_session!(admin_session, status:)
      admin_session.update_columns(status: status, ended_at: Time.current, updated_at: Time.current)
    end

    def prune_events!(admin_session)
      return if admin_session.events_count <= EVENT_RETENTION_LIMIT

      ids = admin_session
            .session_events
            .recent
            .offset(EVENT_RETENTION_LIMIT)
            .limit(EVENT_PRUNE_BATCH_SIZE)
            .pluck(:id)

      ::AdminV2SessionEvent.where(id: ids).delete_all if ids.any?
    end

    def touch_due?
      last_seen_at = @session[:admin_v2_session_last_seen_at].to_i
      last_seen_at.zero? || Time.at(last_seen_at) <= TOUCH_INTERVAL.ago
    end

    def context_attributes(area:, resource:)
      {
        current_area: area.to_s.presence,
        current_resource_type: resource_type_for(resource),
        current_resource_id: resource_id_for(resource)
      }
    end

    def resource_type_for(resource)
      return if resource.blank?

      resource.class.name
    end

    def resource_id_for(resource)
      return if resource.blank? || !resource.respond_to?(:id)

      resource.id
    end
  end
end
