# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Standards
            private

            def standard_element(key)
              LayoutStandards.element(key)
            end

            def standard_box(key, x:, y:, width: nil, height: nil, rx: nil, preserve_size: false)
              layout_box(
                standard_element(key).box(x:, y:, width:, height:, rx:),
                preserve_size:
              )
            end

            def standard_below_box(reference, preset:, gap:, x:, width: nil, height: nil, rx: nil)
              layout_box(
                LayoutRules.below(
                  reference,
                  gap: layout_gap(gap),
                  x:,
                  width: standard_dimension(preset, :width, override: width),
                  height: standard_dimension(preset, :height, override: height),
                  rx: standard_value(preset, :rx, override: rx)
                )
              )
            end

            def standard_value(key, name, override: nil)
              standard_element(key).dimension(name, override:)
            end

            def standard_dimension(key, name, override: nil)
              layout_size(standard_value(key, name, override:))
            end
          end
        end
      end
    end
  end
end
