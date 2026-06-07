# frozen_string_literal: true

require_relative "../blueprints/element_builder_helpers"
require_relative "../layouts"
require_relative "assembler"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class DataLayoutBuilder
          include Blueprints::ElementBuilderHelpers

          attr_reader :blueprint, :assembled

          def initialize(blueprint)
            @blueprint = blueprint
            @assembled = blueprint.assembled_blueprint
          end

          def build
            case blueprint.spec.product_slug
            when "store-venitien"
              build_store_venitien
            when "store-duette"
              build_store_duette
            when "moustiquaire-plissee"
              build_moustiquaire_plissee
            when "moustiquaire-enroulable-verticale"
              build_moustiquaire_enroulable_verticale
            when "store-vertical-zippe"
              build_store_vertical_zippe
            else
              raise NotImplementedError, "No data layout builder for #{blueprint.spec.product_slug.inspect}"
            end
          end

          private

          def build_store_venitien
            headrail = build_venetian_headrail
            supports = build_venetian_supports(headrail:)
            slats = build_venetian_slats(headrail:)
            bottom_bar = build_venetian_bottom_bar(slats:)
            control = build_venetian_control(slats:)
            groups = build_venetian_groups(headrail:, supports:, slats:, bottom_bar:, control:)
            callouts = build_venetian_callouts(groups:)

            VenetianDrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              headrail:,
              slats:,
              bottom_bar:,
              control:,
              supports:,
              callouts:
            )
          end

          def build_venetian_headrail
            element = assembled.element("boitier-haut")
            options = element.options
            box = required_box(element)

            horizontal_rail_element(
              preset: option_symbol(options, "preset"),
              x: box.x,
              y: box.y,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              screw_side_inset: options.fetch("screw_side_inset"),
              inner_inset_y: options.fetch("inner_inset_y"),
              solid_profile: solid_profile_config(options).merge(
                point_radius: options.fetch("point_radius")
              )
            )
          end

          def build_venetian_supports(headrail:)
            element = assembled.element("supports-pose")
            options = element.options

            mount_support_pair_element(
              reference: headrail.body,
              gap: option_gap(options, "gap"),
              width: options.fetch("width"),
              height: options.fetch("height"),
              inset_x: options.fetch("inset_x"),
              marker_gap: options.fetch("marker_gap"),
              pair_class: VenetianSupportPair,
              rx: options.fetch("rx"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              solid_profile: {
                id: options.fetch("solid_profile"),
                point_inset: options.fetch("point_inset"),
                detail_inset_x: options.fetch("detail_inset_x"),
                detail_inset_y: options.fetch("detail_inset_y")
              }
            )
          end

          def build_venetian_slats(headrail:)
            element = assembled.element("lames-orientables")
            options = element.options
            box = required_box(element)
            slats = venetian_slat_pack_element(
              reference: headrail.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - headrail.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              slat_count: options.fetch("slat_count"),
              slat_height: options.fetch("slat_height"),
              tilt: options.fetch("tilt"),
              ladder_offsets: x_offsets(options.fetch("ladder_offsets")),
              lift_cord_offsets: x_offsets(options.fetch("lift_cord_offsets"))
            )

            slats = slats.with_slat_pattern(
              SlatPatterns.venetian_pack(
                id: options.fetch("pattern_id"),
                slats:,
                tone_cycle: symbol_list(options.fetch("tone_cycle"))
              )
            )
            cord_options = assembled.element("cordons-echelles").options

            slats.with_cord_solid_profile(
              SolidProfiles.control_segments(
                id: cord_options.fetch("solid_profile"),
                variant: :venetian_ladder_cords,
                segment_boxes: slats.cord_segment_boxes(segment_width: cord_options.fetch("segment_width")),
                points: slats.cord_points,
                point_radius: cord_options.fetch("point_radius")
              )
            )
          end

          def build_venetian_bottom_bar(slats:)
            element = assembled.element("barre-finale")
            options = element.options
            box = required_box(element)

            threshold_bar_element(
              reference: slats.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - slats.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              detail_inset_x: options.fetch("detail_inset_x"),
              tick_inset_x: options.fetch("tick_inset_x"),
              tick_inset_y: options.fetch("tick_inset_y"),
              solid_profile: solid_profile_config(options).merge(
                detail: options.fetch("detail")
              )
            )
          end

          def build_venetian_control(slats:)
            element = assembled.element("commande")
            options = element.options
            control = venetian_control_element(
              reference: slats.body,
              preset: option_symbol(options, "preset"),
              gap: option_gap(options, "gap"),
              y: slats.slat_top,
              width: options.fetch("width"),
              height: slats.slat_bottom - slats.slat_top,
              rx: options.fetch("rx"),
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              cord_offset_x: options.fetch("cord_offset_x"),
              cord_top_offset_y: options.fetch("cord_top_offset_y"),
              cord_bottom_offset_y: options.fetch("cord_bottom_offset_y"),
              bead_count: options.fetch("bead_count")
            )

            control.with_solid_profile(
              SolidProfiles.wand_control(
                id: options.fetch("solid_profile"),
                body: control.body,
                cord_x: control.cord_top.x,
                top: control.cord_top.y,
                bottom: control.cord_bottom.y,
                bead_ys: control.bead_points.map(&:y),
                segment_width: options.fetch("segment_width"),
                bead_radius: options.fetch("bead_radius")
              )
            )
          end

          def build_venetian_groups(headrail:, supports:, slats:, bottom_bar:, control:)
            {
              "tablier-venitien" => LayoutGroup.new(id: "tablier-venitien", boxes: [headrail.body, slats.body, bottom_bar.body]),
              "pose-haute" => LayoutGroup.new(id: "pose-haute", boxes: [headrail.body, supports.left, supports.right]),
              "lames-cordons" => LayoutGroup.attached(id: "lames-cordons", boxes: [slats.body]),
              "commande-laterale" => LayoutGroup.new(id: "commande-laterale", boxes: [control.body])
            }
          end

          def build_venetian_callouts(groups:)
            assembled.callouts.each_with_object({}) do |definition, callouts|
              callouts[definition.part_id] = callout_from_definition(definition, groups:)
            end
          end

          def build_store_duette
            top_rail = build_duette_top_rail
            supports = build_duette_supports(top_rail:)
            fabric = build_duette_fabric(top_rail:)
            intermediate_rail = build_duette_intermediate_rail(fabric:)
            bottom_rail = build_duette_bottom_rail(fabric:)
            cords = build_duette_cords(top_rail:, fabric:, intermediate_rail:, bottom_rail:)
            top_rail = with_duette_slotted_rail_profile("rail-superieur", rail: top_rail, fabric:, cords:, slot_side: :bottom)
            intermediate_rail = with_duette_intermediate_rail_profile(intermediate_rail:, cords:)
            bottom_rail = with_duette_slotted_rail_profile("rail-bas", rail: bottom_rail, fabric:, cords:, slot_side: :top)
            groups = build_duette_groups(top_rail:, supports:, fabric:, intermediate_rail:, bottom_rail:, cords:)
            callouts = build_duette_callouts(groups:)

            DuetteDrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              top_rail:,
              supports:,
              fabric:,
              intermediate_rail:,
              bottom_rail:,
              cords:,
              callouts:
            )
          end

          def build_duette_top_rail
            element = assembled.element("rail-superieur")
            options = element.options
            box = required_box(element)

            horizontal_rail_element(
              preset: option_symbol(options, "preset"),
              x: box.x,
              y: box.y,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y")
            )
          end

          def build_duette_supports(top_rail:)
            element = assembled.element("supports-pose")
            options = element.options

            mount_support_pair_element(
              reference: top_rail.body,
              gap: option_gap(options, "gap"),
              width: options.fetch("width"),
              height: options.fetch("height"),
              inset_x: options.fetch("inset_x"),
              marker_gap: options.fetch("marker_gap"),
              rx: options.fetch("rx"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              solid_profile: {
                id: options.fetch("solid_profile"),
                point_inset: options.fetch("point_inset"),
                detail_inset_x: options.fetch("detail_inset_x"),
                detail_inset_y: options.fetch("detail_inset_y")
              }
            )
          end

          def build_duette_fabric(top_rail:)
            element = assembled.element("toile-duette")
            options = element.options
            box = required_box(element)

            fabric_element(
              variant: :honeycomb,
              reference: top_rail.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - top_rail.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              cell_count: options.fetch("cell_count"),
              cell_depth: layout_size(options.fetch("cell_depth")),
              pattern_id: options.fetch("pattern_id"),
              pattern_style: option_symbol(options, "pattern_style"),
              pattern_thread_width: options.fetch("pattern_thread_width"),
              thread_offsets: thread_offsets(options.fetch("thread_offsets"))
            )
          end

          def build_duette_intermediate_rail(fabric:)
            element = assembled.element("rail-intermediaire")
            options = element.options
            body = if element.box
                     required_box(element)
                   else
                     Box.new(
                       x: fabric.body.x + options.fetch("x_offset_from_fabric"),
                       y: fabric.body.bottom + options.fetch("y_offset_from_fabric_bottom"),
                       width: fabric.body.width + options.fetch("width_extra"),
                       height: options.fetch("height"),
                       rx: options.fetch("rx")
                     )
                   end
            body = layout_box(body)

            BarElement.build(
              variant: :threshold,
              hit: layout_box(LayoutRules.hit_box(body, inset_x: options.fetch("hit_inset_x"), inset_y: options.fetch("hit_inset_y"))),
              body:,
              marker: layout_anchor(body, side: option_symbol(options, "marker_side", default: :right), gap: options.fetch("marker_gap")),
              detail_inset_x: options.fetch("detail_inset_x"),
              tick_inset_x: options.fetch("tick_inset_x"),
              tick_inset_y: options.fetch("tick_inset_y")
            )
          end

          def build_duette_bottom_rail(fabric:)
            element = assembled.element("rail-bas")
            options = element.options
            box = required_box(element)

            threshold_bar_element(
              reference: fabric.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - fabric.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              detail_inset_x: options.fetch("detail_inset_x"),
              tick_inset_x: options.fetch("tick_inset_x"),
              tick_inset_y: options.fetch("tick_inset_y")
            )
          end

          def build_duette_cords(top_rail:, fabric:, intermediate_rail:, bottom_rail:)
            element = assembled.element("cordons-guidage")
            options = element.options
            left_x = layout_point(Point.new(x: fabric.body.x + options.fetch("offset_x"), y: fabric.body.y)).x
            right_x = layout_point(Point.new(x: fabric.body.right - options.fetch("offset_x"), y: fabric.body.y)).x
            top_y = layout_y(top_rail.body.bottom + options.fetch("top_gap"))
            bottom_y = layout_y(bottom_rail.body.y - options.fetch("bottom_gap"))
            dot_ys = duette_cord_dot_ys(options.fetch("dot_y_offsets"), fabric:, intermediate_rail:)
            hit = layout_box(
              Box.new(
                x: left_x - options.fetch("hit_inset_x"),
                y: top_y - options.fetch("hit_inset_y"),
                width: right_x - left_x + (options.fetch("hit_inset_x") * 2),
                height: bottom_y - top_y + (options.fetch("hit_inset_y") * 2),
                rx: 0
              ),
              preserve_size: true
            )

            DuetteCordPair.new(
              hit:,
              left_x:,
              right_x:,
              top_y:,
              bottom_y:,
              marker: layout_point(Point.new(x: left_x - options.fetch("marker_gap"), y: fabric.body.center_y)),
              dot_ys:,
              solid_profile: SolidProfiles.control_pair(
                id: options.fetch("solid_profile"),
                xs: [left_x, right_x],
                top: top_y,
                bottom: bottom_y,
                dot_ys:,
                segment_width: options.fetch("segment_width"),
                point_radius: options.fetch("point_radius")
              )
            )
          end

          def with_duette_slotted_rail_profile(element_id, rail:, fabric:, cords:, slot_side:)
            options = assembled.element(element_id).options
            slot = options.fetch("slot")
            tabs = options.fetch("cord_tabs")
            slot_height = slot.fetch("height")
            slot_y = slot_side == :bottom ? rail.body.bottom : rail.body.y - slot_height

            rail.with_solid_profile(
              horizontal_bar_solid_profile(
                {
                  id: options.fetch("solid_profile"),
                  extensions: [
                    {
                      id: slot.fetch("id", "toile-slot"),
                      side: slot_side,
                      x: fabric.body.x,
                      y: slot_y,
                      width: fabric.body.width,
                      height: slot_height,
                      rx: slot.fetch("rx"),
                      tone: slot.fetch("tone", "mid")
                    }
                  ],
                  tabs: [
                    {
                      id: tabs.fetch("id", "cord-tab"),
                      side: slot_side,
                      x_positions: [cords.left_x, cords.right_x],
                      y: duette_tab_y(slot_y:, slot_height:, tabs:, side: slot_side),
                      width: tabs.fetch("width"),
                      height: tabs.fetch("height"),
                      rx: tabs.fetch("rx"),
                      tone: tabs.fetch("tone", "dark")
                    }
                  ]
                },
                bar: rail
              )
            )
          end

          def with_duette_intermediate_rail_profile(intermediate_rail:, cords:)
            options = assembled.element("rail-intermediaire").options

            intermediate_rail.with_solid_profile(
              horizontal_bar_solid_profile(
                {
                  id: options.fetch("solid_profile"),
                  detail: options.fetch("detail"),
                  grip: options.fetch("grip"),
                  points: [cords.left_x, cords.right_x].map { |x| Point.new(x:, y: intermediate_rail.body.center_y) },
                  point_radius: options.fetch("point_radius")
                },
                bar: intermediate_rail
              )
            )
          end

          def duette_tab_y(slot_y:, slot_height:, tabs:, side:)
            overlap = tabs.fetch("overlap", 0)
            height = tabs.fetch("height")

            side == :bottom ? slot_y + slot_height - overlap : slot_y - height + overlap
          end

          def duette_cord_dot_ys(values, fabric:, intermediate_rail:)
            values.map do |value|
              case value
              when "intermediate_center"
                layout_y(intermediate_rail.body.center_y)
              when Numeric
                layout_y(value.negative? ? fabric.body.bottom + value : fabric.body.y + value)
              else
                raise ArgumentError, "Unknown Duette cord y offset: #{value.inspect}"
              end
            end
          end

          def build_duette_groups(top_rail:, supports:, fabric:, intermediate_rail:, bottom_rail:, cords:)
            {
              "tablier-duette" => LayoutGroup.new(id: "tablier-duette", boxes: [top_rail.body, fabric.body, intermediate_rail.body, bottom_rail.body]),
              "pose-haute" => LayoutGroup.new(id: "pose-haute", boxes: [top_rail.body, supports.left, supports.right]),
              "toile-rail-intermediaire" => LayoutGroup.attached(id: "toile-rail-intermediaire", boxes: [fabric.body, intermediate_rail.body]),
              "cordons-toile" => LayoutGroup.new(id: "cordons-toile", boxes: [cords.hit, fabric.body])
            }
          end

          def build_duette_callouts(groups:)
            assembled.callouts.each_with_object({}) do |definition, callouts|
              callouts[definition.part_id] = callout_from_definition(definition, groups:)
            end
          end

          def build_moustiquaire_plissee
            guide = build_plissee_guide
            fabric = build_plissee_fabric(guide:)
            profiles = build_plissee_profiles(fabric:)
            handle = build_plissee_handle(fabric:, profiles:)
            threshold = build_plissee_threshold(guide:, profiles:)
            lock = build_plissee_lock(handle:)
            groups = build_plissee_groups(fabric:, handle:, lock:)
            callouts = build_plissee_callouts(groups:)

            PlisseeDrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              guide:,
              profiles:,
              fabric:,
              handle:,
              threshold:,
              lock:,
              callouts:
            )
          end

          def build_plissee_guide
            element = assembled.element("guide-haut")
            options = element.options
            box = required_box(element)

            horizontal_rail_element(
              preset: option_symbol(options, "preset"),
              x: box.x,
              y: box.y,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              solid_profile: solid_profile_config(options).merge(
                point_radius: options.fetch("point_radius")
              )
            )
          end

          def build_plissee_fabric(guide:)
            element = assembled.element("toile-plissee")
            options = element.options
            box = required_box(element)

            fabric_element(
              variant: :pleated,
              reference: guide.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - guide.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              pleat_count: options.fetch("pleat_count"),
              pleat_amplitude: options.fetch("pleat_amplitude"),
              thread_offsets: thread_offsets(options.fetch("thread_offsets")),
              pattern_id: options.fetch("pattern_id"),
              pattern_style: option_symbol(options, "pattern_style"),
              pattern_thread_width: options.fetch("pattern_thread_width")
            )
          end

          def build_plissee_profiles(fabric:)
            element = assembled.element("profils-muraux")
            options = element.options
            top = fabric.body.y - layout_gap(options.fetch("top_offset"))
            height = fabric.body.height + layout_gap(options.fetch("height_extra"))

            vertical_rail_pair_element(
              reference: fabric.body,
              preset: option_symbol(options, "preset"),
              left_gap: option_gap(options, "left_gap"),
              right_gap: option_gap(options, "right_gap"),
              y: top,
              width: options.fetch("width"),
              height:,
              rx: options.fetch("rx"),
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              slot_count: options.fetch("slot_count"),
              inner_inset_x: options.fetch("inner_inset_x"),
              inner_top_inset: options.fetch("inner_top_inset"),
              inner_bottom_inset: options.fetch("inner_bottom_inset"),
              solid_profile: solid_profile_config(options).merge(
                point_radius: options.fetch("point_radius")
              )
            )
          end

          def build_plissee_handle(fabric:, profiles:)
            element = assembled.element("barre-poignee")
            options = element.options

            vertical_handle_bar_element(
              reference: fabric.body,
              preset: option_symbol(options, "preset"),
              gap: option_gap(options, "gap"),
              y: profiles.left.y + options.fetch("y_offset_from_profiles"),
              width: options.fetch("width"),
              height: profiles.left.height - options.fetch("height_inset"),
              rx: options.fetch("rx"),
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              grip_width: options.fetch("grip_width"),
              grip_height: options.fetch("grip_height"),
              grip_rx: options.fetch("grip_rx"),
              solid_profile: solid_profile_config(options).merge(
                axis: option_symbol(options, "axis"),
                grip: options.fetch("grip")
              )
            )
          end

          def build_plissee_threshold(guide:, profiles:)
            element = assembled.element("seuil-bas")
            options = element.options
            box = required_box(element)

            threshold_bar_element(
              reference: profiles.left,
              preset: option_symbol(options, "preset"),
              gap: box.y - profiles.left.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              solid_profile: solid_profile_config(options).merge(
                detail: options.fetch("detail")
              )
            )
          end

          def build_plissee_lock(handle:)
            element = assembled.element("verrouillage")
            options = element.options

            plissee_lock_element(
              handle:,
              radius: options.fetch("radius"),
              catch_divisions: options.fetch("catch_divisions"),
              catch_indexes: options.fetch("catch_indexes"),
              hit_inset_left: options.fetch("hit_inset_left"),
              hit_inset_y: options.fetch("hit_inset_y"),
              hit_width: options.fetch("hit_width"),
              marker_offset_x: options.fetch("marker_offset_x"),
              marker_offset_y: options.fetch("marker_offset_y"),
              solid_profile: solid_profile_config(options)
            )
          end

          def build_plissee_groups(fabric:, handle:, lock:)
            {
              "toile-poignee" => LayoutGroup.attached(id: "toile-poignee", boxes: [fabric.body, handle.body]),
              "poignee-verrouillage" => LayoutGroup.attached(id: "poignee-verrouillage", boxes: [handle.body, lock.hit])
            }
          end

          def build_plissee_callouts(groups:)
            assembled.callouts.each_with_object({}) do |definition, callouts|
              callouts[definition.part_id] = callout_from_definition(definition, groups:)
            end
          end

          def build_moustiquaire_enroulable_verticale
            cassette = build_enroulable_cassette
            fabric = build_enroulable_fabric(cassette:)
            rails = build_enroulable_rails(fabric:)
            bottom_bar = build_enroulable_bottom_bar(fabric:)
            lock = build_enroulable_lock(bottom_bar:)
            bavettes = build_enroulable_bavettes(rails:)
            groups = build_enroulable_groups(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:)
            callouts = build_enroulable_callouts(groups:)

            EnrollableDrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              cassette:,
              rails:,
              fabric:,
              bottom_bar:,
              lock:,
              bavettes:,
              callouts:
            )
          end

          def build_enroulable_cassette
            element = assembled.element("caisson")
            options = element.options
            box = required_box(element)

            cassette_housing_element(
              preset: option_symbol(options, "preset"),
              x: box.x,
              y: box.y,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              roll_inset_x: options.fetch("roll_inset_x"),
              roll_y_offset: options.fetch("roll_y_offset"),
              roll_height: options.fetch("roll_height"),
              roll_radius: options.fetch("roll_radius"),
              screw_side_inset: options.fetch("screw_side_inset"),
              solid_profile: solid_profile_config(options).merge(
                style: option_symbol(options, "style", default: :front_coffre),
                points: options.fetch("points", false),
                opening: options.fetch("opening", {}),
                cheeks: options.fetch("cheeks", {})
              )
            )
          end

          def build_enroulable_fabric(cassette:)
            element = assembled.element("toile-bordee")
            options = element.options
            box = required_box(element)

            fabric_element(
              variant: :bordered_grid,
              reference: cassette.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - cassette.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              vertical_count: options.fetch("vertical_count"),
              horizontal_count: options.fetch("horizontal_count"),
              edge_fastener_indexes: options.fetch("edge_fastener_indexes", []),
              edge_fastener_radius: options.fetch("edge_fastener_radius", 0),
              pattern_id: options.fetch("pattern_id"),
              pattern_style: option_symbol(options, "pattern_style")
            )
          end

          def build_enroulable_rails(fabric:)
            element = assembled.element("double-coulisse")
            options = element.options
            top = fabric.body.y - layout_gap(options.fetch("extra_top"))
            height = fabric.body.height + layout_gap(options.fetch("extra_top")) + layout_gap(options.fetch("extra_bottom"))

            vertical_rail_pair_element(
              reference: fabric.body,
              preset: option_symbol(options, "preset"),
              left_gap: option_symbol(options, "left_gap"),
              right_gap: option_symbol(options, "right_gap"),
              y: top,
              width: options.fetch("width"),
              height:,
              rx: options.fetch("rx"),
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              slot_count: options.fetch("slot_count"),
              inner_inset_x: options.fetch("inner_inset_x"),
              solid_profile: solid_profile_config(options).merge(
                cap_ratio: options.fetch("cap_ratio"),
                point_radius: options.fetch("point_radius")
              ),
              attached_features: options.fetch("attached_features")
            )
          end

          def build_enroulable_bottom_bar(fabric:)
            element = assembled.element("barre-charge")
            options = element.options
            box = required_box(element)

            bottom_bar_element(
              reference: fabric.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - fabric.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: options.fetch("marker_gap"),
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              grip_width: options.fetch("grip_width"),
              grip_height: options.fetch("grip_height"),
              grip_rx: options.fetch("grip_rx"),
              magnet_inset_x: options.fetch("magnet_inset_x"),
              solid_profile: solid_profile_config(options).merge(
                detail: options.fetch("detail"),
                grip: options.fetch("grip")
              )
            )
          end

          def build_enroulable_lock(bottom_bar:)
            element = assembled.element("fermeture-magnetique")
            options = element.options

            magnetic_receiver_element(
              bottom_bar:,
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_y_offset: options.fetch("hit_y_offset"),
              hit_height: options.fetch("hit_height"),
              marker_offset_y: options.fetch("marker_offset_y"),
              receiver_offset_y: options.fetch("receiver_offset_y"),
              radius: options.fetch("radius"),
              solid_profile: solid_profile_config(options).merge(
                point_radius: options.fetch("point_radius"),
                base_height: options.fetch("base_height"),
                base_offset_y: options.fetch("base_offset_y")
              )
            )
          end

          def build_enroulable_bavettes(rails:)
            element = assembled.element("bavettes")
            options = element.options

            rail_bavettes_element(
              rails:,
              marker_gap: options.fetch("marker_gap"),
              feature_id: options.fetch("feature_id").to_sym,
              hit_inset_x: options.fetch("hit_inset_x"),
              hit_inset_y: options.fetch("hit_inset_y"),
              solid_profile: solid_profile_config(options)
            )
          end

          def build_enroulable_groups(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:)
            {
              "caisson-toile" => LayoutGroup.new(id: "caisson-toile", boxes: [cassette.body, fabric.body]),
              "toile-coulisses" => LayoutGroup.new(id: "toile-coulisses", boxes: [fabric.body, rails.left, rails.right]),
              "fermeture-barre" => LayoutGroup.attached(id: "fermeture-barre", boxes: [bottom_bar.body, lock.hit]),
              "coulisses-bavettes" => LayoutGroup.attached(id: "coulisses-bavettes", boxes: [rails.left, rails.right, bavettes.left, bavettes.right])
            }
          end

          def build_enroulable_callouts(groups:)
            assembled.callouts.each_with_object({}) do |definition, callouts|
              callouts[definition.part_id] = callout_from_definition(definition, groups:)
            end
          end

          def build_store_vertical_zippe
            motor = build_vertical_zippe_motor
            coffre = build_vertical_zippe_coffre(motor:)
            fabric = build_vertical_zippe_fabric(coffre:)
            coulisse = build_vertical_zippe_coulisse(fabric:)
            barre = build_vertical_zippe_barre(coffre:, fabric:)
            supports = build_vertical_zippe_supports
            groups = build_vertical_zippe_groups(motor:, coffre:, fabric:, coulisse:, barre:)
            callouts = build_vertical_zippe_callouts(groups:)

            DrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              support_marker: supports.marker,
              supports:,
              motor:,
              coffre:,
              fabric:,
              coulisse:,
              barre:,
              callouts:
            )
          end

          def build_vertical_zippe_motor
            element = assembled.element("motorisation")
            options = element.options

            tubular_motor_element(
              drawing_right: 6_550,
              y: 640,
              head_preset: option_symbol(options, "head_preset"),
              tube_preset: option_symbol(options, "tube_preset"),
              tube_x: options.fetch("tube_x"),
              tube_cap_width: options.fetch("tube_cap_width"),
              marker_gap: 168,
              hit_x: 4_260,
              hit_y_offset: -40,
              hit_width: 2_580,
              hit_height: 330,
              tube_y_offset: 40,
              solid_profile: solid_profile_config(options)
            )
          end

          def build_vertical_zippe_coffre(motor:)
            element = assembled.element("coffre")
            options = element.options
            box = required_box(element)

            zipped_coffre_element(
              reference: motor.head,
              preset: option_symbol(options, "preset"),
              gap: box.y - motor.head.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: 160,
              hit_inset_x: 120,
              hit_inset_y: 75,
              hole_offsets: [488, 712],
              solid_profile: solid_profile_config(options).merge(
                style: option_symbol(options, "style", default: :front_coffre),
                points: options.fetch("points", false)
              )
            )
          end

          def build_vertical_zippe_fabric(coffre:)
            element = assembled.element("toile")
            options = element.options
            box = required_box(element)

            fabric_element(
              variant: :zipped,
              reference: coffre.body,
              preset: option_symbol(options, "preset"),
              gap: box.y - coffre.body.bottom,
              x: box.x,
              width: box.width,
              height: box.height,
              rx: box.rx,
              marker_gap: 160,
              hit_inset_x: 85,
              hit_inset_y: 55,
              line_count: options.fetch("line_count"),
              tick_step: options.fetch("tick_step", 2),
              pattern_id: options.fetch("pattern_id"),
              pattern_style: option_symbol(options, "pattern_style")
            )
          end

          def build_vertical_zippe_coulisse(fabric:)
            element = assembled.element("coulisses")
            options = element.options
            top = fabric.body.y - 140
            bottom = layout_y(fabric.body.bottom + layout_gap(92))

            zipped_coulisse_element(
              top:,
              bottom:,
              hit: Box.new(x: 470, y: top - 75, width: 300, height: (bottom - top) + 165),
              marker: Point.new(x: 410, y: top + ((bottom - top) / 2)),
              solid_profile: solid_profile_config(options)
            )
          end

          def build_vertical_zippe_barre(coffre:, fabric:)
            element = assembled.element("barre-charge")
            options = element.options
            box = required_box(element)

            zipped_load_bar_element(
              top: box.y,
              preset: option_symbol(options, "preset"),
              hit: Box.new(x: coffre.body.x - 50, y: box.y - 85, width: coffre.body.width + 100, height: 265),
              body: box,
              height: box.height,
              marker: Point.new(x: 6_900, y: box.y + 90),
              solid_profile: solid_profile_config(options).merge(
                embouts: options.fetch("embouts", false),
                grip: options.fetch("grip", false)
              )
            )
          end

          def build_vertical_zippe_supports
            left = layout_box(Box.new(x: 1_240, y: 140, width: 420, height: 320, rx: 42))
            right = layout_box(Box.new(x: canvas_spec.svg_width - left.right, y: left.y, width: left.width, height: left.height, rx: left.rx))
            hit = layout_box(Box.new(x: 1_120, y: 90, width: 5_560, height: 430, rx: 0), preserve_size: true)
            marker = layout_point(Point.new(x: 6_718, y: 305))

            MountSupportPair.new(
              hit:,
              left:,
              right:,
              marker:,
              solid_profiles: SolidProfiles.mount_support_pair(
                id: assembled.element("supports").options.fetch("solid_profile"),
                left:,
                right:,
                detail_rows: [
                  { y: 54, inset_x: 76, height: 10 },
                  { y: 100, inset_x: 98, height: 8 },
                  { y: -100, inset_x: 98, height: 8 },
                  { y: -54, inset_x: 76, height: 10 }
                ],
                point_specs: [
                  { x: :center, y: :center, radius: 54, tone: :mid },
                  { x: 96, y: :center, radius: 22 },
                  { x: -96, y: :center, radius: 22 }
                ]
              )
            )
          end

          def build_vertical_zippe_groups(motor:, coffre:, fabric:, coulisse:, barre:)
            {
              "motorisation" => LayoutGroup.attached(id: "motorisation", boxes: [motor.tube, motor.head]),
              "toile-coulisses" => LayoutGroup.new(id: "toile-coulisses", boxes: [fabric.body, coulisse.left, coulisse.right]),
              "coffre-toile-barre" => LayoutGroup.new(id: "coffre-toile-barre", boxes: [coffre.body, fabric.body, barre.hit])
            }
          end

          def build_vertical_zippe_callouts(groups:)
            assembled.callouts.each_with_object({}) do |definition, callouts|
              callouts[definition.part_id] = callout_from_definition(definition, groups:)
            end
          end

          def callout_from_definition(definition, groups:)
            marker = if definition.part_id == "motorisation"
                       groups.fetch("motorisation").outside_anchor(side: :right, gap: 168)
                     else
                       definition.marker
                     end
            options = definition.options.transform_keys(&:to_sym)

            callout(
              definition.part_id,
              marker:,
              placement: definition.placement&.to_sym,
              route: options[:route]&.to_sym,
              anchor_side: options[:anchor_side]&.to_sym,
              label_side: options[:label_side]&.to_sym,
              first_length: options[:first_length],
              second_length: options[:second_length],
              text_offset_x: options[:text_offset_x],
              text_offset_y: options[:text_offset_y],
              text_anchor: options[:text_anchor],
              dominant_baseline: options[:dominant_baseline],
              animation_profile: options[:animation_profile]&.to_sym
            )
          end

          def required_box(element)
            element.box || raise(ArgumentError, "element #{element.id.inspect} needs a box")
          end

          def solid_profile_config(options)
            { id: options.fetch("solid_profile") }
          end

          def option_symbol(options, key, default: nil)
            value = options.fetch(key, default)
            value&.to_sym
          end

          def option_gap(options, key)
            value = options.fetch(key)
            value.is_a?(String) ? value.to_sym : value
          end

          def x_offsets(values)
            values.map { |value| value == "center" ? :center : value }
          end

          def thread_offsets(values)
            values.map { |value| value == "center" ? :center : value }
          end

          def symbol_list(values)
            values.map { |value| value.to_sym }
          end

          def canvas_spec
            @canvas_spec ||= CanvasSpec.new(
              columns: layout_config.fetch(:grid_columns),
              rows: layout_config.fetch(:grid_rows),
              cell: layout_config.fetch(:grid_cell, CanvasSpec::DEFAULT_CELL),
              margin: layout_config.fetch(:grid_margin, CanvasSpec::DEFAULT_MARGIN),
              major_every: layout_config.fetch(:grid_major_every, CanvasSpec::DEFAULT_MAJOR_EVERY),
              radius: layout_config.fetch(:grid_radius, CanvasSpec::DEFAULT_RADIUS),
              snap_unit: layout_config.fetch(:grid_snap_unit, CanvasSpec::DEFAULT_SNAP_UNIT)
            )
          end

          def layout_config
            blueprint.layout_config
          end

          def layout_grid
            canvas_spec.grid
          end

          def layout_box(box, preserve_size: false)
            canvas_spec.snap_box(box, preserve_size:)
          end

          def layout_size(value)
            canvas_spec.snap_length(value)
          end

          def layout_gap(value)
            layout_size(LayoutStandards.resolve_gap(value))
          end

          def layout_y(value)
            canvas_spec.snap_y(value)
          end

          def layout_point(point)
            canvas_spec.snap_point(point)
          end

          def layout_anchor(box, side:, gap:)
            layout_point(CalloutAnchor.outside(box, side:, gap:))
          end

          def part_definitions
            @part_definitions ||= blueprint.parts.each_with_object({}) do |part, definitions|
              definitions[part.id] = part
            end
          end

          def callout(
            part_id,
            marker:,
            first_length: nil,
            route: nil,
            anchor_side: nil,
            label_side: nil,
            placement: nil,
            start_direction: nil,
            turn_direction: nil,
            second_length: nil,
            text_offset_x: nil,
            text_offset_y: nil,
            text_anchor: nil,
            dominant_baseline: nil,
            marker_radius: nil,
            corner_radius: nil,
            dot_radius: nil,
            animation_profile: nil,
            label_reveal_direction: nil
          )
            callout_options = CalloutPlacement.preset_options(placement).merge(
              {
                route:,
                anchor_side:,
                label_side:,
                start_direction:,
                turn_direction:,
                first_length:,
                second_length:,
                text_offset_x:,
                text_offset_y:,
                text_anchor:,
                dominant_baseline:,
                marker_radius:,
                corner_radius:,
                dot_radius:,
                animation_profile:,
                label_reveal_direction:
              }.compact
            )
            resolved_first_length = CalloutMeasure.resolve(
              callout_options.fetch(:first_length) do
                raise ArgumentError, "Callout #{part_id.inspect} needs first_length or a placement preset"
              end
            )
            resolved_second_length = CalloutMeasure.resolve(callout_options.fetch(:second_length, 0))
            resolved_marker = layout_point(marker)
            route = callout_options[:route]
            anchor_side = callout_options[:anchor_side]
            label_side = callout_options[:label_side]
            route_options = if route
                              if route.to_sym == :auto
                                auto_callout_route(marker: resolved_marker, anchor_side:, label_side:, second_length: resolved_second_length)
                              else
                                CalloutRoute.resolve(route)
                              end
                            elsif placement&.to_sym == :auto || auto_callout_side?(anchor_side) || auto_callout_side?(label_side)
                              auto_callout_route(marker: resolved_marker, anchor_side:, label_side:, second_length: resolved_second_length)
                            elsif anchor_side
                              CalloutRoute.from_sides(anchor_side:, label_side: label_side || anchor_side)
                            else
                              {}
                            end
            direction_options = {
              start_direction: callout_options[:start_direction],
              turn_direction: callout_options[:turn_direction],
              text_offset_x: callout_options[:text_offset_x],
              text_offset_y: callout_options[:text_offset_y],
              text_anchor: callout_options[:text_anchor],
              dominant_baseline: callout_options[:dominant_baseline]
            }.compact

            CalloutLayout.new(
              label: part_definitions.fetch(part_id).label,
              marker: resolved_marker,
              first_length: resolved_first_length,
              second_length: resolved_second_length,
              marker_radius: callout_options.fetch(:marker_radius, 58),
              corner_radius: callout_options.fetch(:corner_radius, 46),
              dot_radius: callout_options.fetch(:dot_radius, 18),
              animation_profile: callout_options.fetch(:animation_profile, blueprint.callout_animation_profile),
              label_reveal_direction: callout_options.fetch(:label_reveal_direction, :left_to_right),
              **route_options.merge(direction_options)
            )
          end

          def auto_callout_route(marker:, anchor_side:, label_side:, second_length:)
            CalloutPlacement.resolve(
              marker:,
              frame: canvas_spec.frame,
              anchor_side:,
              label_side:,
              second_length:
            )
          end

          def auto_callout_side?(side)
            side&.to_sym == :auto
          end
        end
      end
    end
  end
end
