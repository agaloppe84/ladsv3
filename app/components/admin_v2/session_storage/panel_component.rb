# frozen_string_literal: true

class AdminV2::SessionStorage::PanelComponent < ViewComponent::Base
  def initialize(current_user:, admin_v2_session: nil)
    @current_user = current_user
    @admin_v2_session = admin_v2_session
  end

  private

  attr_reader :current_user, :admin_v2_session

  def stats
    @stats ||= AdminV2::SessionStorageStats
               .new(user: current_user, current_session: admin_v2_session)
               .summary
  end

  def prunable?
    stats.prunable_sessions_count.positive?
  end

  def purge_classes
    base = "admin-v2-focus mt-2 flex h-8 w-full items-center justify-center rounded-lg border px-3 text-[11px] font-semibold transition"
    return "#{base} cursor-not-allowed border-white/[0.06] bg-white/[0.025] text-[var(--g-faint)]" unless prunable?

    "#{base} border-red-300/20 bg-red-300/10 text-[var(--g-red)] hover:bg-red-300/15"
  end
end
