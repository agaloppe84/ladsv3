# frozen_string_literal: true

class AdminV2::Ui::BadgeComponent < ViewComponent::Base
  def initialize(label:, variant: :neutral)
    @label = label
    @variant = variant
  end

  private

  attr_reader :label, :variant

  def classes
    colors = {
      neutral: "border-white/[0.09] bg-white/[0.045] text-[var(--g-muted)]",
      accent: "border-[var(--g-accent-border)] bg-[var(--g-accent-soft)] text-[var(--g-accent-text)]",
      success: "border-emerald-300/20 bg-emerald-300/10 text-[var(--g-green)]",
      warning: "border-amber-300/20 bg-amber-300/10 text-[var(--g-amber)]",
      danger: "border-red-300/20 bg-red-300/10 text-[var(--g-red)]",
      server: "border-cyan-300/20 bg-cyan-300/10 text-[var(--g-cyan)]"
    }

    "inline-flex items-center rounded-md border px-2 py-1 text-[10px] font-semibold #{colors.fetch(variant, colors[:neutral])}"
  end
end
