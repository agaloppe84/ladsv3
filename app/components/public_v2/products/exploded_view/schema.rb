# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      Part = Struct.new(:id, :number, :label, :measurement, :detail, keyword_init: true)
      Metric = Struct.new(:label, :value, :note, keyword_init: true)

      Theme = Struct.new(:accent, :accent_rgb, :accent_ink, keyword_init: true) do
        def css_style
          [
            ["--pv2-exploded-accent", accent],
            ["--pv2-exploded-accent-rgb", accent_rgb],
            ["--pv2-exploded-accent-ink", accent_ink]
          ].filter_map do |name, value|
            "#{name}: #{value}" unless value.nil? || value.to_s.empty?
          end.join("; ")
        end
      end
    end
  end
end
