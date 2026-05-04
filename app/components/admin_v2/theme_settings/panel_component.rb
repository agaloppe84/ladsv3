# frozen_string_literal: true

class AdminV2::ThemeSettings::PanelComponent < ViewComponent::Base
  private

  def default_accent_label
    "Lime"
  end

  def default_font_label
    "Mono"
  end

  def accent_options
    [
      ["Violet", "124, 92, 255", "#d9d2ff", "#7c5cff"],
      ["Indigo", "99, 102, 241", "#d7d8ff", "#6366f1"],
      ["Cyan", "103, 216, 239", "#cff6ff", "#67d8ef"],
      ["Teal", "45, 212, 191", "#c7fff5", "#2dd4bf"],
      ["Green", "117, 214, 123", "#d8ffdc", "#75d67b"],
      ["Lime", "190, 242, 100", "#efffd1", "#bef264"],
      ["Amber", "245, 196, 81", "#fff0c4", "#f5c451"],
      ["Coral", "255, 104, 104", "#ffd0d0", "#ff6868"],
      ["Rose", "244, 114, 182", "#ffd4e9", "#f472b6"],
      ["Slate", "148, 163, 184", "#e5edf7", "#94a3b8"]
    ]
  end
end
