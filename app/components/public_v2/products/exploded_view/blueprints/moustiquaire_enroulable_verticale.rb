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
            svg_height: 4_320,
            grid_columns: 64,
            grid_rows: 35,
            grid_cell: 120,
            grid_margin: 60,
            marker_gap: 168,
            cassette_x: 980,
            cassette_y: 520,
            cassette_preset: :housing_kiss_50,
            roll_inset_x: 440,
            roll_y_offset: 108,
            roll_height: 124,
            roll_radius: 54,
            gap_cassette_fabric: :exploded_xl,
            fabric_x: 1_580,
            fabric_preset: :fabric_bordered,
            fabric_vertical_count: 59,
            fabric_horizontal_count: 25,
            rail_gap: :rail_to_fabric,
            rail_preset: :rail_double_coulisse,
            rail_extra_top: 180,
            rail_extra_bottom: 250,
            bottom_bar_gap: :exploded_md,
            bottom_bar_preset: :bar_bottom_charge
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
            groups = build_groups(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:)
            callouts = build_callouts(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:, groups:)

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

          def build_callouts(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:, groups:)
            {
              "caisson" => callout("caisson", marker: cassette.marker, placement: :top_housing),
              "double-coulisse" => callout("double-coulisse", marker: rails.marker, placement: :top_rail, label_side: :right, first_length: 260, second_length: 460),
              "toile-bordee" => callout("toile-bordee", marker: fabric.marker, placement: :center_fabric, label_side: :right),
              "barre-charge" => callout("barre-charge", marker: bottom_bar.marker, placement: :bottom_bar),
              "fermeture-magnetique" => callout("fermeture-magnetique", marker: lock.marker, placement: :left_detail, first_length: 460),
              "bavettes" => callout("bavettes", marker: bavettes.marker, placement: :left_detail)
            }
          end

          def build_groups(cassette:, rails:, fabric:, bottom_bar:, lock:, bavettes:)
            {
              "caisson-toile" => LayoutGroup.new(id: "caisson-toile", boxes: [cassette.body, fabric.body]),
              "toile-coulisses" => LayoutGroup.new(id: "toile-coulisses", boxes: [fabric.body, rails.left, rails.right]),
              "fermeture-barre" => LayoutGroup.attached(id: "fermeture-barre", boxes: [bottom_bar.body, lock.hit]),
              "coulisses-bavettes" => LayoutGroup.attached(id: "coulisses-bavettes", boxes: [rails.left, rails.right, bavettes.left, bavettes.right])
            }
          end

          def build_cassette_layout
            cassette_housing_element(
              preset: layout_config.fetch(:cassette_preset),
              x: layout_config.fetch(:cassette_x),
              y: layout_config.fetch(:cassette_y),
              width: layout_config[:cassette_width],
              height: layout_config[:cassette_height],
              rx: layout_config[:cassette_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 100,
              hit_inset_y: 85,
              roll_inset_x: layout_config.fetch(:roll_inset_x),
              roll_y_offset: layout_config.fetch(:roll_y_offset),
              roll_height: layout_config.fetch(:roll_height),
              roll_radius: layout_config.fetch(:roll_radius),
              screw_side_inset: 690
            )
          end

          def build_fabric_layout(cassette:)
            fabric_element(
              variant: :bordered_grid,
              reference: cassette.body,
              preset: layout_config.fetch(:fabric_preset),
              gap: layout_config.fetch(:gap_cassette_fabric),
              x: layout_config.fetch(:fabric_x),
              width: layout_config[:fabric_width],
              height: layout_config[:fabric_height],
              rx: layout_config[:fabric_radius],
              marker_gap: 170,
              hit_inset_x: 90,
              hit_inset_y: 75,
              vertical_count: layout_config.fetch(:fabric_vertical_count),
              horizontal_count: layout_config.fetch(:fabric_horizontal_count),
              edge_fastener_indexes: [6, 10, 14, 18],
              edge_fastener_radius: 22
            )
          end

          def build_rail_layout(fabric:)
            rail_preset = layout_config.fetch(:rail_preset)
            top = fabric.body.y - layout_gap(layout_config.fetch(:rail_extra_top))
            height = fabric.body.height + layout_gap(layout_config.fetch(:rail_extra_top)) + layout_gap(layout_config.fetch(:rail_extra_bottom))

            vertical_rail_pair_element(
              reference: fabric.body,
              preset: rail_preset,
              left_gap: layout_config.fetch(:rail_gap),
              right_gap: layout_config.fetch(:rail_gap),
              y: top,
              width: layout_config[:rail_width],
              height:,
              rx: layout_config[:rail_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 80,
              hit_inset_y: 75,
              slot_count: 5,
              inner_inset_x: 68
            )
          end

          def build_bottom_bar_layout(fabric:)
            bottom_bar_preset = layout_config.fetch(:bottom_bar_preset)

            bottom_bar_element(
              reference: fabric.body,
              preset: bottom_bar_preset,
              gap: layout_config.fetch(:bottom_bar_gap),
              x: fabric.body.x - 130,
              width: fabric.body.width + 260,
              height: layout_config[:bottom_bar_height],
              rx: layout_config[:bottom_bar_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 100,
              hit_inset_y: 80,
              grip_width: 340,
              grip_height: 60,
              grip_rx: 18,
              magnet_inset_x: 610
            )
          end

          def build_lock_layout(bottom_bar:)
            magnetic_receiver_element(
              bottom_bar:,
              hit_inset_x: 360,
              hit_y_offset: -40,
              hit_height: 330,
              marker_offset_y: 285,
              receiver_offset_y: 118,
              radius: 42
            )
          end

          def build_bavette_layout(rails:)
            rail_bavettes_element(
              rails:,
              marker_gap: layout_config.fetch(:marker_gap),
              width: 52,
              height: 142,
              bottom_gap: 56,
              rx: 18,
              hit_inset_x: 70,
              hit_inset_y: 70
            )
          end
        end
      end
    end
  end
end
