# frozen_string_literal: true

class AdminV2SessionEvent < ApplicationRecord
  belongs_to :admin_v2_session, inverse_of: :session_events
  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }
end
