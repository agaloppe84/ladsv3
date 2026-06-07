# frozen_string_literal: true

require_relative "../geometry"
require_relative "../layouts"
require_relative "../schema"
require_relative "base"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class StoreVenitien < Base
          TARGET_SLUGS = %w[store-venitien].freeze
          DEFAULT_PART_ORDER = %w[boitier-haut lames-orientables cordons-echelles barre-finale commande supports-pose].freeze

          TECHNICAL_DATA = {
            source: "Page LADS + documentation publique Luxaflex",
            manufacturer: "Luxaflex",
            product_family: "Store venitien aluminium",
            reference_format: "2,40 x 2,20 m",
            reference_width_mm: 2400,
            reference_height_mm: 2200,
            slat_widths_mm: "25 / 50 / 70",
            movement: "Cordon, tige, chainette, LiteRise ou PowerView",
            finish_count: "70 coloris",
            pose: "Fixation haute"
          }.freeze

          DEFAULT_LAYOUT = {
            svg_width: 7_800,
            svg_height: 4_080,
            grid_columns: 64,
            grid_rows: 33,
            grid_cell: 120,
            grid_margin: 60,
            marker_gap: 168,
            headrail_x: 1_040,
            headrail_y: 500,
            headrail_preset: :rail_venetian_head,
            gap_headrail_slats: :headrail_to_slats,
            slats_x: 1_320,
            slats_preset: :slat_venetian_pack,
            slat_count: 14,
            slat_height: 80,
            slat_tilt: 50,
            ladder_offsets: [760, :center, -760],
            lift_cord_offsets: [1_300, -1_300],
            gap_slats_bottom_bar: :slats_to_bottom_bar,
            bottom_bar_preset: :bar_venetian_bottom,
            control_preset: :control_venetian_wand,
            control_gap: :exploded_lg,
            control_width: 64,
            control_radius: 26,
            support_width: 300,
            support_height: 210,
            support_gap: 150,
            support_inset_x: 710,
            support_marker_gap: 90
          }.freeze

          DEFAULT_THEME = Theme.new(
            accent: "#00a8a0",
            accent_rgb: "0, 168, 160",
            accent_ink: "#ffffff"
          ).freeze

          PART_DEFINITIONS = [
            Part.new(
              id: "boitier-haut",
              number: "1",
              label: "Boitier haut",
              measurement: TECHNICAL_DATA.fetch(:manufacturer),
              detail: "Rail superieur de store venitien, reconstruit en volume simple avec points de fixation et lecture longitudinale."
            ),
            Part.new(
              id: "lames-orientables",
              number: "2",
              label: "Lames orientables",
              measurement: "#{TECHNICAL_DATA.fetch(:slat_widths_mm)} mm",
              detail: "Pack de lames aluminium incline, distribue regulierement pour tester les elements repetitifs et les variations d'orientation."
            ),
            Part.new(
              id: "cordons-echelles",
              number: "3",
              label: "Cordons et echelles",
              measurement: "Inclinaison et levage",
              detail: "Cordons verticaux et echelles de maintien positionnes sur la grille des lames pour verifier la coherence du dessin technique."
            ),
            Part.new(
              id: "barre-finale",
              number: "4",
              label: "Barre finale",
              measurement: "Profil bas",
              detail: "Barre basse separee du tablier pour garder une lecture eclatee nette et reutiliser la famille de barres horizontales."
            ),
            Part.new(
              id: "commande",
              number: "5",
              label: "Commande",
              measurement: TECHNICAL_DATA.fetch(:movement),
              detail: "Tige et cordon dessines a droite du tablier pour representer une commande manuelle simple sans figer les options motorisees."
            ),
            Part.new(
              id: "supports-pose",
              number: "6",
              label: "Supports de pose",
              measurement: TECHNICAL_DATA.fetch(:pose),
              detail: "Supports hauts symetriques, isoles au-dessus du boitier pour expliciter la logique de pose sans surcharger le rail."
            )
          ].each_with_object({}) { |part, definitions| definitions[part.id] = part }.freeze

          METRICS = [
            Metric.new(label: "Fabricant", value: TECHNICAL_DATA.fetch(:manufacturer), note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Largeurs de lames", value: "#{TECHNICAL_DATA.fetch(:slat_widths_mm)} mm", note: TECHNICAL_DATA.fetch(:finish_count)),
            Metric.new(label: "Format POC", value: TECHNICAL_DATA.fetch(:reference_format), note: "reconstruction proportionnelle")
          ].freeze

          def render_for?(product_page)
            product = product_page.product

            TARGET_SLUGS.include?(product.slug.to_s) || product.name.to_s.match?(/\Astore v[ée]nitien\z/i)
          end

          def eyebrow
            "POC technique · Luxaflex vénitien"
          end

          def introduction
            "Quatrieme reconstruction front : un store venitien aluminium avec boitier haut, lames orientables, cordons, barre finale, commande et supports de pose."
          end

          def svg_description
            "Vue technique vectorielle du store venitien Luxaflex avec reperes numerotes interactifs."
          end

          def drawing_component
            PublicV2::Products::ExplodedView::StoreVenitienDrawingComponent
          end

          private

          def build_layout
            headrail = build_headrail_layout
            supports = build_support_layout(headrail:)
            slats = build_slats_layout(headrail:)
            bottom_bar = build_bottom_bar_layout(slats:)
            control = build_control_layout(slats:)
            groups = build_groups(headrail:, supports:, slats:, bottom_bar:, control:)
            callouts = build_callouts(headrail:, supports:, slats:, bottom_bar:, control:)

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

          def build_callouts(headrail:, supports:, slats:, bottom_bar:, control:)
            {
              "boitier-haut" => callout("boitier-haut", marker: headrail.marker, placement: :top_rail),
              "lames-orientables" => callout("lames-orientables", marker: slats.marker, placement: :side_fabric, first_length: 430),
              "cordons-echelles" => callout(
                "cordons-echelles",
                marker: layout_point(Point.new(x: slats.cord_xs.first - 170, y: slats.body.center_y)),
                placement: :left_detail,
                first_length: 360
              ),
              "barre-finale" => callout("barre-finale", marker: bottom_bar.marker, placement: :bottom_rail),
              "commande" => callout("commande", marker: control.marker, placement: :right_detail_up, first_length: 360),
              "supports-pose" => callout("supports-pose", marker: supports.marker, route: :right, first_length: 360)
            }
          end

          def build_groups(headrail:, supports:, slats:, bottom_bar:, control:)
            {
              "tablier-venitien" => LayoutGroup.new(id: "tablier-venitien", boxes: [headrail.body, slats.body, bottom_bar.body]),
              "pose-haute" => LayoutGroup.new(id: "pose-haute", boxes: [headrail.body, supports.left, supports.right]),
              "lames-cordons" => LayoutGroup.attached(id: "lames-cordons", boxes: [slats.body]),
              "commande-laterale" => LayoutGroup.new(id: "commande-laterale", boxes: [control.body])
            }
          end

          def build_headrail_layout
            horizontal_rail_element(
              preset: layout_config.fetch(:headrail_preset),
              x: layout_config.fetch(:headrail_x),
              y: layout_config.fetch(:headrail_y),
              width: layout_config[:headrail_width],
              height: layout_config[:headrail_height],
              rx: layout_config[:headrail_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 120,
              hit_inset_y: 95,
              screw_side_inset: 820,
              inner_inset_y: 64,
              solid_profile: {
                id: "venitien-boitier-haut",
                point_radius: 24
              }
            )
          end

          def build_support_layout(headrail:)
            mount_support_pair_element(
              reference: headrail.body,
              gap: layout_config.fetch(:support_gap),
              width: layout_config.fetch(:support_width),
              height: layout_config.fetch(:support_height),
              inset_x: layout_config.fetch(:support_inset_x),
              marker_gap: layout_config.fetch(:support_marker_gap),
              pair_class: VenetianSupportPair,
              solid_profile: {
                id: "venitien-supports-pose",
                point_inset: 96,
                detail_inset_x: 40,
                detail_inset_y: 62
              }
            )
          end

          def build_slats_layout(headrail:)
            slats = venetian_slat_pack_element(
              reference: headrail.body,
              preset: layout_config.fetch(:slats_preset),
              gap: layout_config.fetch(:gap_headrail_slats),
              x: layout_config.fetch(:slats_x),
              width: layout_config[:slats_width],
              height: layout_config[:slats_height],
              rx: layout_config[:slats_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 95,
              hit_inset_y: 95,
              slat_count: layout_config.fetch(:slat_count),
              slat_height: layout_config.fetch(:slat_height),
              tilt: layout_config.fetch(:slat_tilt),
              ladder_offsets: layout_config.fetch(:ladder_offsets),
              lift_cord_offsets: layout_config.fetch(:lift_cord_offsets)
            )

            slats = slats.with_slat_pattern(
              SlatPatterns.venetian_pack(
                id: "venitien-lames-orientables",
                slats:
              )
            )

            slats.with_cord_solid_profile(
              SolidProfiles.control_segments(
                id: "venitien-cordons-echelles",
                variant: :venetian_ladder_cords,
                segment_boxes: slats.cord_segment_boxes(segment_width: 12),
                points: slats.cord_points,
                point_radius: 17
              )
            )
          end

          def build_bottom_bar_layout(slats:)
            threshold_bar_element(
              reference: slats.body,
              preset: layout_config.fetch(:bottom_bar_preset),
              gap: layout_config.fetch(:gap_slats_bottom_bar),
              x: slats.body.x,
              width: slats.body.width,
              height: layout_config[:bottom_bar_height],
              rx: layout_config[:bottom_bar_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 100,
              hit_inset_y: 90,
              detail_inset_x: 180,
              tick_inset_x: 690,
              tick_inset_y: 28,
              solid_profile: {
                id: "venitien-barre-finale",
                detail: {
                  height: 8,
                  inset_x: 180
                }
              }
            )
          end

          def build_control_layout(slats:)
            control = venetian_control_element(
              reference: slats.body,
              preset: layout_config.fetch(:control_preset),
              gap: layout_config.fetch(:control_gap),
              y: slats.slat_top,
              width: layout_config[:control_width],
              height: slats.slat_bottom - slats.slat_top,
              rx: layout_config[:control_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 90,
              hit_inset_y: 90,
              cord_offset_x: 210,
              cord_top_offset_y: 20,
              cord_bottom_offset_y: -20,
              bead_count: 11
            )

            control.with_solid_profile(
              SolidProfiles.wand_control(
                id: "venitien-commande",
                body: control.body,
                cord_x: control.cord_top.x,
                top: control.cord_top.y,
                bottom: control.cord_bottom.y,
                bead_ys: control.bead_points.map(&:y),
                segment_width: 12,
                bead_radius: 20
              )
            )
          end

        end
      end
    end
  end
end
