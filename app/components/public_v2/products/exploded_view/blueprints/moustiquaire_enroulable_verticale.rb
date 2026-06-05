# frozen_string_literal: true

require_relative "../geometry"
require_relative "../layouts"
require_relative "../schema"
require_relative "base"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class MoustiquaireEnroulableVerticale < Base
          TARGET_SLUGS = %w[moustiquaire-enroulable-verticale].freeze
          DEFAULT_PART_ORDER = %w[caisson double-coulisse toile-bordee barre-charge fermeture-magnetique bavettes].freeze

          TECHNICAL_DATA = {
            source: "Page LADS + Documentation publique AMB 2026",
            product_family: "KISS 50",
            reference_format: "L2000 x H2000 mm",
            reference_width_mm: 2000,
            reference_height_mm: 2000,
            cassette_hint_mm: "caisson compact 50/54 mm",
            movement: "Deplacement vertical",
            fabric: "Toile bouton / toile tendue",
            closure: "Fermeture magnetique",
            rails: "Double coulisse",
            anti_intrusion: "Bavettes anti-intrusion"
          }.freeze

          DEFAULT_LAYOUT = {
            svg_width: 7_800,
            svg_height: 4_250,
            marker_gap: 168,
            cassette_x: 980,
            cassette_y: 520,
            cassette_width: 5_840,
            cassette_height: 340,
            cassette_radius: 86,
            roll_inset_x: 440,
            roll_y_offset: 108,
            roll_height: 124,
            roll_radius: 54,
            gap_cassette_fabric: 500,
            fabric_x: 1_580,
            fabric_width: 4_640,
            fabric_height: 1_920,
            fabric_radius: 18,
            fabric_vertical_count: 59,
            fabric_horizontal_count: 25,
            rail_gap: 310,
            rail_width: 240,
            rail_extra_top: 180,
            rail_extra_bottom: 250,
            rail_radius: 42,
            bottom_bar_gap: 300,
            bottom_bar_height: 150,
            bottom_bar_radius: 34
          }.freeze

          DEFAULT_THEME = Theme.new(
            accent: "#00a8a0",
            accent_rgb: "0, 168, 160",
            accent_ink: "#ffffff"
          ).freeze

          PART_DEFINITIONS = [
            Part.new(
              id: "caisson",
              number: "1",
              label: "Caisson KISS 50",
              measurement: TECHNICAL_DATA.fetch(:cassette_hint_mm),
              detail: "Caisson haut arrondi avec axe d'enroulement interieur. Le dessin isole le volume principal et les reperes de fixation sans remplir la piece."
            ),
            Part.new(
              id: "double-coulisse",
              number: "2",
              label: "Double coulisse",
              measurement: TECHNICAL_DATA.fetch(:rails),
              detail: "Guidage vertical en deux profils lateraux, reconstruit en miroir pour verifier la symetrie et la lecture des tracks de toile."
            ),
            Part.new(
              id: "toile-bordee",
              number: "3",
              label: "Toile bordee",
              measurement: TECHNICAL_DATA.fetch(:fabric),
              detail: "Toile tendue a trame legere avec points de bordure. Le format POC reprend la limite documentaire #{TECHNICAL_DATA.fetch(:reference_format)}."
            ),
            Part.new(
              id: "barre-charge",
              number: "4",
              label: "Barre de charge",
              measurement: TECHNICAL_DATA.fetch(:movement),
              detail: "Barre basse de tirage direct, separee de la toile pour garder la lecture eclatee du mouvement vertical."
            ),
            Part.new(
              id: "fermeture-magnetique",
              number: "5",
              label: "Fermeture magnetique",
              measurement: TECHNICAL_DATA.fetch(:closure),
              detail: "Recepteurs magnetiques simplifies sous la barre basse pour montrer le verrouillage sans alourdir le plan principal."
            ),
            Part.new(
              id: "bavettes",
              number: "6",
              label: "Bavettes anti-intrusion",
              measurement: TECHNICAL_DATA.fetch(:anti_intrusion),
              detail: "Petites levres souples representees en bas des coulisses, pour tester un detail technique fin et recurrent sur les moustiquaires."
            )
          ].each_with_object({}) { |part, definitions| definitions[part.id] = part }.freeze

          METRICS = [
            Metric.new(label: "Format documente", value: TECHNICAL_DATA.fetch(:reference_format), note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Famille", value: TECHNICAL_DATA.fetch(:product_family), note: "moustiquaire enroulable verticale"),
            Metric.new(label: "Guidage", value: TECHNICAL_DATA.fetch(:rails), note: TECHNICAL_DATA.fetch(:anti_intrusion))
          ].freeze

          def render_for?(product_page)
            product = product_page.product

            TARGET_SLUGS.include?(product.slug.to_s) || product.name.to_s.match?(/moustiquaire.*enroulable.*vertical/i)
          end

          def eyebrow
            "POC technique · AMB KISS 50"
          end

          def introduction
            "Troisieme reconstruction front : une moustiquaire enroulable verticale KISS 50, avec caisson, double coulisse, toile bordee, barre basse, fermeture magnetique et bavettes anti-intrusion."
          end

          def svg_description
            "Vue technique vectorielle de la moustiquaire enroulable verticale AMB KISS 50 avec reperes numerotes interactifs."
          end

          def drawing_component
            PublicV2::Products::ExplodedView::MoustiquaireEnroulableVerticaleDrawingComponent
          end

          private

          def build_layout
            cassette = build_cassette_layout
            fabric = build_fabric_layout(cassette:)
            rails = build_rail_layout(fabric:)
            bottom_bar = build_bottom_bar_layout(fabric:)
            lock = build_lock_layout(bottom_bar:)
            bavettes = build_bavette_layout(rails:)
            callouts = build_callouts(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:)

            EnrollableDrawingLayout.new(
              svg_width: layout_config.fetch(:svg_width),
              svg_height: layout_config.fetch(:svg_height),
              cassette:,
              rails:,
              fabric:,
              bottom_bar:,
              lock:,
              bavettes:,
              callouts:
            )
          end

          def build_callouts(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:)
            {
              "caisson" => callout("caisson", marker: cassette.marker, start_direction: :up, turn_direction: :left, first_length: 230, second_length: 520),
              "double-coulisse" => callout("double-coulisse", marker: rails.marker, start_direction: :up, turn_direction: :right, first_length: 260, second_length: 460),
              "toile-bordee" => callout("toile-bordee", marker: fabric.marker, start_direction: :up, turn_direction: :right, first_length: 230, second_length: 430),
              "barre-charge" => callout("barre-charge", marker: bottom_bar.marker, start_direction: :down, turn_direction: :left, first_length: 160, second_length: 430),
              "fermeture-magnetique" => callout("fermeture-magnetique", marker: lock.marker, start_direction: :left, first_length: 460),
              "bavettes" => callout("bavettes", marker: bavettes.marker, start_direction: :left, first_length: 430)
            }
          end

          def build_cassette_layout
            body = Box.new(
              x: layout_config.fetch(:cassette_x),
              y: layout_config.fetch(:cassette_y),
              width: layout_config.fetch(:cassette_width),
              height: layout_config.fetch(:cassette_height),
              rx: layout_config.fetch(:cassette_radius)
            )
            roll = Box.new(
              x: body.x + layout_config.fetch(:roll_inset_x),
              y: body.y + layout_config.fetch(:roll_y_offset),
              width: body.width - (layout_config.fetch(:roll_inset_x) * 2),
              height: layout_config.fetch(:roll_height),
              rx: layout_config.fetch(:roll_radius)
            )

            EnrollableCassetteLayout.new(
              hit: Box.new(x: body.x - 100, y: body.y - 85, width: body.width + 200, height: body.height + 170),
              body:,
              roll:,
              marker: Point.new(x: body.right + layout_config.fetch(:marker_gap), y: body.center_y),
              screw_points: [
                Point.new(x: body.x + 690, y: body.center_y),
                Point.new(x: body.center_x, y: body.center_y),
                Point.new(x: body.right - 690, y: body.center_y)
              ]
            )
          end

          def build_fabric_layout(cassette:)
            body = Box.new(
              x: layout_config.fetch(:fabric_x),
              y: cassette.body.bottom + layout_config.fetch(:gap_cassette_fabric),
              width: layout_config.fetch(:fabric_width),
              height: layout_config.fetch(:fabric_height),
              rx: layout_config.fetch(:fabric_radius)
            )
            horizontal_step = body.height / (layout_config.fetch(:fabric_horizontal_count) - 1)
            vertical_lines = FabricGeometry.positions(
              start: body.x,
              finish: body.right,
              count: layout_config.fetch(:fabric_vertical_count),
              include_edges: false
            )
            horizontal_lines = FabricGeometry.positions(
              start: body.y,
              finish: body.bottom,
              count: layout_config.fetch(:fabric_horizontal_count),
              include_edges: false
            )
            edge_fastener_ys = [6, 10, 14, 18].map { |index| body.y + (index * horizontal_step) }

            EnrollableFabricLayout.new(
              hit: Box.new(x: body.x - 90, y: body.y - 75, width: body.width + 180, height: body.height + 150),
              body:,
              marker: Point.new(x: body.center_x, y: body.y - 170),
              vertical_lines:,
              horizontal_lines:,
              edge_fastener_ys:,
              edge_fastener_radius: 22
            )
          end

          def build_rail_layout(fabric:)
            top = fabric.body.y - layout_config.fetch(:rail_extra_top)
            height = fabric.body.height + layout_config.fetch(:rail_extra_top) + layout_config.fetch(:rail_extra_bottom)
            left = Box.new(
              x: fabric.body.x - layout_config.fetch(:rail_gap) - layout_config.fetch(:rail_width),
              y: top,
              width: layout_config.fetch(:rail_width),
              height:,
              rx: layout_config.fetch(:rail_radius)
            )
            right = Box.new(
              x: fabric.body.right + layout_config.fetch(:rail_gap),
              y: top,
              width: layout_config.fetch(:rail_width),
              height:,
              rx: layout_config.fetch(:rail_radius)
            )
            slot_step = height / 6

            EnrollableRailPairLayout.new(
              hit: Box.new(x: left.x - 80, y: left.y - 75, width: left.width + 160, height: left.height + 150),
              left:,
              right:,
              marker: Point.new(x: left.x - layout_config.fetch(:marker_gap), y: left.center_y),
              slot_ys: Array.new(5) { |index| left.y + slot_step + (index * slot_step) }
            )
          end

          def build_bottom_bar_layout(fabric:)
            body = Box.new(
              x: fabric.body.x - 130,
              y: fabric.body.bottom + layout_config.fetch(:bottom_bar_gap),
              width: fabric.body.width + 260,
              height: layout_config.fetch(:bottom_bar_height),
              rx: layout_config.fetch(:bottom_bar_radius)
            )
            grip = Box.new(x: body.center_x - 170, y: body.center_y - 30, width: 340, height: 60, rx: 18)

            EnrollableBottomBarLayout.new(
              hit: Box.new(x: body.x - 100, y: body.y - 80, width: body.width + 200, height: body.height + 160),
              body:,
              marker: Point.new(x: body.right + layout_config.fetch(:marker_gap), y: body.center_y),
              grip:,
              magnet_points: [
                Point.new(x: body.x + 610, y: body.center_y),
                Point.new(x: body.right - 610, y: body.center_y)
              ]
            )
          end

          def build_lock_layout(bottom_bar:)
            EnrollableLockLayout.new(
              hit: Box.new(x: bottom_bar.body.x + 360, y: bottom_bar.body.bottom - 40, width: bottom_bar.body.width - 720, height: 330),
              marker: Point.new(x: bottom_bar.body.center_x, y: bottom_bar.body.bottom + 285),
              receiver_points: bottom_bar.magnet_points.map { |point| Point.new(x: point.x, y: bottom_bar.body.bottom + 118) },
              radius: 42
            )
          end

          def build_bavette_layout(rails:)
            inset_width = 52
            inset_height = 142
            bottom_gap = 56
            left = Box.new(
              x: rails.left.center_x - (inset_width / 2),
              y: rails.left.bottom - bottom_gap - inset_height,
              width: inset_width,
              height: inset_height,
              rx: 18
            )
            right = Box.new(
              x: rails.right.center_x - (inset_width / 2),
              y: rails.right.bottom - bottom_gap - inset_height,
              width: inset_width,
              height: inset_height,
              rx: 18
            )

            EnrollableBavetteLayout.new(
              hit: Box.new(x: right.x - 70, y: right.y - 70, width: right.width + 140, height: right.height + 140),
              left:,
              right:,
              marker: Point.new(x: rails.right.right + layout_config.fetch(:marker_gap), y: right.center_y)
            )
          end
        end
      end
    end
  end
end
