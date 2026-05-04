# frozen_string_literal: true

module AdminV2
  class SessionTracker
    TOUCH_INTERVAL = 30.seconds

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
      admin_session = find_active_session || create_session
      @session[:admin_v2_session_id] = admin_session.id
      admin_session
    end

    def find_active_session
      session_id = @session[:admin_v2_session_id]
      return if session_id.blank?

      ::AdminV2Session.active.find_by(id: session_id, user: @user)
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
      admin_session.reload
    end

    def touch_due?
      last_seen_at = @session[:admin_v2_session_last_seen_at].to_i
      last_seen_at.zero? || Time.at(last_seen_at) <= TOUCH_INTERVAL.ago
    end

    def context_attributes(area:, resource:)
      {
        current_area: area,
        current_resource_type: resource_type_for(resource),
        current_resource_id: resource_id_for(resource)
      }.compact
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
