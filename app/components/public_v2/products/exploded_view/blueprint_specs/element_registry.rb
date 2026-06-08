# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class ElementRegistry
          Entry = Struct.new(:type, :variant, :renderer_family, :status, :option_keys, keyword_init: true) do
            def key
              ElementRegistry.key(type, variant)
            end

            def option_keys
              Array(self[:option_keys]).map(&:to_s).sort
            end
          end

          DEFAULT_ENTRIES = [
            Entry.new(
              type: "bar",
              variant: "bottom-charge",
              renderer_family: "solid_bar_profile",
              status: "supported",
              option_keys: %w[
                accent grip grip_height grip_rx grip_width hit_inset_x hit_inset_y magnet_inset_x marker_gap
                preset solid_profile
              ]
            ),
            Entry.new(
              type: "bar",
              variant: "roll-tube",
              renderer_family: "solid_bar_profile",
              status: "supported",
              option_keys: %w[
                body_tone highlight hit_inset_x hit_inset_y marker_gap marker_side solid_profile
              ]
            ),
            Entry.new(
              type: "bar",
              variant: "threshold",
              renderer_family: "solid_bar_profile",
              status: "supported",
              option_keys: %w[
                accent cord_tabs grip height hit_inset_x hit_inset_y marker_gap marker_side point_radius preset rx slot
                solid_profile width_extra x_offset_from_fabric y_offset_from_fabric_bottom
              ]
            ),
            Entry.new(
              type: "bar",
              variant: "vertical-handle",
              renderer_family: "solid_bar_profile",
              status: "supported",
              option_keys: %w[
                axis gap grip grip_height grip_rx grip_width height_inset hit_inset_x hit_inset_y marker_gap preset rx
                solid_profile width y_offset_from_profiles
              ]
            ),
            Entry.new(
              type: "bar",
              variant: "zipped-load",
              renderer_family: "solid_bar_profile",
              status: "supported",
              option_keys: %w[
                embouts grip preset solid_profile
              ]
            ),
            Entry.new(
              type: "closure",
              variant: "magnetic-receivers",
              renderer_family: "solid_accessory_profile",
              status: "supported",
              option_keys: %w[
                base_height base_offset_y hit_height hit_inset_x hit_y_offset marker_offset_y point_radius radius
                receiver_offset_y solid_profile
              ]
            ),
            Entry.new(
              type: "closure",
              variant: "plissee-lock",
              renderer_family: "solid_accessory_profile",
              status: "supported",
              option_keys: %w[
                catch_divisions catch_indexes hit_inset_left hit_inset_y hit_width marker_offset_x marker_offset_y radius
                solid_profile
              ]
            ),
            Entry.new(
              type: "closure",
              variant: "rail-bavettes",
              renderer_family: "solid_accessory_profile",
              status: "supported",
              option_keys: %w[
                feature_id hit_inset_x hit_inset_y marker_gap solid_profile
              ]
            ),
            Entry.new(
              type: "control",
              variant: "bead-chain",
              renderer_family: "solid_control_profile",
              status: "supported",
              option_keys: %w[
                bead_count bead_radius cord_bottom_offset_y cord_top_offset_y gap hit_inset_x hit_inset_y marker_gap
                marker_side rx segment_width solid_profile width
              ]
            ),
            Entry.new(
              type: "control",
              variant: "cord-pair",
              renderer_family: "solid_control_profile",
              status: "supported",
              option_keys: %w[
                bottom_gap dot_y_offsets hit_inset_x hit_inset_y marker_gap offset_x point_radius segment_width solid_profile
                top_gap
              ]
            ),
            Entry.new(
              type: "control",
              variant: "venetian-wand",
              renderer_family: "solid_control_profile",
              status: "supported",
              option_keys: %w[
                bead_count bead_radius cord_bottom_offset_y cord_offset_x cord_top_offset_y gap hit_inset_x hit_inset_y
                marker_gap preset rx segment_width solid_profile width
              ]
            ),
            Entry.new(
              type: "fabric",
              variant: "bordered-grid-solid",
              renderer_family: "fabric_pattern",
              status: "supported",
              option_keys: %w[
                edge_fastener_indexes edge_fastener_radius hit_inset_x hit_inset_y horizontal_count marker_gap pattern_id
                pattern_style preset vertical_count
              ]
            ),
            Entry.new(
              type: "fabric",
              variant: "duo-bands-solid",
              renderer_family: "fabric_pattern",
              status: "supported",
              option_keys: %w[
                band_count band_radius hit_inset_x hit_inset_y layer_offset marker_gap opaque_ratio pattern_id pattern_style
                preset
              ]
            ),
            Entry.new(
              type: "fabric",
              variant: "honeycomb-solid",
              renderer_family: "fabric_pattern",
              status: "supported",
              option_keys: %w[
                cell_count cell_depth hit_inset_x hit_inset_y marker_gap pattern_id pattern_style pattern_thread_width preset
                thread_offsets
              ]
            ),
            Entry.new(
              type: "fabric",
              variant: "pleated-solid",
              renderer_family: "fabric_pattern",
              status: "supported",
              option_keys: %w[
                hit_inset_x hit_inset_y marker_gap pattern_id pattern_style pattern_thread_width pleat_amplitude pleat_count
                preset thread_offsets
              ]
            ),
            Entry.new(
              type: "fabric",
              variant: "zipped-solid",
              renderer_family: "fabric_pattern",
              status: "supported",
              option_keys: %w[
                line_count pattern_id pattern_style preset tick_step
              ]
            ),
            Entry.new(
              type: "housing",
              variant: "front-coffre",
              renderer_family: "solid_housing_profile",
              status: "supported",
              option_keys: %w[
                points preset solid_profile style
              ]
            ),
            Entry.new(
              type: "housing",
              variant: "kiss-50-cassette",
              renderer_family: "solid_housing_profile",
              status: "supported",
              option_keys: %w[
                cheeks hit_inset_x hit_inset_y marker_gap points preset roll_height roll_inset_x roll_radius roll_y_offset
                screw_side_inset solid_profile style
              ]
            ),
            Entry.new(
              type: "motor",
              variant: "tubular",
              renderer_family: "solid_motor_profile",
              status: "supported",
              option_keys: %w[
                head_preset solid_profile tube_cap_width tube_preset tube_x
              ]
            ),
            Entry.new(
              type: "rail",
              variant: "duette-head",
              renderer_family: "solid_bar_profile",
              status: "supported",
              option_keys: %w[
                cord_tabs hit_inset_x hit_inset_y marker_gap preset slot solid_profile
              ]
            ),
            Entry.new(
              type: "rail",
              variant: "double-coulisse-pair",
              renderer_family: "solid_profile",
              status: "supported",
              option_keys: %w[
                attached_features cap_ratio extra_bottom extra_top hit_inset_x hit_inset_y inner_inset_x left_gap marker_gap
                point_radius preset right_gap rx slot_count solid_profile width
              ]
            ),
            Entry.new(
              type: "rail",
              variant: "horizontal-guide",
              renderer_family: "solid_profile",
              status: "supported",
              option_keys: %w[
                hit_inset_x hit_inset_y inner_inset_y marker_gap point_radius preset screw_side_inset solid_profile
              ]
            ),
            Entry.new(
              type: "rail",
              variant: "profile-pair",
              renderer_family: "solid_profile",
              status: "supported",
              option_keys: %w[
                height_extra hit_inset_x hit_inset_y inner_bottom_inset inner_inset_x inner_top_inset left_gap marker_gap
                point_radius preset right_gap rx slot_count solid_profile top_offset width
              ]
            ),
            Entry.new(
              type: "rail",
              variant: "zipped-coulisse-pair",
              renderer_family: "solid_profile",
              status: "supported",
              option_keys: %w[
                attached_to mirrored solid_profile
              ]
            ),
            Entry.new(
              type: "slat",
              variant: "venetian-pack",
              renderer_family: "slat_pattern",
              status: "supported",
              option_keys: %w[
                hit_inset_x hit_inset_y ladder_offsets lift_cord_offsets marker_gap pattern_id preset slat_count slat_height
                tilt tone_cycle
              ]
            ),
            Entry.new(
              type: "support",
              variant: "mount-pair",
              renderer_family: "solid_support_profile",
              status: "supported",
              option_keys: %w[
                accent_inset_x accent_inset_y accent_style gap height hit_inset_x hit_inset_y inset_x marker_gap mirrored
                point_inset rx solid_profile width
              ]
            )
          ].freeze

          def self.default
            new(DEFAULT_ENTRIES)
          end

          def self.key(type, variant)
            "#{type}:#{variant}"
          end

          def initialize(entries = DEFAULT_ENTRIES)
            @entries = entries.each_with_object({}) do |entry, index|
              index[entry.key] = entry
            end
          end

          def fetch(type, variant)
            entries.fetch(self.class.key(type, variant))
          end

          def registered?(type, variant)
            entries.key?(self.class.key(type, variant))
          end

          def supported?(type, variant)
            entry = entries[self.class.key(type, variant)]

            entry&.status == "supported"
          end

          def keys
            entries.keys.sort
          end

          private

          attr_reader :entries
        end
      end
    end
  end
end
