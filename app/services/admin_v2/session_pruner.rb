# frozen_string_literal: true

module AdminV2
  class SessionPruner
    Result = Struct.new(
      :sessions_pruned,
      :events_pruned,
      :sessions_kept,
      keyword_init: true
    )

    def initialize(user:, current_session: nil, keep_count: SessionStorageStats::DEFAULT_KEEP_COUNT)
      @user = user
      @current_session = current_session
      @keep_count = keep_count
    end

    def prune!
      stats = SessionStorageStats.new(user: @user, current_session: @current_session, keep_count: @keep_count)
      prunable_ids = stats.prunable_session_ids
      events_pruned = prunable_ids.empty? ? 0 : ::AdminV2SessionEvent.where(admin_v2_session_id: prunable_ids).count
      sessions_pruned = prunable_ids.size

      ::AdminV2Session.transaction do
        ::AdminV2Session.where(id: prunable_ids).destroy_all if prunable_ids.any?
      end

      Result.new(
        sessions_pruned: sessions_pruned,
        events_pruned: events_pruned,
        sessions_kept: stats.kept_session_ids.size
      )
    end
  end
end
