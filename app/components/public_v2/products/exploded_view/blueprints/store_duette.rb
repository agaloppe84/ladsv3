# frozen_string_literal: true

require_relative "../geometry"
require_relative "../layouts"
require_relative "../schema"
require_relative "base"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class StoreDuette < Base
          TARGET_SLUGS = %w[store-duette].freeze
          DEFAULT_PART_ORDER = %w[rail-superieur toile-duette rail-intermediaire rail-bas cordons-guidage supports-pose].freeze

          TECHNICAL_DATA = {
            source: "Page LADS + documentation publique Luxaflex",
            manufacturer: "Luxaflex",
            product_family: "Store Duette",
            fabric_structure: "structure nid d'abeille",
            pleat_widths_mm: "25 / 32",
            operation: "LiteRise, SmartCord ou PowerView",
            colors: "231 coloris",
            reference_format: "2,40 x 2,20 m",
            pose: "Fixation haute"
          }.freeze

          DEFAULT_LAYOUT = {
            svg_width: 7_800,
            svg_height: 3_960,
            grid_columns: 64,
            grid_rows: 32,
            grid_cell: 120,
            grid_margin: 60,
            marker_gap: 168,
            top_rail_x: 1_020,
            top_rail_y: 540,
            top_rail_width: 5_760,
            top_rail_radius: 26,
            top_rail_preset: :rail_duette_head,
            gap_top_rail_fabric: :duette_rail_to_fabric,
            fabric_x: 1_380,
            fabric_preset: :fabric_honeycomb,
            fabric_cell_count: 12,
            fabric_cell_depth: 130,
            intermediate_offset_y: 660,
            intermediate_height: 120,
            bottom_rail_gap: :exploded_md,
            bottom_rail_height: 150,
            rail_preset: :bar_threshold,
            support_width: 280,
            support_height: 210,
            support_gap: 150,
            support_inset_x: 720,
            support_marker_gap: 90,
            cord_offset_x: 260,
            cord_top_gap: 180,
            cord_bottom_gap: 90
          }.freeze

          DEFAULT_THEME = Theme.new(
            accent: "#00a8a0",
            accent_rgb: "0, 168, 160",
            accent_ink: "#ffffff"
          ).freeze

          PART_DEFINITIONS = [
            Part.new(
              id: "rail-superieur",
              number: "1",
              label: "Rail superieur",
              measurement: TECHNICAL_DATA.fetch(:manufacturer),
              detail: "Rail haut de store Duette reconstruit comme un profil horizontal compact, avec points de fixation et lignes internes simplifiees."
            ),
            Part.new(
              id: "toile-duette",
              number: "2",
              label: "Toile Duette",
              measurement: TECHNICAL_DATA.fetch(:fabric_structure),
              detail: "Toile alvéolaire à cellules horizontales. Le dessin montre le principe nid d'abeille sans figer une coupe fabricant exhaustive."
            ),
            Part.new(
              id: "rail-intermediaire",
              number: "3",
              label: "Rail intermediaire",
              measurement: "Top down / bottom up",
              detail: "Profil mobile intermediaire place sur la toile pour représenter l'ouverture par le haut ou par le bas."
            ),
            Part.new(
              id: "rail-bas",
              number: "4",
              label: "Rail bas",
              measurement: "Barre de lestage",
              detail: "Profil bas separe du tablier pour garder la lecture eclatee du produit et tester une barre horizontale fine."
            ),
            Part.new(
              id: "cordons-guidage",
              number: "5",
              label: "Cordons de guidage",
              measurement: TECHNICAL_DATA.fetch(:operation),
              detail: "Cordons lateraux simplifies, alignes sur les rails pour visualiser le guidage sans surcharger la toile alvéolaire."
            ),
            Part.new(
              id: "supports-pose",
              number: "6",
              label: "Supports de pose",
              measurement: TECHNICAL_DATA.fetch(:pose),
              detail: "Supports hauts symetriques, isoles du rail pour montrer la logique de pose et enrichir la famille des petites platines."
            )
          ].each_with_object({}) { |part, definitions| definitions[part.id] = part }.freeze

          METRICS = [
            Metric.new(label: "Fabricant", value: TECHNICAL_DATA.fetch(:manufacturer), note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Plis documentes", value: "#{TECHNICAL_DATA.fetch(:pleat_widths_mm)} mm", note: TECHNICAL_DATA.fetch(:colors)),
            Metric.new(label: "Format POC", value: TECHNICAL_DATA.fetch(:reference_format), note: "reconstruction proportionnelle")
          ].freeze

          def render_for?(product_page)
            product = product_page.product

            TARGET_SLUGS.include?(product.slug.to_s) || product.name.to_s.match?(/store duette/i)
          end

          def eyebrow
            "POC technique · Luxaflex Duette"
          end

          def introduction
            "Cinquième reconstruction front : un store Duette alvéolaire, avec rail haut, toile nid d'abeille, rail intermédiaire, rail bas, cordons et supports de pose."
          end

          def svg_description
            "Vue technique vectorielle du store Duette Luxaflex avec repères numérotés interactifs."
          end

          def drawing_component
            PublicV2::Products::ExplodedView::StoreDuetteDrawingComponent
          end

          private

          def build_layout
            top_rail = build_top_rail_layout
            supports = build_support_layout(top_rail:)
            fabric = build_fabric_layout(top_rail:)
            intermediate_rail = build_intermediate_rail_layout(fabric:)
            bottom_rail = build_bottom_rail_layout(fabric:)
            cords = build_cord_layout(top_rail:, fabric:, intermediate_rail:, bottom_rail:)
            groups = build_groups(top_rail:, supports:, fabric:, intermediate_rail:, bottom_rail:, cords:)
            callouts = build_callouts(top_rail:, supports:, fabric:, intermediate_rail:, bottom_rail:, cords:)

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

          def build_callouts(top_rail:, supports:, fabric:, intermediate_rail:, bottom_rail:, cords:)
            {
              "rail-superieur" => callout("rail-superieur", marker: top_rail.marker, placement: :top_rail),
              "toile-duette" => callout("toile-duette", marker: fabric.marker, placement: :center_fabric, label_side: :right),
              "rail-intermediaire" => callout("rail-intermediaire", marker: intermediate_rail.marker, route: :right, first_length: 390),
              "rail-bas" => callout("rail-bas", marker: bottom_rail.marker, placement: :bottom_rail),
              "cordons-guidage" => callout("cordons-guidage", marker: cords.marker, placement: :left_detail, first_length: 380),
              "supports-pose" => callout("supports-pose", marker: supports.marker, route: :right, first_length: 360)
            }
          end

          def build_groups(top_rail:, supports:, fabric:, intermediate_rail:, bottom_rail:, cords:)
            {
              "tablier-duette" => LayoutGroup.new(id: "tablier-duette", boxes: [top_rail.body, fabric.body, intermediate_rail.body, bottom_rail.body]),
              "pose-haute" => LayoutGroup.new(id: "pose-haute", boxes: [top_rail.body, supports.left, supports.right]),
              "toile-rail-intermediaire" => LayoutGroup.attached(id: "toile-rail-intermediaire", boxes: [fabric.body, intermediate_rail.body]),
              "cordons-toile" => LayoutGroup.new(id: "cordons-toile", boxes: [cords.hit, fabric.body])
            }
          end

          def build_top_rail_layout
            horizontal_rail_element(
              preset: layout_config.fetch(:top_rail_preset),
              x: layout_config.fetch(:top_rail_x),
              y: layout_config.fetch(:top_rail_y),
              width: layout_config[:top_rail_width],
              height: layout_config[:top_rail_height],
              rx: layout_config[:top_rail_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 120,
              hit_inset_y: 95,
              screw_side_inset: 820,
              inner_inset_y: 64,
              solid_profile: {
                id: "duette-top-rail",
                cap_ratio: 0.29,
                point_radius: 24
              }
            )
          end

          def build_support_layout(top_rail:)
            width = layout_size(layout_config.fetch(:support_width))
            height = layout_size(layout_config.fetch(:support_height))
            y = top_rail.body.y - layout_gap(layout_config.fetch(:support_gap)) - height
            inset_x = layout_size(layout_config.fetch(:support_inset_x))
            left = layout_box(Box.new(x: top_rail.body.x + inset_x, y:, width:, height:, rx: 38))
            right = layout_box(Box.new(x: top_rail.body.right - inset_x - width, y:, width:, height:, rx: 38))
            hit = layout_box(LayoutRules.hit_box(Box.union([left, right]), inset_x: 80, inset_y: 80), preserve_size: true)

            MountSupportPair.new(
              hit:,
              left:,
              right:,
              marker: layout_anchor(right, side: :right, gap: layout_config.fetch(:support_marker_gap))
            )
          end

          def build_fabric_layout(top_rail:)
            fabric_element(
              variant: :honeycomb,
              reference: top_rail.body,
              preset: layout_config.fetch(:fabric_preset),
              gap: layout_config.fetch(:gap_top_rail_fabric),
              x: layout_config.fetch(:fabric_x),
              width: layout_config[:fabric_width],
              height: layout_config[:fabric_height],
              rx: layout_config[:fabric_radius],
              marker_gap: 175,
              hit_inset_x: 85,
              hit_inset_y: 85,
              cell_count: layout_config.fetch(:fabric_cell_count),
              cell_depth: layout_size(layout_config.fetch(:fabric_cell_depth)),
              thread_offsets: [390, :center, -390]
            )
          end

          def build_intermediate_rail_layout(fabric:)
            rail_width = fabric.body.width + 180
            body = layout_box(
              Box.new(
                x: fabric.body.x - 90,
                y: fabric.body.y + layout_size(layout_config.fetch(:intermediate_offset_y)),
                width: rail_width,
                height: layout_size(layout_config.fetch(:intermediate_height)),
                rx: 28
              )
            )

            BarElement.build(
              variant: :threshold,
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 100, inset_y: 80)),
              body:,
              marker: layout_anchor(body, side: :right, gap: layout_config.fetch(:marker_gap)),
              detail_inset_x: 230,
              tick_inset_x: 720,
              tick_inset_y: 24
            )
          end

          def build_bottom_rail_layout(fabric:)
            threshold_bar_element(
              reference: fabric.body,
              preset: layout_config.fetch(:rail_preset),
              gap: layout_config.fetch(:bottom_rail_gap),
              x: fabric.body.x - 140,
              width: fabric.body.width + 280,
              height: layout_config.fetch(:bottom_rail_height),
              rx: 32,
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 100,
              hit_inset_y: 80,
              detail_inset_x: 210,
              tick_inset_x: 620,
              tick_inset_y: 28
            )
          end

          def build_cord_layout(top_rail:, fabric:, intermediate_rail:, bottom_rail:)
            left_x = layout_point(Point.new(x: fabric.body.x + layout_config.fetch(:cord_offset_x), y: fabric.body.y)).x
            right_x = layout_point(Point.new(x: fabric.body.right - layout_config.fetch(:cord_offset_x), y: fabric.body.y)).x
            top_y = layout_y(top_rail.body.bottom + layout_config.fetch(:cord_top_gap))
            bottom_y = layout_y(bottom_rail.body.y - layout_config.fetch(:cord_bottom_gap))
            hit = layout_box(
              Box.new(
                x: left_x - 80,
                y: top_y - 80,
                width: right_x - left_x + 160,
                height: bottom_y - top_y + 160,
                rx: 0
              ),
              preserve_size: true
            )
            dot_ys = [
              fabric.body.y + 260,
              intermediate_rail.body.center_y,
              fabric.body.bottom - 260
            ].map { |y| layout_y(y) }

            DuetteCordPair.new(
              hit:,
              left_x:,
              right_x:,
              top_y:,
              bottom_y:,
              marker: layout_point(Point.new(x: left_x - layout_config.fetch(:marker_gap), y: fabric.body.center_y)),
              dot_ys:
            )
          end
        end
      end
    end
  end
end
