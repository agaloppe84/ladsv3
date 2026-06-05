# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      FabricGrid = Struct.new(:body, :verticals, :horizontals, keyword_init: true) do
        def path
          FabricGeometry.grid_path(body:, verticals:, horizontals:)
        end
      end

      module FabricGeometry
        module_function

        def positions(start:, finish:, count:, include_edges: true)
          raise ArgumentError, "count must be greater than 1" if count.to_i < 2

          step = interval(start:, finish:, count:)
          range = include_edges ? (0...count) : (1...(count - 1))

          range.map { |index| start + (index * step) }
        end

        def vertical_lines(body:, count:, include_edges: true)
          positions(start: body.x, finish: body.right, count:, include_edges:)
        end

        def horizontal_lines(body:, count:, include_edges: true)
          positions(start: body.y, finish: body.bottom, count:, include_edges:)
        end

        def indexed_positions(start:, finish:, count:, indexes:)
          step = interval(start:, finish:, count:)

          indexes.map { |index| start + (index * step) }
        end

        def every(values, step:, offset: 0)
          values.each_with_index.filter_map do |value, index|
            value if index >= offset && ((index - offset) % step).zero?
          end
        end

        def grid(body:, vertical_count:, horizontal_count:, include_edges: false)
          FabricGrid.new(
            body:,
            verticals: vertical_lines(body:, count: vertical_count, include_edges:),
            horizontals: horizontal_lines(body:, count: horizontal_count, include_edges:)
          )
        end

        def grid_path(body:, verticals:, horizontals:)
          [
            verticals.map { |x| "M#{x} #{body.y}V#{body.bottom}" },
            horizontals.map { |y| "M#{body.x} #{y}H#{body.right}" }
          ].flatten.join
        end

        def interval(start:, finish:, count:)
          raise ArgumentError, "count must be greater than 1" if count.to_i < 2

          (finish - start) / (count - 1)
        end
      end
    end
  end
end
