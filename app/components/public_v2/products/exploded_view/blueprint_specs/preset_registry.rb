# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class PresetRegistry
          LayoutPreset = Struct.new(
            :id,
            :family,
            :axis,
            :anchor_slot,
            :slots,
            :required_slots,
            :required_slot_groups,
            :optional_slots,
            :attached_slots,
            :stack_rules,
            :spacing_rules,
            :snap_rules,
            keyword_init: true
          )

          CalloutPreset = Struct.new(
            :id,
            :default_placement_by_slot,
            :default_options_by_slot,
            :rules,
            keyword_init: true
          )

          LAYOUT_PRESETS = [
            LayoutPreset.new(
              id: "vertical-product-layout",
              family: "product-layout",
              axis: "vertical",
              anchor_slot: "fabric",
              slots: %w[
                top-supports
                top-housing
                top-rail
                headrail
                motor
                roll
                fabric
                side-guides
                bottom-bar
                bottom-rail
                intermediate-rail
                guide-cords
                ladder-cords
                controls
                closure
                attached-features
              ],
              required_slots: %w[fabric],
              required_slot_groups: [
                %w[top-housing top-rail headrail],
                %w[bottom-bar bottom-rail]
              ],
              optional_slots: %w[
                top-supports
                motor
                roll
                side-guides
                intermediate-rail
                guide-cords
                ladder-cords
                controls
                closure
                attached-features
              ],
              attached_slots: %w[attached-features closure guide-cords ladder-cords],
              stack_rules: {
                "top-stack" => %w[top-supports top-housing top-rail headrail],
                "center-stack" => %w[side-guides fabric],
                "bottom-stack" => %w[bottom-bar bottom-rail],
                "right-stack" => %w[controls motor closure attached-features]
              },
              spacing_rules: %w[
                leave-callout-room-between-stacks
                treat-attached-slots-as-parent-bounds
                keep-controls-right-of-center-stack
              ],
              snap_rules: %w[
                center-anchor-slot-on-canvas
                snap-wide-elements-to-major-grid
                mirror-side-guides-from-one-source
              ]
            ),
            LayoutPreset.new(
              id: "horizontal-product-layout",
              family: "product-layout",
              axis: "horizontal",
              anchor_slot: "fabric",
              slots: %w[
                top-supports
                top-rail
                top-guide
                headrail
                fabric
                side-guides
                side-profiles
                handle
                bottom-threshold
                bottom-rail
                controls
                closure
                attached-features
              ],
              required_slots: %w[fabric],
              required_slot_groups: [
                %w[top-guide top-rail headrail]
              ],
              optional_slots: %w[
                top-supports
                side-guides
                side-profiles
                handle
                bottom-threshold
                bottom-rail
                controls
                closure
                attached-features
              ],
              attached_slots: %w[handle closure attached-features],
              stack_rules: {
                "top-stack" => %w[top-supports top-guide top-rail headrail],
                "center-stack" => %w[side-profiles side-guides fabric handle],
                "bottom-stack" => %w[bottom-threshold bottom-rail],
                "right-stack" => %w[controls closure attached-features]
              },
              spacing_rules: %w[
                leave-callout-room-between-stacks
                treat-handle-and-fabric-as-one-center-group
                treat-attached-slots-as-parent-bounds
              ],
              snap_rules: %w[
                center-anchor-slot-on-canvas
                snap-wide-elements-to-major-grid
                mirror-side-guides-from-one-source
              ]
            ),
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
              id: "vertical-product-callouts",
              default_options_by_slot: {
                "top-housing" => { "route" => "right", "first_length" => 430 },
                "top-rail" => { "route" => "right", "first_length" => 430 },
                "headrail" => { "route" => "right", "first_length" => 430 },
                "fabric" => { "route" => "right", "first_length" => 430 },
                "bottom-bar" => { "route" => "right", "first_length" => 430 },
                "bottom-rail" => { "route" => "right", "first_length" => 430 },
                "side-guides" => { "placement" => "left_vertical_pair" },
                "top-supports" => { "placement" => "top_rail" },
                "motor" => { "placement" => "top_housing" },
                "roll" => { "placement" => "top_rail" },
                "intermediate-rail" => { "placement" => "right_outside_up" },
                "guide-cords" => { "placement" => "left_outside" },
                "ladder-cords" => { "placement" => "left_outside" },
                "controls" => { "placement" => "right_outside_up" },
                "closure" => { "placement" => "right_outside_up" },
                "attached-features" => { "placement" => "right_outside_up" }
              },
              rules: %w[
                prefer-straight-right-callouts-for-main-horizontal-stack
                keep-side-guide-callouts-outside-center-stack
                keep-controls-right-of-center-stack
                allow-json-overrides-for-product-specific-collisions
              ]
            ),
            CalloutPreset.new(
              id: "horizontal-product-callouts",
              default_options_by_slot: {
                "top-guide" => { "route" => "right", "first_length" => 430 },
                "top-rail" => { "route" => "right", "first_length" => 430 },
                "headrail" => { "route" => "right", "first_length" => 430 },
                "fabric" => { "route" => "right", "first_length" => 430 },
                "side-profiles" => { "placement" => "left_vertical_pair" },
                "side-guides" => { "placement" => "left_vertical_pair" },
                "handle" => { "placement" => "right_attached_panel" },
                "bottom-threshold" => { "placement" => "bottom_rail" },
                "bottom-rail" => { "placement" => "bottom_rail" },
                "top-supports" => { "placement" => "top_rail" },
                "controls" => { "placement" => "right_outside_up" },
                "closure" => { "placement" => "right_outside_up" },
                "attached-features" => { "placement" => "right_outside_up" }
              },
              rules: %w[
                treat-handle-and-fabric-as-one-center-group
                keep-side-profile-callouts-outside-center-stack
                prefer-straight-right-callouts-for-main-horizontal-stack
                allow-json-overrides-for-product-specific-collisions
              ]
            ),
            CalloutPreset.new(
              id: "technical-exploded-default",
              default_placement_by_slot: {
                "top-housing" => "top_housing",
                "top-supports" => "top_rail",
                "top-rail" => "top_rail",
                "top-guide" => "top_rail",
                "headrail" => "top_rail",
                "roll" => "top_rail",
                "motor" => "top_housing",
                "fabric" => "center_fabric",
                "slats" => "side_fabric",
                "side-guides" => "left_vertical_pair",
                "side-profiles" => "left_vertical_pair",
                "bottom-bar" => "bottom_bar",
                "bottom-rail" => "bottom_rail",
                "bottom-threshold" => "bottom_rail",
                "intermediate-rail" => "right_outside_up",
                "handle" => "right_attached_panel",
                "closure" => "right_outside_up",
                "guide-cords" => "left_outside",
                "ladder-cords" => "left_outside",
                "controls" => "right_outside_up",
                "attached-features" => "right_outside_up"
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

          def slot?(layout_preset_id, slot)
            return false if layout_preset_id.to_s.empty? || slot.to_s.empty?
            return false unless layout?(layout_preset_id)

            layout(layout_preset_id).slots.include?(slot.to_s)
          end

          def default_callout_placement(callout_preset_id, slot)
            default_callout_options(callout_preset_id, slot)["placement"]
          end

          def default_callout_options(callout_preset_id, slot)
            return {} if callout_preset_id.to_s.empty? || slot.to_s.empty?
            return {} unless callouts?(callout_preset_id)

            preset = callouts(callout_preset_id)
            options = preset.default_options_by_slot&.fetch(slot.to_s, nil)
            return options.dup if options

            placement = preset.default_placement_by_slot&.fetch(slot.to_s, nil)
            placement ? { "placement" => placement } : {}
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
