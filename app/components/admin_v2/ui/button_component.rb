# frozen_string_literal: true

class AdminV2::Ui::ButtonComponent < ViewComponent::Base
  def initialize(label: nil, variant: :secondary, type: nil, path: nil, data: {}, method: nil)
    @label = label
    @variant = variant
    @type = type
    @path = path
    @data = data
    @method = method
  end

  private

  attr_reader :label, :type, :path, :data, :method

  def classes
    colors = {
      primary: "border-[var(--g-accent-border)] bg-[var(--g-accent)] text-white hover:bg-[#6e50f0]",
      secondary: "border-white/[0.09] bg-white/[0.055] text-[var(--g-text)] hover:bg-white/[0.09]",
      ghost: "border-transparent bg-transparent text-[var(--g-muted)] hover:bg-white/[0.055] hover:text-[var(--g-text)]",
      danger: "border-red-300/20 bg-red-300/10 text-[var(--g-red)] hover:bg-red-300/15"
    }

    "admin-v2-focus inline-flex h-8 items-center justify-center rounded-lg border px-3 text-[11px] font-semibold transition #{colors.fetch(@variant, colors[:secondary])}"
  end
end
