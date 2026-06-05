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
            svg_height: 4_620,
            drawing_right: 6_550,
            marker_gap: 168,
            motor_head_width: 320,
            motor_head_height: 248,
            motor_head_radius: 40,
            motor_tube_x: 4_400,
            motor_tube_height: 168,
            motor_tube_radius: 36,
            motor_tube_cap_width: 180,
            gap_motor_coffre: 420,
            coffre_x: 850,
            coffre_width: 6_100,
            coffre_height: 260,
            coffre_radius: 38,
            gap_coffre_fabric: 420,
            fabric_x: 1_250,
            fabric_width: 5_300,
            fabric_height: 2_048,
            fabric_radius: 22,
            fabric_line_count: 17,
            gap_fabric_barre: 282
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

            motor_head = Box.new(
              x: drawing_right - layout_config.fetch(:motor_head_width),
              y: 640,
              width: layout_config.fetch(:motor_head_width),
              height: layout_config.fetch(:motor_head_height),
              rx: layout_config.fetch(:motor_head_radius)
            )
            motor_tube = Box.new(
              x: layout_config.fetch(:motor_tube_x),
              y: motor_head.y + 40,
              width: motor_head.x - layout_config.fetch(:motor_tube_x),
              height: layout_config.fetch(:motor_tube_height),
              rx: layout_config.fetch(:motor_tube_radius)
            )
            motor = MotorLayout.new(
              hit: Box.new(x: 4_260, y: motor_head.y - 40, width: 2_580, height: 330),
              tube: motor_tube,
              tube_cap_width: layout_config.fetch(:motor_tube_cap_width),
              head: motor_head,
              marker: Point.new(x: drawing_right + marker_gap, y: motor_head.center_y)
            )

            coffre = build_coffre_layout(motor:)
            fabric = build_fabric_layout(coffre:)
            coulisse = build_coulisse_layout(fabric:)
            barre = build_barre_layout(fabric:)
            support_marker = Point.new(x: drawing_right + marker_gap, y: 305)
            callouts = build_callouts(support_marker:, motor:, coffre:, fabric:, coulisse:, barre:)

            DrawingLayout.new(
              svg_width: layout_config.fetch(:svg_width),
              svg_height: layout_config.fetch(:svg_height),
              support_marker:,
              motor:,
              coffre:,
              fabric:,
              coulisse:,
              barre:,
              callouts:
            )
          end

          def build_callouts(support_marker:, motor:, coffre:, fabric:, coulisse:, barre:)
            {
              "coffre" => callout("coffre", marker: coffre.marker, start_direction: :up, turn_direction: :right, first_length: 225, second_length: 390, text_offset_x: 76),
              "coulisses" => callout("coulisses", marker: coulisse.marker, start_direction: :left, turn_direction: :down, first_length: 285, second_length: 190),
              "toile" => callout("toile", marker: fabric.marker, start_direction: :up, turn_direction: :right, first_length: 265, second_length: 390, text_offset_x: 76),
              "barre-charge" => callout("barre-charge", marker: barre.marker, start_direction: :down, turn_direction: :left, first_length: 95, second_length: 500, text_offset_x: -72, text_anchor: "end"),
              "motorisation" => callout("motorisation", marker: motor.marker, start_direction: :up, turn_direction: :left, first_length: 230, second_length: 380, text_offset_x: -72, text_anchor: "end"),
              "supports" => callout("supports", marker: support_marker, start_direction: :up, turn_direction: :left, first_length: 180, second_length: 430, text_offset_x: -72, text_anchor: "end")
            }
          end

          def build_coffre_layout(motor:)
            body = Box.new(
              x: layout_config.fetch(:coffre_x),
              y: motor.head.bottom + layout_config.fetch(:gap_motor_coffre),
              width: layout_config.fetch(:coffre_width),
              height: layout_config.fetch(:coffre_height),
              rx: layout_config.fetch(:coffre_radius)
            )

            center_y = body.center_y
            left_holes = [Point.new(x: 1_338, y: center_y), Point.new(x: 1_562, y: center_y)]
            right_holes = [Point.new(x: 6_238, y: center_y), Point.new(x: 6_462, y: center_y)]

            CoffreLayout.new(
              hit: Box.new(x: 730, y: body.y - 75, width: 6_340, height: body.height + 150),
              body:,
              marker: Point.new(x: body.x - 160, y: center_y),
              hole_pairs: [left_holes, right_holes]
            )
          end

          def build_fabric_layout(coffre:)
            body = Box.new(
              x: layout_config.fetch(:fabric_x),
              y: coffre.body.bottom + layout_config.fetch(:gap_coffre_fabric),
              width: layout_config.fetch(:fabric_width),
              height: layout_config.fetch(:fabric_height),
              rx: layout_config.fetch(:fabric_radius)
            )
            line_ys = FabricGeometry.positions(
              start: body.y,
              finish: body.bottom,
              count: layout_config.fetch(:fabric_line_count)
            )

            FabricLayout.new(
              hit: Box.new(x: 1_165, y: body.y - 55, width: 5_470, height: body.height + 112),
              body:,
              marker: Point.new(x: body.center_x, y: body.y - 160),
              line_ys:,
              tick_ys: line_ys.values_at(0, 2, 4, 6, 8, 10, 12, 14, 16)
            )
          end

          def build_coulisse_layout(fabric:)
            top = fabric.body.y - 140
            bottom = fabric.body.bottom + 92

            CoulisseLayout.new(
              top:,
              bottom:,
              hit: Box.new(x: 470, y: top - 75, width: 300, height: (bottom - top) + 165),
              marker: Point.new(x: 410, y: top + ((bottom - top) / 2))
            )
          end

          def build_barre_layout(fabric:)
            top = fabric.body.bottom + layout_config.fetch(:gap_fabric_barre)

            BarreLayout.new(
              hit: Box.new(x: 1_035, y: top - 85, width: 5_740, height: 265),
              top:,
              height: 178,
              marker: Point.new(x: 6_900, y: top + 90)
            )
          end
        end
      end
    end
  end
end
