# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class PresetRegistry
          LayoutPreset = Struct.new(
            :id,
            :family,
            :slots,
            :required_slots,
            :attached_slots,
            :snap_rules,
            keyword_init: true
          )

          CalloutPreset = Struct.new(
            :id,
            :default_placement_by_slot,
            :rules,
            keyword_init: true
          )

          LAYOUT_PRESETS = [
            LayoutPreset.new(
              id: "vertical-zipped-screen",
              family: "top-housing-with-fabric",
              slots: %w[top-supports top-housing motor fabric side-guides bottom-bar attached-features],
              required_slots: %w[top-housing fabric side-guides bottom-bar],
              attached_slots: %w[attached-features],
              snap_rules: %w[center-main-horizontal-elements snap-wide-elements-to-major-grid group-attached-features]
            ),
            LayoutPreset.new(
              id: "side-guided-fabric",
              family: "top-housing-with-fabric",
              slots: %w[top-housing fabric side-guides bottom-bar closure attached-features],
              required_slots: %w[top-housing fabric side-guides bottom-bar],
              attached_slots: %w[closure attached-features],
              snap_rules: %w[center-main-horizontal-elements snap-wide-elements-to-major-grid group-attached-features]
            ),
            LayoutPreset.new(
              id: "pleated-lateral",
              family: "side-guided-fabric",
              slots: %w[top-guide fabric side-profiles handle bottom-threshold closure],
              required_slots: %w[top-guide fabric side-profiles handle bottom-threshold],
              attached_slots: %w[handle closure],
              snap_rules: %w[center-fabric-between-profiles snap-wide-elements-to-major-grid group-attached-features]
            ),
            LayoutPreset.new(
              id: "top-down-bottom-up-fabric",
              family: "top-housing-with-fabric",
              slots: %w[top-supports top-rail fabric intermediate-rail bottom-rail guide-cords],
              required_slots: %w[top-rail fabric intermediate-rail bottom-rail],
              attached_slots: %w[guide-cords],
              snap_rules: %w[center-main-horizontal-elements snap-wide-elements-to-major-grid group-attached-features]
            ),
            LayoutPreset.new(
              id: "slatted-pack",
              family: "slatted-pack",
              slots: %w[top-supports headrail slats ladder-cords bottom-bar controls],
              required_slots: %w[headrail slats ladder-cords bottom-bar controls],
              attached_slots: %w[ladder-cords],
              snap_rules: %w[center-slat-pack snap-wide-elements-to-major-grid align-controls-to-pack-height]
            ),
            LayoutPreset.new(
              id: "roller-duo",
              family: "roller-fabric",
              slots: %w[top-supports headrail roll fabric bottom-bar controls],
              required_slots: %w[headrail roll fabric bottom-bar controls],
              attached_slots: %w[roll],
              snap_rules: %w[center-main-horizontal-elements snap-wide-elements-to-major-grid align-controls-to-fabric-height]
            )
          ].freeze

          CALLOUT_PRESETS = [
            CalloutPreset.new(
              id: "technical-exploded-default",
              default_placement_by_slot: {
                "top-housing" => "top_housing",
                "top-rail" => "top_rail",
                "headrail" => "top_rail",
                "fabric" => "center_fabric",
                "side-guides" => "left_vertical_pair",
                "side-profiles" => "left_vertical_pair",
                "bottom-bar" => "bottom_bar",
                "bottom-rail" => "bottom_rail",
                "controls" => "right_detail_up",
                "attached-features" => "right_detail_up"
              },
              rules: %w[
                prefer-straight-line-when-marker-and-label-share-axis
                keep-attached-features-callouts-on-their-parent-group
                resolve-auto-label-side-from-canvas-quadrant
                allow-json-overrides-for-product-specific-collisions
              ]
            )
          ].freeze

          def self.default
            @default ||= new
          end

          def layout?(id)
            layout_presets.key?(id.to_s)
          end

          def callouts?(id)
            callout_presets.key?(id.to_s)
          end

          def layout(id)
            layout_presets.fetch(id.to_s)
          end

          def callouts(id)
            callout_presets.fetch(id.to_s)
          end

          def layout_ids
            layout_presets.keys.sort
          end

          def callout_ids
            callout_presets.keys.sort
          end

          private

          def layout_presets
            @layout_presets ||= LAYOUT_PRESETS.to_h { |preset| [preset.id, preset] }
          end

          def callout_presets
            @callout_presets ||= CALLOUT_PRESETS.to_h { |preset| [preset.id, preset] }
          end
        end
      end
    end
  end
end
