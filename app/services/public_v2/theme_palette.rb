# frozen_string_literal: true

module PublicV2
  class ThemePalette
    GROUPS = [
      { key: :soft, label: "Douces" },
      { key: :flashy, label: "Flashy" }
    ].freeze

    ACCENTS = [
      { key: :sage, group: :soft, label: "Sauge", hex: "#8fb98b", rgb: "143, 185, 139", text: "#102012" },
      { key: :lichen, group: :soft, label: "Lichen", hex: "#a3c76d", rgb: "163, 199, 109", text: "#17210a" },
      { key: :soft_sky, group: :soft, label: "Ciel doux", hex: "#7cc7d9", rgb: "124, 199, 217", text: "#06252b" },
      { key: :clay, group: :soft, label: "Argile", hex: "#c9876b", rgb: "201, 135, 107", text: "#2e130b" },
      { key: :powder_rose, group: :soft, label: "Rose poudre", hex: "#d88aa3", rgb: "216, 138, 163", text: "#2b0d17" },
      { key: :lavender, group: :soft, label: "Lavande", hex: "#a99be0", rgb: "169, 155, 224", text: "#18112d" },
      { key: :lime, group: :flashy, label: "Lime", hex: "#84cc16", rgb: "132, 204, 22", text: "#0f1b05" },
      { key: :cyan, group: :flashy, label: "Cyan", hex: "#06b6d4", rgb: "6, 182, 212", text: "#041e24" },
      { key: :amber, group: :flashy, label: "Ambre", hex: "#f59e0b", rgb: "245, 158, 11", text: "#241400" },
      { key: :signal, group: :flashy, label: "Signal", hex: "#e11d48", rgb: "225, 29, 72", text: "#21030a" },
      { key: :violet, group: :flashy, label: "Violet", hex: "#8b5cf6", rgb: "139, 92, 246", text: "#120824" },
      { key: :electric_green, group: :flashy, label: "Vert electrique", hex: "#22c55e", rgb: "34, 197, 94", text: "#031807" }
    ].freeze

    class << self
      def accents
        ACCENTS
      end

      def groups
        GROUPS.map do |group|
          group.merge(accents: accents_for(group[:key]))
        end
      end

      def default_accent
        accent_by_key(:lime)
      end

      def accent_by_key(key)
        normalized_key = key.to_s.to_sym
        accents.find { |accent| accent[:key] == normalized_key } || accents.first
      end

      def accent_by_hex(hex)
        normalized_hex = hex.to_s.downcase
        accents.find { |accent| accent[:hex] == normalized_hex }
      end

      private

      def accents_for(group_key)
        accents.select { |accent| accent[:group] == group_key }
      end
    end
  end
end
