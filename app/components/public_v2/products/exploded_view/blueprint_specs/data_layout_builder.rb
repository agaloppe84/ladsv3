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
            when "store-vertical-zippe"
              build_store_vertical_zippe
            else
              raise NotImplementedError, "No data layout builder for #{blueprint.spec.product_slug.inspect}"
            end
          end

          private

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
