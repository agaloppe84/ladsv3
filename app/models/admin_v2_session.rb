# frozen_string_literal: true

class AdminV2Session < ApplicationRecord
  MUTATION_TYPES = %w[
    autosave
    create
    delete
    processed
    reorder
    update
  ].freeze

  belongs_to :user
  has_many :session_events,
           class_name: "AdminV2SessionEvent",
           dependent: :destroy,
           inverse_of: :admin_v2_session

  scope :active, -> { where(status: "active") }
  scope :recent, -> { order(last_seen_at: :desc) }

  def register_event_counters!(event)
    self.class
      .where(id: id)
      .update_all(
        [
          counter_sql,
          1,
          mutation_increment_for(event),
          error_increment_for(event),
          upload_increment_for(event),
          autosave_increment_for(event),
          Time.current
        ]
      )
  end

  private

  def counter_sql
    <<~SQL.squish
      events_count = events_count + ?,
      mutations_count = mutations_count + ?,
      errors_count = errors_count + ?,
      uploads_count = uploads_count + ?,
      autosaves_count = autosaves_count + ?,
      updated_at = ?
    SQL
  end

  def mutation_increment_for(event)
    MUTATION_TYPES.include?(event.event_type) ? 1 : 0
  end

  def error_increment_for(event)
    event.level.in?(%w[error warning]) || event.event_type == "error" ? 1 : 0
  end

  def upload_increment_for(event)
    event.event_type == "upload" ? 1 : 0
  end

  def autosave_increment_for(event)
    event.event_type == "autosave" ? 1 : 0
  end
end
