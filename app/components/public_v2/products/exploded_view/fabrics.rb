# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      FabricGrid = Struct.new(:body, :verticals, :horizontals, keyword_init: true) do
        def path
          FabricGeometry.grid_path(body:, verticals:, horizontals:)
        end
      end

      class FabricElement
        VARIANTS = %i[zipped pleated bordered_grid honeycomb].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :marker,
          :line_count,
          :tick_step,
          :tick_offset,
          :pleat_count,
          :pleat_amplitude,
          :thread_offsets,
          :grid_vertical_count,
          :grid_horizontal_count,
          :edge_fastener_indexes,
          :edge_fastener_radius,
          :cell_count,
          :cell_depth
        )

        def self.build(variant:, hit:, body:, marker:, **options)
          case variant.to_sym
          when :zipped
            zipped(
              hit:,
              body:,
              marker:,
              line_count: options.fetch(:line_count),
              tick_step: options.fetch(:tick_step, 2),
              tick_offset: options.fetch(:tick_offset, 0)
            )
          when :pleated
            pleated(
              hit:,
              body:,
              marker:,
              pleat_count: options.fetch(:pleat_count),
              thread_offsets: options.fetch(:thread_offsets),
              pleat_amplitude: options.fetch(:pleat_amplitude, 34)
            )
          when :bordered_grid
            bordered_grid(
              hit:,
              body:,
              marker:,
              vertical_count: options.fetch(:vertical_count),
              horizontal_count: options.fetch(:horizontal_count),
              edge_fastener_indexes: options.fetch(:edge_fastener_indexes),
              edge_fastener_radius: options.fetch(:edge_fastener_radius)
            )
          when :honeycomb
            honeycomb(
              hit:,
              body:,
              marker:,
              cell_count: options.fetch(:cell_count),
              cell_depth: options.fetch(:cell_depth, 120),
              thread_offsets: options.fetch(:thread_offsets, [])
            )
          else
            raise ArgumentError, "Unknown fabric variant: #{variant}"
          end
        end

        def self.zipped(hit:, body:, marker:, line_count:, tick_step: 2, tick_offset: 0)
          new(
            variant: :zipped,
            hit:,
            body:,
            marker:,
            line_count:,
            tick_step:,
            tick_offset:
          )
        end

        def self.pleated(hit:, body:, marker:, pleat_count:, thread_offsets:, pleat_amplitude: 34)
          new(
            variant: :pleated,
            hit:,
            body:,
            marker:,
            pleat_count:,
            pleat_amplitude:,
            thread_offsets:
          )
        end

        def self.bordered_grid(
          hit:,
          body:,
          marker:,
          vertical_count:,
          horizontal_count:,
          edge_fastener_indexes:,
          edge_fastener_radius:
        )
          new(
            variant: :bordered_grid,
            hit:,
            body:,
            marker:,
            grid_vertical_count: vertical_count,
            grid_horizontal_count: horizontal_count,
            edge_fastener_indexes:,
            edge_fastener_radius:
          )
        end

        def self.honeycomb(hit:, body:, marker:, cell_count:, cell_depth: 120, thread_offsets: [])
          new(
            variant: :honeycomb,
            hit:,
            body:,
            marker:,
            cell_count:,
            cell_depth:,
            thread_offsets:
          )
        end

        def initialize(
          variant:,
          hit:,
          body:,
          marker:,
          line_count: nil,
          tick_step: 2,
          tick_offset: 0,
          pleat_count: nil,
          pleat_amplitude: 34,
          thread_offsets: [],
          grid_vertical_count: nil,
          grid_horizontal_count: nil,
          edge_fastener_indexes: [],
          edge_fastener_radius: nil,
          cell_count: nil,
          cell_depth: 120
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown fabric variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @marker = marker
          @line_count = line_count
          @tick_step = tick_step
          @tick_offset = tick_offset
          @pleat_count = pleat_count
          @pleat_amplitude = pleat_amplitude
          @thread_offsets = thread_offsets
          @grid_vertical_count = grid_vertical_count
          @grid_horizontal_count = grid_horizontal_count
          @edge_fastener_indexes = edge_fastener_indexes
          @edge_fastener_radius = edge_fastener_radius
          @cell_count = cell_count
          @cell_depth = cell_depth
        end

        def line_ys
          FabricGeometry.horizontal_lines(body:, count: require_option(:line_count))
        end

        def tick_ys
          FabricGeometry.every(line_ys, step: tick_step, offset: tick_offset)
        end

        def pleat_xs
          FabricGeometry.vertical_lines(body:, count: require_option(:pleat_count))
        end

        def thread_ys
          thread_offsets.map { |offset| vertical_offset(offset) }
        end

        def grid
          FabricGeometry.grid(
            body:,
            vertical_count: require_option(:grid_vertical_count),
            horizontal_count: require_option(:grid_horizontal_count),
            include_edges: false
          )
        end

        def grid_path
          grid.path
        end

        def edge_fastener_ys
          FabricGeometry.indexed_positions(
            start: body.y,
            finish: body.bottom,
            count: require_option(:grid_horizontal_count),
            indexes: edge_fastener_indexes
          )
        end

        def surface_path
          top_points = pleat_points(body.y, pleat_amplitude).each_with_index.map do |point, index|
            command = index.zero? ? "M" : "L"
            "#{command}#{point.x} #{point.y}"
          end
          bottom_points = pleat_points(body.bottom, -pleat_amplitude).reverse.map { |point| "L#{point.x} #{point.y}" }

          "#{top_points.join}#{bottom_points.join}Z"
        end

        def top_pleat_path
          pleat_edge_path(body.y, pleat_amplitude)
        end

        def bottom_pleat_path
          pleat_edge_path(body.bottom, -pleat_amplitude)
        end

        def side_path
          "M#{body.x} #{body.y}V#{body.bottom}M#{body.right} #{body.y}V#{body.bottom}"
        end

        def top_pleat_y(index)
          pleat_y(body.y, pleat_amplitude, index)
        end

        def bottom_pleat_y(index)
          pleat_y(body.bottom, -pleat_amplitude, index)
        end

        def left_fastener_path(y)
          "M#{body.x} #{y - edge_fastener_radius}" \
            "A#{edge_fastener_radius} #{edge_fastener_radius} 0 0 1 #{body.x} #{y + edge_fastener_radius}" \
            "L#{body.x} #{y - edge_fastener_radius}Z"
        end

        def right_fastener_path(y)
          "M#{body.right} #{y - edge_fastener_radius}" \
            "A#{edge_fastener_radius} #{edge_fastener_radius} 0 0 0 #{body.right} #{y + edge_fastener_radius}" \
            "L#{body.right} #{y - edge_fastener_radius}Z"
        end

        def honeycomb_boundary_path
          internal_cell_ys.map { |y| "M#{body.x} #{y}H#{body.right}" }.join
        end

        def honeycomb_recess_path
          cell_bounds.map do |top, middle, bottom|
            inset = [cell_depth, (bottom - top) * 1.4].min

            "M#{body.x + inset} #{middle}H#{body.right - inset}"
          end.join
        end

        def honeycomb_side_path
          cell_bounds.map do |top, middle, bottom|
            "M#{body.x} #{top}L#{body.x + cell_depth} #{middle}L#{body.x} #{bottom}" \
              "M#{body.right} #{top}L#{body.right - cell_depth} #{middle}L#{body.right} #{bottom}"
          end.join
        end

        def cell_ys
          FabricGeometry.horizontal_lines(body:, count: require_option(:cell_count) + 1)
        end

        def internal_cell_ys
          cell_ys[1...-1]
        end

        def cell_bounds
          cell_ys.each_cons(2).map do |top, bottom|
            [top, top + ((bottom - top) / 2), bottom]
          end
        end

        private

        def require_option(name)
          value = public_send(name)
          raise ArgumentError, "#{variant} fabric requires #{name}" if value.nil?

          value
        end

        def vertical_offset(offset)
          case offset
          when :center then body.center_y
          when Numeric
            offset.negative? ? body.bottom + offset : body.y + offset
          else
            raise ArgumentError, "Unknown fabric vertical offset: #{offset}"
          end
        end

        def pleat_points(origin_y, amplitude)
          pleat_xs.each_with_index.map do |x, index|
            Point.new(x:, y: pleat_y(origin_y, amplitude, index))
          end
        end

        def pleat_edge_path(origin_y, amplitude)
          pleat_points(origin_y, amplitude).each_with_index.map do |point, index|
            command = index.zero? ? "M" : "L"

            "#{command}#{point.x} #{point.y}"
          end.join
        end

        def pleat_y(origin_y, amplitude, index)
          origin_y + (index.even? ? 0 : amplitude)
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
