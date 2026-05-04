# frozen_string_literal: true

module AdminV2
  class SessionStorageStats
    DEFAULT_KEEP_COUNT = 4

    Summary = Struct.new(
      :sessions_total,
      :events_total,
      :keep_count,
      :kept_sessions_count,
      :prunable_sessions_count,
      :prunable_events_count,
      keyword_init: true
    )

    def initialize(user:, current_session: nil, keep_count: DEFAULT_KEEP_COUNT)
      @user = user
      @current_session = current_session
      @keep_count = keep_count
    end

    attr_reader :user, :current_session, :keep_count

    def summary
      Summary.new(
        sessions_total: sessions_scope.count,
        events_total: events_scope.count,
        keep_count: keep_count,
        kept_sessions_count: kept_session_ids.size,
        prunable_sessions_count: prunable_session_ids.size,
        prunable_events_count: prunable_events_count
      )
    end

    def kept_session_ids
      @kept_session_ids ||= begin
        ids = sessions_scope.recent.limit(keep_count).pluck(:id)
        ids << current_session.id if current_session&.id.present? && !ids.include?(current_session.id)
        ids
      end
    end

    def prunable_session_ids
      @prunable_session_ids ||= sessions_scope.where.not(id: kept_session_ids).pluck(:id)
    end

    private

    def sessions_scope
      ::AdminV2Session.where(user: user)
    end

    def events_scope
      ::AdminV2SessionEvent.where(user: user)
    end

    def prunable_events_count
      return 0 if prunable_session_ids.empty?

      ::AdminV2SessionEvent.where(admin_v2_session_id: prunable_session_ids).count
    end
  end
end
