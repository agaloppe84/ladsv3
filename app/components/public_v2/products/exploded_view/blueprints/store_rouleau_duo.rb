# frozen_string_literal: true

require_relative "../geometry"
require_relative "../layouts"
require_relative "../schema"
require_relative "base"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class StoreRouleauDuo < Base
          TARGET_SLUGS = %w[store-rouleau-duo].freeze
          DEFAULT_PART_ORDER = %w[rail-superieur tube-enroulement toile-duo barre-charge commande supports-pose].freeze

          TECHNICAL_DATA = {
            source: "Page LADS prod + documentation publique Luxaflex",
            manufacturer: "Luxaflex",
            product_family: "Store rouleau duo",
            fabric_structure: "double panneau transparent / opaque",
            width_range_mm: "270 a 2750",
            height_range_mm: "400 a 2600",
            band_width_mm: 75,
            operation: "Chainette, cordon sans fin ou PowerView",
            colors: "120 coloris",
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
            headrail_x: 1_020,
            headrail_y: 540,
            headrail_width: 5_760,
            headrail_height: 240,
            headrail_radius: 34,
            headrail_preset: :rail_horizontal_guide,
            roll_gap: :exploded_md,
            roll_x: 1_260,
            roll_width: 5_280,
            roll_height: 170,
            roll_radius: 48,
            gap_roll_fabric: :exploded_sm,
            fabric_x: 1_380,
            fabric_preset: :fabric_duo,
            fabric_band_count: 12,
            fabric_opaque_ratio: 0.52,
            fabric_layer_offset: 0.5,
            bottom_bar_gap: :exploded_md,
            bottom_bar_height: 120,
            bottom_bar_radius: 30,
            bottom_bar_preset: :bar_threshold,
            control_gap: :exploded_md,
            control_width: 110,
            control_radius: 40,
            control_bead_count: 14,
            support_width: 280,
            support_height: 210,
            support_gap: 150,
            support_inset_x: 720,
            support_marker_gap: 90
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
              detail: "Profil haut plein, aligne sur la grille de fond et reconstruit dans la famille des rails horizontaux parametriques."
            ),
            Part.new(
              id: "tube-enroulement",
              number: "2",
              label: "Tube d'enroulement",
              measurement: TECHNICAL_DATA.fetch(:operation),
              detail: "Tube horizontal separe du rail haut pour montrer la logique du store rouleau et preparer les variantes motorisees."
            ),
            Part.new(
              id: "toile-duo",
              number: "3",
              label: "Toile duo",
              measurement: "#{TECHNICAL_DATA.fetch(:band_width_mm)} mm par bande",
              detail: "Toile a deux couches avec bandes transparentes et opaques alternees. Le POC met l'accent sur le rythme de bandes et le decalage de couche."
            ),
            Part.new(
              id: "barre-charge",
              number: "4",
              label: "Barre de charge",
              measurement: "Profil bas",
              detail: "Barre basse simple en mode plein, separee de la toile pour garder une lecture eclatee du store."
            ),
            Part.new(
              id: "commande",
              number: "5",
              label: "Commande",
              measurement: TECHNICAL_DATA.fetch(:operation),
              detail: "Commande laterale a chainette, positionnee a droite du tablier pour representer le reglage des deux couches de tissu."
            ),
            Part.new(
              id: "supports-pose",
              number: "6",
              label: "Supports de pose",
              measurement: TECHNICAL_DATA.fetch(:pose),
              detail: "Supports hauts symetriques, isoles du rail pour garder le dessin lisible et modulaire."
            )
          ].each_with_object({}) { |part, definitions| definitions[part.id] = part }.freeze

          METRICS = [
            Metric.new(label: "Fabricant", value: TECHNICAL_DATA.fetch(:manufacturer), note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Dimensions", value: "#{TECHNICAL_DATA.fetch(:width_range_mm)} mm", note: "hauteur #{TECHNICAL_DATA.fetch(:height_range_mm)} mm"),
            Metric.new(label: "Bandes", value: "#{TECHNICAL_DATA.fetch(:band_width_mm)} mm", note: TECHNICAL_DATA.fetch(:fabric_structure))
          ].freeze

          def render_for?(product_page)
            product = product_page.product

            TARGET_SLUGS.include?(product.slug.to_s) || product.name.to_s.match?(/store rouleau duo/i)
          end

          def eyebrow
            "POC technique - Luxaflex Duo"
          end

          def introduction
            "Nouvelle reconstruction front : un store rouleau duo avec rail haut, tube d'enroulement, toile a bandes alternees, barre de charge, commande et supports de pose."
          end

          def svg_description
            "Vue technique vectorielle du store rouleau duo Luxaflex avec reperes numerotes interactifs."
          end

          def drawing_component
            PublicV2::Products::ExplodedView::StoreRouleauDuoDrawingComponent
          end

          private

          def build_layout
            headrail = build_headrail_layout
            supports = build_support_layout(headrail:)
            roll = build_roll_layout(headrail:)
            fabric = build_fabric_layout(roll:)
            bottom_bar = build_bottom_bar_layout(fabric:)
            control = build_control_layout(fabric:)
            groups = build_groups(headrail:, supports:, roll:, fabric:, bottom_bar:, control:)
            callouts = build_callouts(headrail:, supports:, roll:, fabric:, bottom_bar:, control:)

            DuoDrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              headrail:,
              roll:,
              fabric:,
              bottom_bar:,
              control:,
              supports:,
              callouts:
            )
          end

          def build_callouts(headrail:, supports:, roll:, fabric:, bottom_bar:, control:)
            {
              "rail-superieur" => callout("rail-superieur", marker: headrail.marker, placement: :top_rail),
              "tube-enroulement" => callout("tube-enroulement", marker: roll.marker, placement: :top_rail, first_length: 220, second_length: 380),
              "toile-duo" => callout("toile-duo", marker: fabric.marker, placement: :center_fabric, label_side: :right),
              "barre-charge" => callout("barre-charge", marker: bottom_bar.marker, placement: :bottom_bar),
              "commande" => callout("commande", marker: control.marker, placement: :right_detail_up, first_length: 340),
              "supports-pose" => callout("supports-pose", marker: supports.marker, route: :right, first_length: 360)
            }
          end

          def build_groups(headrail:, supports:, roll:, fabric:, bottom_bar:, control:)
            {
              "mecanisme-haut" => LayoutGroup.new(id: "mecanisme-haut", boxes: [headrail.body, roll.body, supports.left, supports.right]),
              "tablier-duo" => LayoutGroup.new(id: "tablier-duo", boxes: [roll.body, fabric.body, bottom_bar.body]),
              "commande-laterale" => LayoutGroup.new(id: "commande-laterale", boxes: [control.body]),
              "toile-barre" => LayoutGroup.attached(id: "toile-barre", boxes: [fabric.body, bottom_bar.body])
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
              solid_profile: {
                id: "duo-rail-superieur",
                point_radius: 20
              }
            )
          end

          def build_support_layout(headrail:)
            width = layout_size(layout_config.fetch(:support_width))
            height = layout_size(layout_config.fetch(:support_height))
            y = headrail.body.y - layout_gap(layout_config.fetch(:support_gap)) - height
            inset_x = layout_size(layout_config.fetch(:support_inset_x))
            left = layout_box(Box.new(x: headrail.body.x + inset_x, y:, width:, height:, rx: 38))
            right = layout_box(Box.new(x: headrail.body.right - inset_x - width, y:, width:, height:, rx: 38))
            hit = layout_box(LayoutRules.hit_box(Box.union([left, right]), inset_x: 80, inset_y: 80), preserve_size: true)

            MountSupportPair.new(
              hit:,
              left:,
              right:,
              marker: layout_anchor(right, side: :right, gap: layout_config.fetch(:support_marker_gap))
            )
          end

          def build_roll_layout(headrail:)
            body = layout_box(
              LayoutRules.below(
                headrail.body,
                gap: layout_gap(layout_config.fetch(:roll_gap)),
                x: layout_config.fetch(:roll_x),
                width: layout_size(layout_config.fetch(:roll_width)),
                height: layout_size(layout_config.fetch(:roll_height)),
                rx: layout_config.fetch(:roll_radius)
              )
            )

            DuoRollElement.new(
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 100, inset_y: 90)),
              body:,
              marker: layout_anchor(body, side: :right, gap: layout_config.fetch(:marker_gap))
            )
          end

          def build_fabric_layout(roll:)
            fabric_element(
              variant: :duo_bands,
              reference: roll.body,
              preset: layout_config.fetch(:fabric_preset),
              gap: layout_config.fetch(:gap_roll_fabric),
              x: layout_config.fetch(:fabric_x),
              width: layout_config[:fabric_width],
              height: layout_config[:fabric_height],
              rx: layout_config[:fabric_radius],
              marker_gap: 175,
              hit_inset_x: 90,
              hit_inset_y: 85,
              band_count: layout_config.fetch(:fabric_band_count),
              opaque_ratio: layout_config.fetch(:fabric_opaque_ratio),
              layer_offset: layout_config.fetch(:fabric_layer_offset),
              pattern_id: "duo-toile",
              pattern_style: :solid
            )
          end

          def build_bottom_bar_layout(fabric:)
            threshold_bar_element(
              reference: fabric.body,
              preset: layout_config.fetch(:bottom_bar_preset),
              gap: layout_config.fetch(:bottom_bar_gap),
              x: fabric.body.x - 120,
              width: fabric.body.width + 240,
              height: layout_config.fetch(:bottom_bar_height),
              rx: layout_config.fetch(:bottom_bar_radius),
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 100,
              hit_inset_y: 80,
              detail_inset_x: 220,
              tick_inset_x: 620,
              tick_inset_y: 28,
              solid_profile: {
                id: "duo-barre-charge",
                detail: {
                  height: 8,
                  inset_x: 260
                }
              }
            )
          end

          def build_control_layout(fabric:)
            body = layout_box(
              LayoutRules.right_of(
                fabric.body,
                gap: layout_gap(layout_config.fetch(:control_gap)),
                y: fabric.body.y,
                width: layout_size(layout_config.fetch(:control_width)),
                height: fabric.body.height,
                rx: layout_config.fetch(:control_radius)
              )
            )

            ControlElement.build(
              variant: :venetian_wand,
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 95, inset_y: 75)),
              body:,
              marker: layout_anchor(body, side: :right, gap: layout_config.fetch(:marker_gap)),
              cord_top: layout_point(Point.new(x: body.center_x, y: body.y + 90)),
              cord_bottom: layout_point(Point.new(x: body.center_x, y: body.bottom - 90)),
              bead_count: layout_config.fetch(:control_bead_count)
            )
          end
        end
      end
    end
  end
end
