# frozen_string_literal: true

require_relative "bars"
require_relative "callouts"
require_relative "controls"
require_relative "closures"
require_relative "fabrics"
require_relative "geometry"
require_relative "housings"
require_relative "layout_primitives"
require_relative "motors"
require_relative "rails"
require_relative "slats"

module PublicV2
  module Products
    module ExplodedView
      DrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :support_marker,
        :supports,
        :motor,
        :coffre,
        :fabric,
        :coulisse,
        :barre,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      PlisseeDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :guide,
        :profiles,
        :fabric,
        :handle,
        :threshold,
        :lock,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      EnrollableDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :cassette,
        :rails,
        :fabric,
        :bottom_bar,
        :lock,
        :bavettes,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      VenetianSupportPair = Struct.new(
        :hit,
        :left,
        :right,
        :marker,
        :solid_profiles,
        keyword_init: true
      ) do
        def solid_profile_for(side)
          solid_profiles&.fetch(side.to_sym)
        end
      end

      DuetteCordPair = Struct.new(
        :hit,
        :left_x,
        :right_x,
        :top_y,
        :bottom_y,
        :marker,
        :dot_ys,
        :solid_profile,
        keyword_init: true
      ) do
        def path
          "M#{left_x} #{top_y}V#{bottom_y}M#{right_x} #{top_y}V#{bottom_y}"
        end

        def dot_points
          dot_ys.flat_map do |y|
            [
              Point.new(x: left_x, y:),
              Point.new(x: right_x, y:)
            ]
          end
        end
      end

      MountSupportPair = Struct.new(
        :hit,
        :left,
        :right,
        :marker,
        :solid_profiles,
        keyword_init: true
      ) do
        def solid_profile_for(side)
          solid_profiles&.fetch(side.to_sym)
        end
      end

      DuoRollElement = Struct.new(
        :hit,
        :body,
        :marker,
        keyword_init: true
      )

      DuetteDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :top_rail,
        :supports,
        :fabric,
        :intermediate_rail,
        :bottom_rail,
        :cords,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      DuoDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :headrail,
        :roll,
        :fabric,
        :bottom_bar,
        :control,
        :supports,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      VenetianDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :headrail,
        :slats,
        :bottom_bar,
        :control,
        :supports,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end
    end
  end
end
