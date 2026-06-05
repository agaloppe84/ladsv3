# frozen_string_literal: true

require_relative "bars"
require_relative "callouts"
require_relative "closures"
require_relative "fabrics"
require_relative "geometry"
require_relative "housings"
require_relative "layout_primitives"
require_relative "motors"
require_relative "rails"

module PublicV2
  module Products
    module ExplodedView
      DrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
        :support_marker,
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
    end
  end
end
