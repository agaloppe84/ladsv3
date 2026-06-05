# frozen_string_literal: true

require_relative "../geometry"
require_relative "../layouts"
require_relative "../schema"
require_relative "base"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class MoustiquairePlissee < Base
          TARGET_SLUGS = %w[moustiquaire-plissee].freeze
          DEFAULT_PART_ORDER = %w[guide-haut profils-muraux toile-plissee barre-poignee seuil-bas verrouillage].freeze

          TECHNICAL_DATA = {
            source: "PDF AMB PLISSE31_PLISSE22 + documentation publique AMB",
            product_family: "PLISSE 31 laterale",
            depth_mm: 31,
            reference_format: "5 x 3 m",
            reference_width_mm: 5000,
            reference_height_mm: 3000,
            threshold_height_mm: 7,
            profile_hint_mm: "31 x 37",
            movement: "Tirage direct"
          }.freeze

          DEFAULT_LAYOUT = {
            svg_width: 7_800,
            svg_height: 3_720,
            grid_columns: 64,
            grid_rows: 30,
            grid_cell: 120,
            grid_margin: 60,
            marker_gap: 165,
            guide_x: 1_080,
            guide_y: 470,
            guide_width: 5_640,
            guide_height: 260,
            guide_radius: 42,
            gap_guide_fabric: 520,
            fabric_x: 1_420,
            fabric_width: 4_050,
            fabric_height: 1_540,
            fabric_radius: 18,
            pleat_count: 31,
            profile_gap: 470,
            profile_width: 190,
            profile_radius: 34,
            handle_gap: 340,
            handle_width: 300,
            handle_radius: 42,
            threshold_gap: 300,
            threshold_height: 105,
            threshold_radius: 26
          }.freeze

          DEFAULT_THEME = Theme.new(
            accent: "#00a8a0",
            accent_rgb: "0, 168, 160",
            accent_ink: "#ffffff"
          ).freeze

          PART_DEFINITIONS = [
	            Part.new(
	              id: "guide-haut",
	              number: "1",
	              label: "Guide superieur",
              measurement: "Encombrement #{TECHNICAL_DATA.fetch(:depth_mm)} mm",
              detail: "Rail haut reconstruit depuis la fiche AMB PLISSE 31. Il porte la lecture du coulissement et reste separe de la toile pour conserver l'effet eclate."
            ),
	            Part.new(
	              id: "profils-muraux",
	              number: "2",
              label: "Profils muraux",
              measurement: "#{TECHNICAL_DATA.fetch(:profile_hint_mm)} mm",
              detail: "Profils verticaux lateraux avec points de fixation homogenes. Les deux cotes utilisent le meme dessin pour verifier la logique de miroir."
            ),
	            Part.new(
	              id: "toile-plissee",
	              number: "3",
              label: "Toile plissee",
              measurement: "Toile polyester grise ou noire",
              detail: "Surface plissee a plis reguliers. Le format POC reprend la limite documentee de #{TECHNICAL_DATA.fetch(:reference_format)} pour tester les proportions."
            ),
	            Part.new(
	              id: "barre-poignee",
	              number: "4",
              label: "Barre poignee",
              measurement: TECHNICAL_DATA.fetch(:movement),
              detail: "Profil de tirage direct place en vue eclatee sur le cote mobile de la toile, avec zones de prise simplifiees mais lisibles."
            ),
	            Part.new(
	              id: "seuil-bas",
	              number: "5",
              label: "Seuil extra-plat",
              measurement: "#{TECHNICAL_DATA.fetch(:threshold_height_mm)} mm",
              detail: "Guide au sol extra-plat documente sur la fiche AMB. Il sert de test pour les pieces longues, fines et tres sensibles a l'aliasing."
            ),
	            Part.new(
	              id: "verrouillage",
	              number: "6",
              label: "Verrouillage",
              measurement: "Fermeture magnetique",
              detail: "Points magnetiques et zones de reception isoles pour montrer le principe de fermeture sans alourdir le dessin principal."
            )
          ].each_with_object({}) { |part, definitions| definitions[part.id] = part }.freeze

          METRICS = [
            Metric.new(label: "Encombrement", value: "#{TECHNICAL_DATA.fetch(:depth_mm)} mm", note: TECHNICAL_DATA.fetch(:source)),
            Metric.new(label: "Format max POC", value: TECHNICAL_DATA.fetch(:reference_format), note: TECHNICAL_DATA.fetch(:product_family)),
            Metric.new(label: "Seuil bas", value: "#{TECHNICAL_DATA.fetch(:threshold_height_mm)} mm", note: "guide au sol extra-plat")
          ].freeze

          def render_for?(product_page)
            product = product_page.product

            TARGET_SLUGS.include?(product.slug.to_s) || product.name.to_s.match?(/moustiquaire.*pliss/i)
          end

          def eyebrow
            "POC technique · AMB PLISSÉ 31"
          end

          def introduction
            "Deuxième reconstruction front : une moustiquaire plissée à déplacement latéral, découpée en rails, profils, toile, barre poignée et seuil bas pour tester la librairie d'éléments."
          end

          def svg_description
            "Vue technique vectorielle de la moustiquaire plissée AMB PLISSÉ 31 avec repères numérotés interactifs."
          end

          def drawing_component
            PublicV2::Products::ExplodedView::MoustiquairePlisseeDrawingComponent
          end

          private

          def build_layout
            guide = build_guide_layout
            fabric = build_fabric_layout(guide:)
            profiles = build_profile_layout(fabric:)
            handle = build_handle_layout(fabric:, profiles:)
            threshold = build_threshold_layout(guide:, profiles:)
            lock = build_lock_layout(handle:, profiles:)
            groups = build_groups(fabric:, handle:, lock:)
            callouts = build_callouts(guide:, profiles:, fabric:, handle:, threshold:, lock:, groups:)

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

          def build_callouts(guide:, profiles:, fabric:, handle:, threshold:, lock:, groups:)
            moving_panel = groups.fetch("toile-poignee")

            {
              "guide-haut" => callout("guide-haut", marker: guide.marker, anchor_side: :top, label_side: :left, first_length: 250, second_length: 430, text_offset_x: -72, text_anchor: "end"),
              "profils-muraux" => callout("profils-muraux", marker: profiles.marker, anchor_side: :left, label_side: :bottom, first_length: 310, second_length: 180),
              "toile-plissee" => callout("toile-plissee", marker: fabric.marker, anchor_side: :right, first_length: :lg),
              "barre-poignee" => callout("barre-poignee", marker: moving_panel.outside_anchor(side: :right, gap: layout_config.fetch(:marker_gap)), anchor_side: :top, label_side: :left, first_length: 230, second_length: 330, text_offset_x: -72, text_anchor: "end"),
              "seuil-bas" => callout("seuil-bas", marker: threshold.marker, anchor_side: :bottom, label_side: :left, first_length: 230, second_length: 430, text_offset_x: -72, text_anchor: "end"),
              "verrouillage" => callout("verrouillage", marker: lock.marker, anchor_side: :right, label_side: :top, first_length: 290, second_length: 170)
            }
          end

          def build_groups(fabric:, handle:, lock:)
            {
              "toile-poignee" => LayoutGroup.new(id: "toile-poignee", boxes: [fabric.body, handle.body]),
              "poignee-verrouillage" => LayoutGroup.new(id: "poignee-verrouillage", boxes: [handle.body, lock.hit])
            }
          end

          def build_guide_layout
            body = layout_box(Box.new(
              x: layout_config.fetch(:guide_x),
              y: layout_config.fetch(:guide_y),
              width: layout_config.fetch(:guide_width),
              height: layout_config.fetch(:guide_height),
              rx: layout_config.fetch(:guide_radius)
            ))

            PlisseeRailLayout.new(
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 120, inset_y: 95)),
              body:,
              marker: layout_anchor(body, side: :right, gap: layout_config.fetch(:marker_gap))
            )
          end

          def build_fabric_layout(guide:)
            body = layout_box(LayoutRules.below(
              guide.body,
              gap: layout_config.fetch(:gap_guide_fabric),
              x: layout_config.fetch(:fabric_x),
              width: layout_config.fetch(:fabric_width),
              height: layout_config.fetch(:fabric_height),
              rx: layout_config.fetch(:fabric_radius)
            ))

            PlisseeFabricLayout.new(
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 85, inset_y: 85)),
              body:,
              marker: layout_anchor(body, side: :top, gap: 175),
              pleat_xs: FabricGeometry.vertical_lines(
                body:,
                count: layout_config.fetch(:pleat_count)
              ),
              thread_ys: [body.y + 310, body.center_y, body.bottom - 310]
            )
          end

          def build_profile_layout(fabric:)
            height = fabric.body.height + 320
            top = fabric.body.y - 160
            left = layout_box(LayoutRules.left_of(
              fabric.body,
              gap: layout_config.fetch(:profile_gap),
              y: top,
              width: layout_config.fetch(:profile_width),
              height:,
              rx: layout_config.fetch(:profile_radius)
            ))
            right = layout_box(LayoutRules.right_of(
              fabric.body,
              gap: layout_config.fetch(:handle_gap) + layout_config.fetch(:handle_width) + 620,
              y: top,
              width: layout_config.fetch(:profile_width),
              height:,
              rx: layout_config.fetch(:profile_radius)
            ))

            slot_ys = RailGeometry.distributed_positions(start: top, finish: top + height, count: 4)

            PlisseeProfileLayout.new(
              hit: layout_box(LayoutRules.hit_box(left, inset_x: 80, inset_y: 75)),
              left:,
              right:,
              marker: layout_anchor(left, side: :left, gap: layout_config.fetch(:marker_gap)),
              slot_ys:
            )
          end

          def build_handle_layout(fabric:, profiles:)
            body = layout_box(LayoutRules.right_of(
              fabric.body,
              gap: 0,
              y: profiles.left.y + 90,
              width: layout_config.fetch(:handle_width),
              height: profiles.left.height - 180,
              rx: layout_config.fetch(:handle_radius)
            ))

            PlisseeHandleLayout.new(
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 80, inset_y: 85)),
              body:,
              marker: layout_anchor(body, side: :right, gap: layout_config.fetch(:marker_gap)),
              grip: layout_box(BarGeometry.centered_box(center_x: body.center_x, center_y: body.center_y, width: 86, height: 250, rx: 28))
            )
          end

          def build_threshold_layout(guide:, profiles:)
            body = layout_box(LayoutRules.below(
              profiles.left,
              gap: layout_config.fetch(:threshold_gap),
              x: guide.body.x + 160,
              width: guide.body.width - 320,
              height: layout_config.fetch(:threshold_height),
              rx: layout_config.fetch(:threshold_radius)
            ))

            PlisseeThresholdLayout.new(
              hit: layout_box(LayoutRules.hit_box(body, inset_x: 110, inset_y: 90)),
              body:,
              marker: layout_anchor(body, side: :right, gap: layout_config.fetch(:marker_gap))
            )
          end

          def build_lock_layout(handle:, profiles:)
            radius = 34
            flat_x = handle.body.right
            catch_step = handle.body.height / 5
            catches = [
              Point.new(x: flat_x, y: handle.body.y + catch_step),
              Point.new(x: flat_x, y: handle.body.bottom - catch_step)
            ]

            PlisseeLockLayout.new(
              hit: layout_box(Box.new(x: flat_x - 42, y: handle.body.y - 85, width: 260, height: handle.body.height + 170)),
              marker: layout_point(Point.new(x: flat_x + 390, y: handle.body.center_y - 230)),
              catches:,
              radius:
            )
          end
        end
      end
    end
  end
end
