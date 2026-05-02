# frozen_string_literal: true

class AdminV2::SidebarItemComponent < ViewComponent::Base
  def initialize(label:, path:, active: false, count: nil, disabled: false)
    @label = label
    @path = path
    @active = active
    @count = count
    @disabled = disabled
  end

  private

  attr_reader :label, :path, :count

  def active?
    @active
  end

  def disabled?
    @disabled
  end

  def classes
    base = "admin-v2-focus flex h-9 items-center justify-between rounded-lg border px-3 text-[12px] font-medium transition"
    return "#{base} cursor-not-allowed border-transparent text-[var(--g-faint)] opacity-60" if disabled?
    return "#{base} border-[var(--g-accent-border)] bg-[var(--g-accent-soft)] text-[var(--g-text)]" if active?

    "#{base} border-transparent text-[var(--g-muted)] hover:border-white/[0.075] hover:bg-white/[0.035] hover:text-[var(--g-text)]"
  end
end
