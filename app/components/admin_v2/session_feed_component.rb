# frozen_string_literal: true

class AdminV2::SessionFeedComponent < ViewComponent::Base
  def initialize(admin_v2_session: nil)
    @admin_v2_session = admin_v2_session
  end

  private

  attr_reader :admin_v2_session

  def events
    return AdminV2SessionEvent.none unless admin_v2_session

    admin_v2_session.session_events.recent.limit(80)
  end
end
