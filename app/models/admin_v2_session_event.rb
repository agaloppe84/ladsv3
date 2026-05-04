# frozen_string_literal: true

class AdminV2SessionEvent < ApplicationRecord
  LEVEL_COLORS = {
    "success" => "var(--g-green)",
    "warning" => "var(--g-amber)",
    "error" => "var(--g-red)",
    "server" => "var(--g-cyan)",
    "info" => "var(--g-accent)",
    "system" => "var(--g-faint)"
  }.freeze

  belongs_to :admin_v2_session, inverse_of: :session_events
  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

  def debug_color
    LEVEL_COLORS.fetch(level, "var(--g-muted)")
  end

  def debug_source
    metadata_value("source").presence || request_source
  end

  def debug_type
    metadata_value("type").presence || event_type
  end

  def debug_meta
    [request_method, status_code].compact.join(" ").presence
  end

  def resource_label
    return if resource_type.blank?

    [resource_type.demodulize, resource_id].compact.join("#")
  end

  private

  def metadata_value(key)
    return unless metadata.is_a?(Hash)

    metadata[key.to_s]
  end

  def request_source
    return "system" if event_type == "session"
    return "server" if request_method.present? || request_path.present? || status_code.present?

    "session"
  end
end
