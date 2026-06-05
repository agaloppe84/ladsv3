# frozen_string_literal: true

require_relative "../geometry"
require_relative "../layouts"
require_relative "../schema"
require_relative "base"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class StoreVerticalZippe < Base
          TARGET_SLUGS = %w[store-vertical-zippe store-vertical].freeze
          DEFAULT_PART_ORDER = %w[coffre coulisses toile barre-charge motorisation supports].freeze

          TECHNICAL_DATA = {
            source: "Fiche ADS + PDF Coublanc Espalis",
            width_range: "0,84 a 6 m",
            max_surface: "15 m2",
            reference_format: "6 x 2,50 m",
            reference_width_mm: 6000,
            reference_height_mm: 2500,
            coffre_profile_mm: "123 x 171",
            coulisse_profile_mm: "52 x 41",
            barre_charge_profile_mm: "114"
          }.freeze

          DEFAULT_LAYOUT = {
            svg_width: 7_800,
            svg_height: 4_680,
            grid_columns: 64,
            grid_rows: 38,
            grid_cell: 120,
            grid_margin: 60,
            drawing_right: 6_550,
            marker_gap: 168,
            motor_head_preset: :motor_tubular_head,
            motor_tube_x: 4_400,
            motor_tube_preset: :motor_tubular_tube,
            motor_tube_cap_width: 180,
            gap_motor_coffre: :exploded_lg,
            coffre_x: 850,
            coffre_preset: :housing_zipped_coffre,
            gap_coffre_fabric: :exploded_lg,
            fabric_x: 1_250,
            fabric_preset: :fabric_zipped,
            fabric_line_count: 17,
            gap_fabric_barre: :fabric_to_load_bar,
            barre_preset: :bar_zipped_load
          }.freeze

          DEFAULT_THEME = Theme.new(
            accent: "#009e96",
            accent_rgb: "0, 158, 150",
            accent_ink: "#ffffff"
          ).freeze

          PART_DEFINITIONS = [
	            Part.new(
	              id: "coffre",
	              number: "1",
              label: "Coffre extrude",
              measurement: "#{TECHNICAL_DATA.fetch(:coffre_profile_mm)} mm",
              detail: "Profil haut compact reconstruit depuis la coupe cotee du PDF Espalis, avec enveloppe, levres de facade et reperes d'embouts."
            ),
	            Part.new(
	              id: "coulisses",
	              number: "2",
              label: "Coulisses laterales",
              measurement: "#{TECHNICAL_DATA.fetch(:coulisse_profile_mm)} mm",
              detail: "Guidage vertical du zip textile. Les deux coulisses partagent le meme etat de surbrillance pour garder la lecture symetrique."
            ),
	            Part.new(
	              id: "toile",
	              number: "3",
              label: "Toile zippee",
              measurement: "PVC micro-perfore ou plein",
              detail: "Surface tendue entre les coulisses. Le format de reference utilise #{TECHNICAL_DATA.fetch(:reference_format)} pour rester coherent avec les #{TECHNICAL_DATA.fetch(:max_surface)} maximum."
            ),
	            Part.new(
	              id: "barre-charge",
	              number: "4",
              label: "Barre de charge",
              measurement: "Profil #{TECHNICAL_DATA.fetch(:barre_charge_profile_mm)} mm",
              detail: "Profil bas qui stabilise la toile et ferme la descente. La cote est reprise comme repere de profil dans le dessin."
            ),
	            Part.new(
	              id: "motorisation",
	              number: "5",
              label: "Motorisation",
              measurement: "Somfy selon configuration",
              detail: "Moteur tubulaire isole en vue eclatee au-dessus du coffre, avec tete moteur et axe d'enroulement separes pour clarifier l'assemblage."
            ),
	            Part.new(
	              id: "supports",
	              number: "6",
              label: "Supports et pose",
              measurement: "Fixation facade",
              detail: "Platines de fixation placees hors du coffre pour montrer la logique de pose et les points d'ancrage principaux."
            )
          ].each_with_object({}) { |part, definitions| definitions[part.id] = part }.freeze

          METRICS = [
            Metric.new(label: "Largeur documentee", value: TECHNICAL_DATA.fetch(:width_range), note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Surface maximale", value: TECHNICAL_DATA.fetch(:max_surface), note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Format POC", value: TECHNICAL_DATA.fetch(:reference_format), note: "reconstruction proportionnelle #{TECHNICAL_DATA.fetch(:max_surface)}")
          ].freeze

          def render_for?(product_page)
            product = product_page.product

            TARGET_SLUGS.include?(product.slug.to_s) || product.name.to_s.match?(/store vertical(?: zipp)?/i)
          end

          def eyebrow
            "POC technique · Coublanc Espalis"
          end

          def introduction
            "Reconstruction front à partir des cotes documentées : un format de référence 6 000 x 2 500 mm, des profils dessinés à l'échelle, et une lecture filaire qui sépare les pièces sans brouiller le plan technique."
          end

          def svg_description
            "Vue technique vectorielle du store vertical zippé Espalis avec repères numérotés interactifs."
          end

          def drawing_component
            PublicV2::Products::ExplodedView::StoreVerticalZippeDrawingComponent
          end

          private

          def build_layout
            drawing_right = layout_config.fetch(:drawing_right)
            marker_gap = layout_config.fetch(:marker_gap)

            motor = tubular_motor_element(
              drawing_right:,
              y: 640,
              head_preset: layout_config.fetch(:motor_head_preset),
              tube_preset: layout_config.fetch(:motor_tube_preset),
              tube_x: layout_config.fetch(:motor_tube_x),
              tube_cap_width: layout_config.fetch(:motor_tube_cap_width),
              marker_gap:,
              hit_x: 4_260,
              hit_y_offset: -40,
              hit_width: 2_580,
              hit_height: 330,
              tube_y_offset: 40,
              head_width: layout_config[:motor_head_width],
              head_height: layout_config[:motor_head_height],
              head_rx: layout_config[:motor_head_radius],
              tube_height: layout_config[:motor_tube_height],
              tube_rx: layout_config[:motor_tube_radius]
            )

            coffre = build_coffre_layout(motor:)
            fabric = build_fabric_layout(coffre:)
            coulisse = build_coulisse_layout(fabric:)
            barre = build_barre_layout(fabric:)
            support_marker = layout_point(Point.new(x: drawing_right + marker_gap, y: 305))
            groups = build_groups(motor:, coffre:, fabric:, coulisse:, barre:)
            callouts = build_callouts(support_marker:, motor:, coffre:, fabric:, coulisse:, barre:, groups:)

            DrawingLayout.new(
              svg_width: canvas_spec.svg_width,
              svg_height: canvas_spec.svg_height,
              grid: layout_grid,
              groups:,
              support_marker:,
              motor:,
              coffre:,
              fabric:,
              coulisse:,
              barre:,
              callouts:
            )
          end

          def build_callouts(support_marker:, motor:, coffre:, fabric:, coulisse:, barre:, groups:)
            {
              "coffre" => callout("coffre", marker: coffre.marker, placement: :top_housing, label_side: :right, first_length: 225, second_length: 390, text_offset_x: 76),
              "coulisses" => callout("coulisses", marker: coulisse.marker, placement: :left_vertical_pair, first_length: 285, second_length: 190),
              "toile" => callout("toile", marker: fabric.marker, placement: :center_fabric, label_side: :right, first_length: 265, second_length: 390, text_offset_x: 76),
              "barre-charge" => callout("barre-charge", marker: barre.marker, placement: :bottom_bar, first_length: 95, second_length: 500, text_offset_x: -72, text_anchor: "end"),
              "motorisation" => callout("motorisation", marker: groups.fetch("motorisation").outside_anchor(side: :right, gap: layout_config.fetch(:marker_gap)), placement: :top_housing, second_length: 380, text_offset_x: -72, text_anchor: "end"),
              "supports" => callout("supports", marker: support_marker, placement: :top_rail, first_length: 180, text_offset_x: -72, text_anchor: "end")
            }
          end

          def build_groups(motor:, coffre:, fabric:, coulisse:, barre:)
            right_coulisse_hit = LayoutRules.mirror_x(coulisse.hit, canvas_width: canvas_spec.svg_width)

            {
              "motorisation" => LayoutGroup.attached(id: "motorisation", boxes: [motor.tube, motor.head]),
              "toile-coulisses" => LayoutGroup.new(id: "toile-coulisses", boxes: [fabric.body, coulisse.hit, right_coulisse_hit]),
              "coffre-toile-barre" => LayoutGroup.new(id: "coffre-toile-barre", boxes: [coffre.body, fabric.body, barre.hit])
            }
          end

          def build_coffre_layout(motor:)
            zipped_coffre_element(
              reference: motor.head,
              preset: layout_config.fetch(:coffre_preset),
              gap: layout_config.fetch(:gap_motor_coffre),
              x: layout_config.fetch(:coffre_x),
              width: layout_config[:coffre_width],
              height: layout_config[:coffre_height],
              rx: layout_config[:coffre_radius],
              marker_gap: 160,
              hit_inset_x: 120,
              hit_inset_y: 75,
              hole_offsets: [488, 712]
            )
          end

          def build_fabric_layout(coffre:)
            fabric_element(
              variant: :zipped,
              reference: coffre.body,
              preset: layout_config.fetch(:fabric_preset),
              gap: layout_config.fetch(:gap_coffre_fabric),
              x: layout_config.fetch(:fabric_x),
              width: layout_config[:fabric_width],
              height: layout_config[:fabric_height],
              rx: layout_config[:fabric_radius],
              marker_gap: 160,
              hit_inset_x: 85,
              hit_inset_y: 55,
              line_count: layout_config.fetch(:fabric_line_count),
              tick_step: 2
            )
          end

          def build_coulisse_layout(fabric:)
            top = fabric.body.y - 140
            bottom = layout_y(fabric.body.bottom + layout_gap(92))

            zipped_coulisse_element(
              top:,
              bottom:,
              hit: Box.new(x: 470, y: top - 75, width: 300, height: (bottom - top) + 165),
              marker: Point.new(x: 410, y: top + ((bottom - top) / 2))
            )
          end

          def build_barre_layout(fabric:)
            top = layout_y(fabric.body.bottom + layout_gap(layout_config.fetch(:gap_fabric_barre)))

            zipped_load_bar_element(
              top:,
              preset: layout_config.fetch(:barre_preset),
              hit: Box.new(x: 1_035, y: top - 85, width: 5_740, height: 265),
              height: layout_config[:barre_height],
              marker: Point.new(x: 6_900, y: top + 90)
            )
          end
        end
      end
    end
  end
end
