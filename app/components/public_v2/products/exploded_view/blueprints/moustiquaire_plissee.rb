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
            guide_preset: :rail_horizontal_guide,
            gap_guide_fabric: :guide_to_fabric,
            fabric_x: 1_420,
            fabric_preset: :fabric_pleated,
            pleat_count: 31,
            profile_gap: :profile_to_fabric,
            profile_preset: :rail_profile_pair,
            handle_gap: :handle_to_fabric,
            handle_preset: :bar_vertical_handle,
            threshold_gap: :exploded_md,
            threshold_preset: :bar_threshold
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
              "guide-haut" => callout("guide-haut", marker: guide.marker, placement: :top_rail),
              "profils-muraux" => callout("profils-muraux", marker: profiles.marker, placement: :left_vertical_pair),
              "toile-plissee" => callout("toile-plissee", marker: fabric.marker, placement: :side_fabric),
              "barre-poignee" => callout("barre-poignee", marker: moving_panel.outside_anchor(side: :right, gap: layout_config.fetch(:marker_gap)), placement: :right_attached_panel),
              "seuil-bas" => callout("seuil-bas", marker: threshold.marker, placement: :bottom_rail),
              "verrouillage" => callout("verrouillage", marker: lock.marker, placement: :right_detail_up)
            }
          end

          def build_groups(fabric:, handle:, lock:)
            {
              "toile-poignee" => LayoutGroup.attached(id: "toile-poignee", boxes: [fabric.body, handle.body]),
              "poignee-verrouillage" => LayoutGroup.attached(id: "poignee-verrouillage", boxes: [handle.body, lock.hit])
            }
          end

          def build_guide_layout
            horizontal_rail_element(
              preset: layout_config.fetch(:guide_preset),
              x: layout_config.fetch(:guide_x),
              y: layout_config.fetch(:guide_y),
              width: layout_config[:guide_width],
              height: layout_config[:guide_height],
              rx: layout_config[:guide_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 120,
              hit_inset_y: 95,
              solid_profile: {
                id: "plissee-guide-haut",
                point_radius: 23
              }
            )
          end

          def build_fabric_layout(guide:)
            fabric_element(
              variant: :pleated,
              reference: guide.body,
              preset: layout_config.fetch(:fabric_preset),
              gap: layout_config.fetch(:gap_guide_fabric),
              x: layout_config.fetch(:fabric_x),
              width: layout_config[:fabric_width],
              height: layout_config[:fabric_height],
              rx: layout_config[:fabric_radius],
              marker_gap: 175,
              hit_inset_x: 85,
              hit_inset_y: 85,
              pleat_count: layout_config.fetch(:pleat_count),
              thread_offsets: [310, -310],
              pattern_id: "plissee-toile",
              pattern_style: :solid
            )
          end

          def build_profile_layout(fabric:)
            profile_preset = layout_config.fetch(:profile_preset)
            handle_preset = layout_config.fetch(:handle_preset)
            height = fabric.body.height + 320
            top = fabric.body.y - 160
            right_gap = layout_gap(layout_config.fetch(:handle_gap)) +
              standard_dimension(handle_preset, :width, override: layout_config[:handle_width]) +
              620

            vertical_rail_pair_element(
              reference: fabric.body,
              preset: profile_preset,
              left_gap: layout_config.fetch(:profile_gap),
              right_gap:,
              y: top,
              width: layout_config[:profile_width],
              height:,
              rx: layout_config[:profile_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 80,
              hit_inset_y: 75,
              slot_count: 4,
              inner_inset_x: 74,
              inner_top_inset: 90,
              inner_bottom_inset: 90,
              solid_profile: {
                id: "plissee-profils-muraux",
                point_radius: 24
              }
            )
          end

          def build_handle_layout(fabric:, profiles:)
            handle_preset = layout_config.fetch(:handle_preset)

            vertical_handle_bar_element(
              reference: fabric.body,
              preset: handle_preset,
              gap: :attached,
              y: profiles.left.y + 90,
              width: layout_config[:handle_width],
              height: profiles.left.height - 180,
              rx: layout_config[:handle_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 80,
              hit_inset_y: 85,
              grip_width: 86,
              grip_height: 250,
              grip_rx: 28,
              solid_profile: {
                id: "plissee-barre-poignee",
                axis: :vertical,
                grip: true
              }
            )
          end

          def build_threshold_layout(guide:, profiles:)
            threshold_preset = layout_config.fetch(:threshold_preset)

            threshold_bar_element(
              reference: profiles.left,
              preset: threshold_preset,
              gap: layout_config.fetch(:threshold_gap),
              x: guide.body.x + 160,
              width: guide.body.width - 320,
              height: layout_config[:threshold_height],
              rx: layout_config[:threshold_radius],
              marker_gap: layout_config.fetch(:marker_gap),
              hit_inset_x: 110,
              hit_inset_y: 90,
              solid_profile: {
                id: "plissee-seuil-bas",
                detail: {
                  height: 8,
                  inset_x: 170
                }
              }
            )
          end

          def build_lock_layout(handle:, profiles:)
            plissee_lock_element(
              handle:,
              radius: 34,
              catch_divisions: 5,
              catch_indexes: [1, 4],
              hit_inset_left: 42,
              hit_inset_y: 85,
              hit_width: 260,
              marker_offset_x: 390,
              marker_offset_y: -230,
              solid_profile: {
                id: "plissee-verrouillage"
              }
            )
          end
        end
      end
    end
  end
end
