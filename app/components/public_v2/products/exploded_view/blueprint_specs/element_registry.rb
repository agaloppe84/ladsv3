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

            def required_option_keys_for(slot)
              ElementRegistry.required_option_keys_for(key, slot)
            end

            def option_type_for(option_key)
              ElementRegistry.option_type_for(option_key)
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
                embouts grip hit_height hit_inset_x hit_y_offset marker_offset_x marker_offset_y preset solid_profile
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
                hit_inset_x hit_inset_y line_count marker_gap pattern_id pattern_style preset tick_step
              ]
            ),
            Entry.new(
              type: "housing",
              variant: "front-coffre",
              renderer_family: "solid_housing_profile",
              status: "supported",
              option_keys: %w[
                hit_inset_x hit_inset_y hole_offsets marker_gap points preset solid_profile style
              ]
            ),
            Entry.new(
              type: "housing",
              variant: "kiss-50-cassette",
              renderer_family: "solid_housing_profile",
              status: "supported",
              option_keys: %w[
                cheeks hit_inset_x hit_inset_y marker_gap opening points preset roll_height roll_inset_x roll_radius roll_y_offset
                screw_side_inset solid_profile style
              ]
            ),
            Entry.new(
              type: "motor",
              variant: "tubular",
              renderer_family: "solid_motor_profile",
              status: "supported",
              option_keys: %w[
                drawing_right head_preset hit_height hit_width hit_x hit_y_offset marker_gap solid_profile tube_cap_width
                tube_preset tube_x tube_y_offset y
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

          OPTION_TYPES = {
            "accent" => :object,
            "accent_inset_x" => :number,
            "accent_inset_y" => :number,
            "accent_style" => :string,
            "attached_features" => :object,
            "attached_to" => :string,
            "axis" => :string,
            "band_count" => :integer,
            "band_radius" => :number,
            "base_height" => :number,
            "base_offset_y" => :number,
            "bead_count" => :integer,
            "bead_radius" => :number,
            "body_tone" => :string,
            "bottom_gap" => :number,
            "cap_ratio" => :number,
            "catch_divisions" => :integer,
            "catch_indexes" => :array,
            "cell_count" => :integer,
            "cell_depth" => :number,
            "cheeks" => :object,
            "cord_bottom_offset_y" => :number,
            "cord_offset_x" => :number,
            "cord_tabs" => :object,
            "cord_top_offset_y" => :number,
            "dot_y_offsets" => :array,
            "drawing_right" => :number,
            "edge_fastener_indexes" => :array,
            "edge_fastener_radius" => :number,
            "embouts" => :boolean,
            "extra_bottom" => [:number, :string],
            "extra_top" => [:number, :string],
            "feature_id" => :string,
            "gap" => [:number, :string],
            "grip" => [:boolean, :object],
            "grip_height" => :number,
            "grip_rx" => :number,
            "grip_width" => :number,
            "head_preset" => :string,
            "height" => :number,
            "height_extra" => [:number, :string],
            "height_inset" => :number,
            "highlight" => :object,
            "hit_height" => :number,
            "hit_x" => :number,
            "hit_inset_left" => :number,
            "hit_inset_x" => :number,
            "hit_inset_y" => :number,
            "hit_width" => :number,
            "hit_y_offset" => :number,
            "hole_offsets" => :array,
            "horizontal_count" => :integer,
            "inner_bottom_inset" => :number,
            "inner_inset_x" => :number,
            "inner_inset_y" => :number,
            "inner_top_inset" => :number,
            "inset_x" => :number,
            "ladder_offsets" => :array,
            "layer_offset" => :number,
            "left_gap" => [:number, :string],
            "lift_cord_offsets" => :array,
            "line_count" => :integer,
            "magnet_inset_x" => :number,
            "marker_gap" => :number,
            "marker_offset_x" => :number,
            "marker_offset_y" => :number,
            "marker_side" => :string,
            "mirrored" => :boolean,
            "offset_x" => :number,
            "opaque_ratio" => :number,
            "opening" => :object,
            "pattern_id" => :string,
            "pattern_style" => :string,
            "pattern_thread_width" => :number,
            "pleat_amplitude" => :number,
            "pleat_count" => :integer,
            "point_inset" => :number,
            "point_radius" => :number,
            "points" => :boolean,
            "preset" => :string,
            "radius" => :number,
            "receiver_offset_y" => :number,
            "right_gap" => [:number, :string],
            "roll_height" => :number,
            "roll_inset_x" => :number,
            "roll_radius" => :number,
            "roll_y_offset" => :number,
            "rx" => :number,
            "screw_side_inset" => :number,
            "segment_width" => :number,
            "slat_count" => :integer,
            "slat_height" => :number,
            "slot" => :object,
            "slot_count" => :integer,
            "solid_profile" => :string,
            "style" => :string,
            "thread_offsets" => :array,
            "tick_step" => :integer,
            "tilt" => :number,
            "tone_cycle" => :array,
            "top_gap" => :number,
            "top_offset" => [:number, :string],
            "tube_cap_width" => :number,
            "tube_preset" => :string,
            "tube_x" => :number,
            "tube_y_offset" => :number,
            "vertical_count" => :integer,
            "width" => :number,
            "width_extra" => :number,
            "x_offset_from_fabric" => :number,
            "y" => :number,
            "y_offset_from_fabric_bottom" => :number,
            "y_offset_from_profiles" => :number
          }.freeze

          REQUIRED_OPTION_KEYS = {
            "bar:bottom-charge" => {
              "bottom-bar" => %w[
                accent grip grip_height grip_rx grip_width hit_inset_x hit_inset_y magnet_inset_x marker_gap
                preset solid_profile
              ]
            },
            "bar:roll-tube" => {
              "roll" => %w[
                body_tone highlight hit_inset_x hit_inset_y marker_gap solid_profile
              ]
            },
            "bar:threshold" => {
              "*" => %w[hit_inset_x hit_inset_y marker_gap solid_profile],
              "bottom-bar" => %w[accent preset],
              "bottom-rail" => %w[cord_tabs preset slot],
              "bottom-threshold" => %w[accent preset],
              "intermediate-rail" => %w[
                accent grip height point_radius rx width_extra x_offset_from_fabric y_offset_from_fabric_bottom
              ]
            },
            "bar:vertical-handle" => {
              "handle" => %w[
                axis gap grip grip_height grip_rx grip_width height_inset hit_inset_x hit_inset_y marker_gap
                preset rx solid_profile width y_offset_from_profiles
              ]
            },
            "bar:zipped-load" => {
              "bottom-bar" => %w[
                hit_height hit_inset_x hit_y_offset marker_offset_x marker_offset_y preset solid_profile
              ]
            },
            "closure:magnetic-receivers" => {
              "closure" => %w[
                base_height base_offset_y hit_height hit_inset_x hit_y_offset marker_offset_y point_radius radius
                receiver_offset_y solid_profile
              ]
            },
            "closure:plissee-lock" => {
              "closure" => %w[
                catch_divisions catch_indexes hit_inset_left hit_inset_y hit_width marker_offset_x marker_offset_y
                radius solid_profile
              ]
            },
            "closure:rail-bavettes" => {
              "attached-features" => %w[
                feature_id hit_inset_x hit_inset_y marker_gap solid_profile
              ]
            },
            "control:bead-chain" => {
              "controls" => %w[
                bead_count bead_radius cord_bottom_offset_y cord_top_offset_y gap hit_inset_x hit_inset_y
                marker_gap rx segment_width solid_profile width
              ]
            },
            "control:cord-pair" => {
              "guide-cords" => %w[
                bottom_gap dot_y_offsets hit_inset_x hit_inset_y marker_gap offset_x point_radius segment_width
                solid_profile top_gap
              ],
              "ladder-cords" => %w[
                point_radius segment_width solid_profile
              ]
            },
            "control:venetian-wand" => {
              "controls" => %w[
                bead_count bead_radius cord_bottom_offset_y cord_offset_x cord_top_offset_y gap hit_inset_x
                hit_inset_y marker_gap rx segment_width solid_profile width
              ]
            },
            "fabric:bordered-grid-solid" => {
              "fabric" => %w[
                hit_inset_x hit_inset_y horizontal_count marker_gap pattern_id pattern_style preset vertical_count
              ]
            },
            "fabric:duo-bands-solid" => {
              "fabric" => %w[
                band_count band_radius hit_inset_x hit_inset_y layer_offset marker_gap opaque_ratio pattern_id
                pattern_style preset
              ]
            },
            "fabric:honeycomb-solid" => {
              "fabric" => %w[
                cell_count cell_depth hit_inset_x hit_inset_y marker_gap pattern_id pattern_style
                pattern_thread_width preset thread_offsets
              ]
            },
            "fabric:pleated-solid" => {
              "fabric" => %w[
                hit_inset_x hit_inset_y marker_gap pattern_id pattern_style pattern_thread_width pleat_amplitude
                pleat_count preset thread_offsets
              ]
            },
            "fabric:zipped-solid" => {
              "fabric" => %w[
                hit_inset_x hit_inset_y line_count marker_gap pattern_id pattern_style preset
              ]
            },
            "housing:front-coffre" => {
              "top-housing" => %w[
                hit_inset_x hit_inset_y hole_offsets marker_gap preset solid_profile
              ]
            },
            "housing:kiss-50-cassette" => {
              "top-housing" => %w[
                hit_inset_x hit_inset_y marker_gap preset roll_height roll_inset_x roll_radius roll_y_offset
                screw_side_inset solid_profile
              ]
            },
            "motor:tubular" => {
              "motor" => %w[
                drawing_right head_preset hit_height hit_width hit_x hit_y_offset marker_gap solid_profile tube_cap_width
                tube_preset tube_x tube_y_offset y
              ]
            },
            "rail:duette-head" => {
              "top-rail" => %w[
                cord_tabs hit_inset_x hit_inset_y marker_gap preset slot solid_profile
              ]
            },
            "rail:double-coulisse-pair" => {
              "side-guides" => %w[
                attached_features cap_ratio extra_bottom extra_top hit_inset_x hit_inset_y inner_inset_x
                left_gap marker_gap point_radius preset right_gap rx slot_count solid_profile width
              ]
            },
            "rail:horizontal-guide" => {
              "headrail" => %w[
                hit_inset_x hit_inset_y marker_gap point_radius preset solid_profile
              ],
              "top-guide" => %w[
                hit_inset_x hit_inset_y marker_gap point_radius preset solid_profile
              ]
            },
            "rail:profile-pair" => {
              "side-profiles" => %w[
                height_extra hit_inset_x hit_inset_y inner_bottom_inset inner_inset_x inner_top_inset left_gap
                marker_gap point_radius preset right_gap rx slot_count solid_profile top_offset width
              ]
            },
            "rail:zipped-coulisse-pair" => {
              "side-guides" => %w[solid_profile]
            },
            "slat:venetian-pack" => {
              "fabric" => %w[
                hit_inset_x hit_inset_y ladder_offsets lift_cord_offsets marker_gap pattern_id slat_count
                slat_height tilt tone_cycle
              ]
            },
            "support:mount-pair" => {
              "*" => %w[solid_profile]
            }
          }.freeze

          def self.default
            new(DEFAULT_ENTRIES)
          end

          def self.key(type, variant)
            "#{type}:#{variant}"
          end

          def self.option_type_for(option_key)
            OPTION_TYPES[option_key.to_s]
          end

          def self.required_option_keys_for(entry_key, slot)
            contracts = REQUIRED_OPTION_KEYS.fetch(entry_key.to_s, {})
            wildcard_keys = Array(contracts["*"])
            slot_keys = Array(contracts[slot.to_s])

            (wildcard_keys + slot_keys).map(&:to_s).uniq.sort
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
