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

      FabricPatternLayer = Struct.new(:id, :slot, :role, :path, :shape_rendering, :box, :point, :radius, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def slot
          (self[:slot] || :under_outline).to_sym
        end

        def role
          (self[:role] || :line).to_sym
        end
      end

      class FabricPattern
        attr_reader :id, :variant, :body, :layers

        def initialize(id:, variant:, body:, layers:)
          @id = id.to_s
          @variant = variant.to_sym
          @body = body
          @layers = layers.map { |layer| FabricPatternLayer.coerce(layer) }.freeze
        end

        def layers_for(slot)
          layers.select { |layer| layer.slot == slot.to_sym }
        end
      end

      class FabricElement
        VARIANTS = %i[zipped pleated bordered_grid honeycomb duo_bands].freeze

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
          :cell_depth,
          :band_count,
          :opaque_ratio,
          :layer_offset,
          :band_radius,
          :pattern
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
              tick_offset: options.fetch(:tick_offset, 0),
              pattern_id: options.fetch(:pattern_id, nil),
              pattern_style: options.fetch(:pattern_style, nil),
              pattern_line_width: options.fetch(:pattern_line_width, FabricPatterns::ZIPPED_SOLID_LINE_WIDTH),
              pattern_edge_width: options.fetch(:pattern_edge_width, FabricPatterns::ZIPPED_SOLID_EDGE_WIDTH),
              pattern_edge_radius: options.fetch(:pattern_edge_radius, FabricPatterns::ZIPPED_SOLID_EDGE_RADIUS)
            )
          when :pleated
            pleated(
              hit:,
              body:,
              marker:,
              pleat_count: options.fetch(:pleat_count),
              thread_offsets: options.fetch(:thread_offsets),
              pleat_amplitude: options.fetch(:pleat_amplitude, 34),
              pattern_id: options.fetch(:pattern_id, nil),
              pattern_style: options.fetch(:pattern_style, nil),
              pattern_thread_width: options.fetch(:pattern_thread_width, FabricPatterns::PLEATED_SOLID_THREAD_WIDTH)
            )
          when :bordered_grid
            bordered_grid(
              hit:,
              body:,
              marker:,
              vertical_count: options.fetch(:vertical_count),
              horizontal_count: options.fetch(:horizontal_count),
              edge_fastener_indexes: options.fetch(:edge_fastener_indexes),
              edge_fastener_radius: options.fetch(:edge_fastener_radius),
              pattern_id: options.fetch(:pattern_id, nil),
              pattern_style: options.fetch(:pattern_style, :line)
            )
          when :honeycomb
            honeycomb(
              hit:,
              body:,
              marker:,
              cell_count: options.fetch(:cell_count),
              cell_depth: options.fetch(:cell_depth, 120),
              thread_offsets: options.fetch(:thread_offsets, []),
              pattern_id: options.fetch(:pattern_id, nil),
              pattern_style: options.fetch(:pattern_style, nil),
              pattern_thread_width: options.fetch(:pattern_thread_width, FabricPatterns::HONEYCOMB_SOLID_THREAD_WIDTH)
            )
          when :duo_bands
            duo_bands(
              hit:,
              body:,
              marker:,
              band_count: options.fetch(:band_count),
              opaque_ratio: options.fetch(:opaque_ratio, FabricPatterns::DUO_OPAQUE_RATIO),
              layer_offset: options.fetch(:layer_offset, FabricPatterns::DUO_LAYER_OFFSET),
              band_radius: options.fetch(:band_radius, FabricPatterns::DUO_BAND_RADIUS),
              pattern_id: options.fetch(:pattern_id, nil),
              pattern_style: options.fetch(:pattern_style, nil)
            )
          else
            raise ArgumentError, "Unknown fabric variant: #{variant}"
          end
        end

        def self.zipped(
          hit:,
          body:,
          marker:,
          line_count:,
          tick_step: 2,
          tick_offset: 0,
          pattern_id: nil,
          pattern_style: nil,
          pattern_line_width: FabricPatterns::ZIPPED_SOLID_LINE_WIDTH,
          pattern_edge_width: FabricPatterns::ZIPPED_SOLID_EDGE_WIDTH,
          pattern_edge_radius: FabricPatterns::ZIPPED_SOLID_EDGE_RADIUS
        )
          pattern = if pattern_style
                      FabricPatterns.zipped(
                        id: pattern_id || "zipped",
                        body:,
                        line_count:,
                        style: pattern_style,
                        line_width: pattern_line_width,
                        edge_width: pattern_edge_width,
                        edge_radius: pattern_edge_radius
                      )
                    end

          new(
            variant: :zipped,
            hit:,
            body:,
            marker:,
            line_count:,
            tick_step:,
            tick_offset:,
            pattern:
          )
        end

        def self.pleated(
          hit:,
          body:,
          marker:,
          pleat_count:,
          thread_offsets:,
          pleat_amplitude: 34,
          pattern_id: nil,
          pattern_style: nil,
          pattern_thread_width: FabricPatterns::PLEATED_SOLID_THREAD_WIDTH
        )
          pattern = if pattern_style
                      FabricPatterns.pleated(
                        id: pattern_id || "pleated",
                        body:,
                        pleat_count:,
                        pleat_amplitude:,
                        thread_offsets:,
                        style: pattern_style,
                        thread_width: pattern_thread_width
                      )
                    end

          new(
            variant: :pleated,
            hit:,
            body:,
            marker:,
            pleat_count:,
            pleat_amplitude:,
            thread_offsets:,
            pattern:
          )
        end

        def self.bordered_grid(
          hit:,
          body:,
          marker:,
          vertical_count:,
          horizontal_count:,
          edge_fastener_indexes:,
          edge_fastener_radius:,
          pattern_id: nil,
          pattern_style: :line
        )
          pattern = FabricPatterns.bordered_grid(
            id: pattern_id || "bordered-grid",
            body:,
            vertical_count:,
            horizontal_count:,
            edge_fastener_indexes:,
            edge_fastener_radius:,
            style: pattern_style
          )

          new(
            variant: :bordered_grid,
            hit:,
            body:,
            marker:,
            grid_vertical_count: vertical_count,
            grid_horizontal_count: horizontal_count,
            edge_fastener_indexes:,
            edge_fastener_radius:,
            pattern:
          )
        end

        def self.honeycomb(
          hit:,
          body:,
          marker:,
          cell_count:,
          cell_depth: 120,
          thread_offsets: [],
          pattern_id: nil,
          pattern_style: nil,
          pattern_thread_width: FabricPatterns::HONEYCOMB_SOLID_THREAD_WIDTH
        )
          pattern = if pattern_style
                      FabricPatterns.honeycomb(
                        id: pattern_id || "honeycomb",
                        body:,
                        cell_count:,
                        cell_depth:,
                        thread_offsets:,
                        style: pattern_style,
                        thread_width: pattern_thread_width
                      )
                    end

          new(
            variant: :honeycomb,
            hit:,
            body:,
            marker:,
            cell_count:,
            cell_depth:,
            thread_offsets:,
            pattern:
          )
        end

        def self.duo_bands(
          hit:,
          body:,
          marker:,
          band_count:,
          opaque_ratio: FabricPatterns::DUO_OPAQUE_RATIO,
          layer_offset: FabricPatterns::DUO_LAYER_OFFSET,
          band_radius: FabricPatterns::DUO_BAND_RADIUS,
          pattern_id: nil,
          pattern_style: nil
        )
          pattern = if pattern_style
                      FabricPatterns.duo_bands(
                        id: pattern_id || "duo-bands",
                        body:,
                        band_count:,
                        opaque_ratio:,
                        layer_offset:,
                        band_radius:,
                        style: pattern_style
                      )
                    end

          new(
            variant: :duo_bands,
            hit:,
            body:,
            marker:,
            band_count:,
            opaque_ratio:,
            layer_offset:,
            band_radius:,
            pattern:
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
          cell_depth: 120,
          band_count: nil,
          opaque_ratio: FabricPatterns::DUO_OPAQUE_RATIO,
          layer_offset: FabricPatterns::DUO_LAYER_OFFSET,
          band_radius: FabricPatterns::DUO_BAND_RADIUS,
          pattern: nil
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
          @band_count = band_count
          @opaque_ratio = opaque_ratio
          @layer_offset = layer_offset
          @band_radius = band_radius
          @pattern = pattern
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

      module FabricPatterns
        ZIPPED_SOLID_LINE_WIDTH = 8
        ZIPPED_SOLID_EDGE_WIDTH = 120
        ZIPPED_SOLID_EDGE_RADIUS = 8
        ZIP_TEETH_DEPTH = 34
        ZIP_TOOTH_HEIGHT_RATIO = 0.54
        PLEATED_SOLID_THREAD_WIDTH = 6
        PLEATED_SOLID_THREAD_POINT_RADIUS = 18
        HONEYCOMB_SOLID_RECESS_WIDTH = 7
        HONEYCOMB_SOLID_THREAD_WIDTH = 6
        DUO_OPAQUE_RATIO = 0.52
        DUO_LAYER_OFFSET = 0.5
        DUO_BAND_RADIUS = 10
        DUO_REAR_LAYER_INSET = 90

        SOLID_GRID_STROKE_WIDTH = 10
        SOLID_GRID_EDGE_CELLS = 2
        SOLID_GRID_FALLBACK_CELL_WIDTH = 60
        SOLID_GRID_EDGE_RADIUS = 8

        module_function

        def zipped(
          id:,
          body:,
          line_count:,
          style:,
          line_width: ZIPPED_SOLID_LINE_WIDTH,
          edge_width: ZIPPED_SOLID_EDGE_WIDTH,
          edge_radius: ZIPPED_SOLID_EDGE_RADIUS
        )
          style = style.to_sym

          FabricPattern.new(
            id:,
            variant: :zipped,
            body:,
            layers: zipped_layers(body:, line_count:, style:, line_width:, edge_width:, edge_radius:)
          )
        end

        def zipped_layers(body:, line_count:, style:, line_width:, edge_width:, edge_radius:)
          case style
          when :solid
            zipped_solid_layers(body:, line_count:, line_width:, edge_width:, edge_radius:)
          else
            raise ArgumentError, "Unknown zipped pattern style: #{style}"
          end
        end

        def pleated(
          id:,
          body:,
          pleat_count:,
          pleat_amplitude:,
          thread_offsets:,
          style:,
          thread_width: PLEATED_SOLID_THREAD_WIDTH
        )
          style = style.to_sym

          FabricPattern.new(
            id:,
            variant: :pleated,
            body:,
            layers: pleated_layers(body:, pleat_count:, pleat_amplitude:, thread_offsets:, style:, thread_width:)
          )
        end

        def pleated_layers(body:, pleat_count:, pleat_amplitude:, thread_offsets:, style:, thread_width:)
          case style
          when :solid
            pleated_solid_layers(body:, pleat_count:, pleat_amplitude:, thread_offsets:, thread_width:)
          else
            raise ArgumentError, "Unknown pleated pattern style: #{style}"
          end
        end

        def honeycomb(
          id:,
          body:,
          cell_count:,
          cell_depth:,
          thread_offsets:,
          style:,
          thread_width: HONEYCOMB_SOLID_THREAD_WIDTH
        )
          style = style.to_sym

          FabricPattern.new(
            id:,
            variant: :honeycomb,
            body:,
            layers: honeycomb_layers(body:, cell_count:, cell_depth:, thread_offsets:, style:, thread_width:)
          )
        end

        def honeycomb_layers(body:, cell_count:, cell_depth:, thread_offsets:, style:, thread_width:)
          case style
          when :solid
            honeycomb_solid_layers(body:, cell_count:, cell_depth:, thread_offsets:, thread_width:)
          else
            raise ArgumentError, "Unknown honeycomb pattern style: #{style}"
          end
        end

        def duo_bands(
          id:,
          body:,
          band_count:,
          opaque_ratio: DUO_OPAQUE_RATIO,
          layer_offset: DUO_LAYER_OFFSET,
          band_radius: DUO_BAND_RADIUS,
          style:
        )
          style = style.to_sym

          FabricPattern.new(
            id:,
            variant: :duo_bands,
            body:,
            layers: duo_band_layers(
              body:,
              band_count:,
              opaque_ratio:,
              layer_offset:,
              band_radius:,
              style:
            )
          )
        end

        def duo_band_layers(body:, band_count:, opaque_ratio:, layer_offset:, band_radius:, style:)
          case style
          when :solid
            duo_solid_band_layers(
              body:,
              band_count:,
              opaque_ratio:,
              layer_offset:,
              band_radius:
            )
          else
            raise ArgumentError, "Unknown duo band pattern style: #{style}"
          end
        end

        def zipped_solid_layers(body:, line_count:, line_width:, edge_width:, edge_radius:)
          left_edge = Box.new(x: body.x, y: body.y, width: edge_width, height: body.height, rx: edge_radius)
          right_edge = Box.new(x: body.right - edge_width, y: body.y, width: edge_width, height: body.height, rx: edge_radius)
          tooth_step = zip_tooth_step(body:, line_count:)

          [
            FabricPatternLayer.new(
              id: "surface",
              slot: :under_outline,
              role: :fabric_solid_surface,
              box: body
            ),
            FabricPatternLayer.new(
              id: "left-zip-edge",
              slot: :over_outline,
              role: :fabric_solid_edge,
              box: left_edge
            ),
            FabricPatternLayer.new(
              id: "right-zip-edge",
              slot: :over_outline,
              role: :fabric_solid_edge,
              box: right_edge
            ),
            FabricPatternLayer.new(
              id: "left-zip-teeth",
              slot: :over_outline,
              role: :fabric_zip_teeth,
              path: zip_teeth_path(x: left_edge.x, top: left_edge.y, bottom: left_edge.bottom, step: tooth_step, side: :left)
            ),
            FabricPatternLayer.new(
              id: "right-zip-teeth",
              slot: :over_outline,
              role: :fabric_zip_teeth,
              path: zip_teeth_path(x: right_edge.right, top: right_edge.y, bottom: right_edge.bottom, step: tooth_step, side: :right)
            )
          ]
        end

        def pleated_solid_layers(body:, pleat_count:, pleat_amplitude:, thread_offsets:, thread_width:)
          pleat_xs = FabricGeometry.vertical_lines(body:, count: pleat_count)
          top_points = pleat_edge_points(pleat_xs:, origin_y: body.y, amplitude: pleat_amplitude)
          bottom_points = pleat_edge_points(pleat_xs:, origin_y: body.bottom, amplitude: -pleat_amplitude)

          [
            FabricPatternLayer.new(
              id: "surface",
              slot: :under_outline,
              role: :fabric_solid_surface,
              path: pleated_surface_path(top_points:, bottom_points:)
            ),
            *pleated_face_layers(top_points:, bottom_points:),
            *pleated_thread_layers(body:, pleat_xs:, thread_offsets:, thread_width:)
          ]
        end

        def honeycomb_solid_layers(body:, cell_count:, cell_depth:, thread_offsets:, thread_width:)
          y_positions = honeycomb_zigzag_y_positions(body:, cell_count:)
          depth = honeycomb_zigzag_depth(body:, cell_count:, cell_depth:)

          [
            FabricPatternLayer.new(
              id: "surface",
              slot: :under_outline,
              role: :fabric_solid_surface,
              path: honeycomb_surface_path(body:, y_positions:, depth:)
            ),
            *honeycomb_face_layers(body:, y_positions:, depth:)
          ]
        end

        def duo_solid_band_layers(body:, band_count:, opaque_ratio:, layer_offset:, band_radius:)
          step = body.height.to_f / band_count
          band_height = step * opaque_ratio
          rear_offset = step * layer_offset

          [
            FabricPatternLayer.new(
              id: "surface",
              slot: :under_outline,
              role: :fabric_duo_sheer,
              box: body
            ),
            *duo_band_boxes(
              body:,
              band_count: band_count + 1,
              start_y: body.y + rear_offset,
              step:,
              height: band_height,
              inset_x: DUO_REAR_LAYER_INSET,
              radius: band_radius,
              role: :fabric_duo_band_mid,
              prefix: "rear-band"
            ),
            *duo_band_boxes(
              body:,
              band_count:,
              start_y: body.y,
              step:,
              height: band_height,
              inset_x: 0,
              radius: band_radius,
              role: :fabric_duo_band_light,
              prefix: "front-band"
            )
          ]
        end

        def bordered_grid(
          id:,
          body:,
          vertical_count:,
          horizontal_count:,
          edge_fastener_indexes:,
          edge_fastener_radius:,
          style: :line
        )
          style = style.to_sym
          grid = FabricGeometry.grid(body:, vertical_count:, horizontal_count:, include_edges: false)

          FabricPattern.new(
            id:,
            variant: :bordered_grid,
            body:,
            layers: bordered_grid_layers(body:, grid:, style:) + [
              *edge_fastener_layers(
                body:,
                count: horizontal_count,
                indexes: edge_fastener_indexes,
                radius: edge_fastener_radius,
                role: style == :solid ? :solid_dark : :fill,
                edge_inset: style == :solid ? solid_edge_width(grid.verticals) : 0
              )
            ]
          )
        end

        def bordered_grid_layers(body:, grid:, style:)
          case style
          when :line
            [
              FabricPatternLayer.new(
                id: "grid",
                slot: :under_outline,
                role: :grid,
                path: grid.path,
                shape_rendering: "crispEdges"
              )
            ]
          when :solid
            solid_grid_layers(body:, verticals: grid.verticals, horizontals: grid.horizontals)
          else
            raise ArgumentError, "Unknown bordered grid pattern style: #{style}"
          end
        end

        def solid_grid_layers(
          body:,
          verticals:,
          horizontals:,
          stroke_width: SOLID_GRID_STROKE_WIDTH,
          edge_width: nil,
          edge_radius: SOLID_GRID_EDGE_RADIUS
        )
          edge_width ||= solid_edge_width(verticals)
          left_edge = Box.new(x: body.x, y: body.y, width: edge_width, height: body.height, rx: edge_radius)
          right_edge = Box.new(x: body.right - edge_width, y: body.y, width: edge_width, height: body.height, rx: edge_radius)

          [
            FabricPatternLayer.new(
              id: "surface",
              slot: :under_outline,
              role: :fabric_solid_surface,
              box: body
            ),
            *verticals.map.with_index do |x, index|
              FabricPatternLayer.new(
                id: "vertical-grid-#{index}",
                slot: :under_outline,
                role: :fabric_solid_grid,
                box: centered_vertical_box(body:, x:, width: stroke_width)
              )
            end,
            *horizontals.map.with_index do |y, index|
              FabricPatternLayer.new(
                id: "horizontal-grid-#{index}",
                slot: :under_outline,
                role: :fabric_solid_grid,
                box: centered_horizontal_box(body:, y:, height: stroke_width)
              )
            end,
            FabricPatternLayer.new(
              id: "left-edge",
              slot: :over_outline,
              role: :fabric_solid_edge,
              box: left_edge
            ),
            FabricPatternLayer.new(
              id: "right-edge",
              slot: :over_outline,
              role: :fabric_solid_edge,
              box: right_edge
            ),
            FabricPatternLayer.new(
              id: "left-edge-detail",
              slot: :over_outline,
              role: :fabric_solid_edge_detail,
              path: vertical_edge_detail_path(left_edge)
            ),
            FabricPatternLayer.new(
              id: "right-edge-detail",
              slot: :over_outline,
              role: :fabric_solid_edge_detail,
              path: vertical_edge_detail_path(right_edge)
            )
          ]
        end

        def edge_fastener_layers(body:, count:, indexes:, radius:, role: :fill, edge_inset: 0)
          FabricGeometry.indexed_positions(
            start: body.y,
            finish: body.bottom,
            count:,
            indexes:
          ).each_with_index.flat_map do |y, index|
            [
              FabricPatternLayer.new(
                id: "left-fastener-#{index}",
                slot: :over_outline,
                role:,
                path: left_fastener_path(body:, y:, radius:, edge_inset:)
              ),
              FabricPatternLayer.new(
                id: "right-fastener-#{index}",
                slot: :over_outline,
                role:,
                path: right_fastener_path(body:, y:, radius:, edge_inset:)
              )
            ]
          end
        end

        def centered_vertical_box(body:, x:, width:)
          Box.new(x: x - (width / 2), y: body.y, width:, height: body.height, rx: 0)
        end

        def centered_horizontal_box(body:, y:, height:)
          Box.new(x: body.x, y: y - (height / 2), width: body.width, height:, rx: 0)
        end

        def solid_edge_width(verticals)
          grid_step(verticals) * SOLID_GRID_EDGE_CELLS
        end

        def grid_step(values)
          values.each_cons(2).first&.yield_self { |left, right| right - left } || SOLID_GRID_FALLBACK_CELL_WIDTH
        end

        def vertical_edge_detail_path(edge)
          "M#{edge.center_x} #{edge.y}V#{edge.bottom}"
        end

        def zip_tooth_step(body:, line_count:)
          FabricGeometry.interval(start: body.y, finish: body.bottom, count: line_count)
        end

        def honeycomb_face_layers(body:, y_positions:, depth:)
          y_positions.each_cons(2).with_index.map do |(top, bottom), index|
            FabricPatternLayer.new(
              id: "pleat-#{index}",
              slot: :under_outline,
              role: honeycomb_face_role(index),
              path: honeycomb_face_path(body:, top:, bottom:, index:, depth:)
            )
          end
        end

        def honeycomb_face_role(index)
          case index % 4
          when 0 then :fabric_honeycomb_face_light
          when 1 then :fabric_honeycomb_face_mid
          when 2 then :fabric_honeycomb_face_deep
          else :fabric_honeycomb_face_mid
          end
        end

        def honeycomb_face_path(body:, top:, bottom:, index:, depth:)
          left_top = honeycomb_left_x(body:, index:, depth:)
          left_bottom = honeycomb_left_x(body:, index: index + 1, depth:)
          right_top = honeycomb_right_x(body:, index:, depth:)
          right_bottom = honeycomb_right_x(body:, index: index + 1, depth:)

          "M#{left_top} #{top}H#{right_top}L#{right_bottom} #{bottom}H#{left_bottom}Z"
        end

        def honeycomb_surface_path(body:, y_positions:, depth:)
          left_points = honeycomb_side_points(body:, y_positions:, depth:, side: :left)
          right_points = honeycomb_side_points(body:, y_positions:, depth:, side: :right)

          [
            "M#{left_points.first.x} #{left_points.first.y}",
            "H#{right_points.first.x}",
            *right_points.drop(1).map { |point| "L#{point.x} #{point.y}" },
            "H#{left_points.last.x}",
            *left_points.reverse.drop(1).map { |point| "L#{point.x} #{point.y}" },
            "Z"
          ].join
        end

        def honeycomb_side_points(body:, y_positions:, depth:, side:)
          y_positions.map.with_index do |y, index|
            x = side.to_sym == :left ? honeycomb_left_x(body:, index:, depth:) : honeycomb_right_x(body:, index:, depth:)

            Point.new(x:, y:)
          end
        end

        def honeycomb_zigzag_y_positions(body:, cell_count:)
          FabricGeometry.horizontal_lines(body:, count: (cell_count * 2) + 1)
        end

        def honeycomb_zigzag_depth(body:, cell_count:, cell_depth:)
          segment_height = FabricGeometry.interval(start: body.y, finish: body.bottom, count: (cell_count * 2) + 1)

          [cell_depth, (segment_height * 2).round].min
        end

        def honeycomb_left_x(body:, index:, depth:)
          index.even? ? body.x : body.x + depth
        end

        def honeycomb_right_x(body:, index:, depth:)
          index.even? ? body.right : body.right - depth
        end

        def honeycomb_thread_layers(body:, thread_offsets:, thread_width:)
          thread_offsets.map.with_index do |offset, index|
            y = honeycomb_vertical_offset(body:, offset:)
            FabricPatternLayer.new(
              id: "thread-#{index}",
              slot: :over_outline,
              role: :fabric_honeycomb_thread,
              box: Box.new(
                x: body.x,
                y: y - (thread_width / 2),
                width: body.width,
                height: thread_width,
                rx: thread_width / 2
              )
            )
          end
        end

        def honeycomb_cell_bounds(body:, cell_count:)
          FabricGeometry.horizontal_lines(body:, count: cell_count + 1).each_cons(2).map do |top, bottom|
            [top, top + ((bottom - top) / 2), bottom]
          end
        end

        def honeycomb_cell_inset(cell_depth:, top:, bottom:)
          [cell_depth, (bottom - top) * 1.4].min
        end

        def honeycomb_top_face_path(body:, top:, middle:, inset:)
          "M#{body.x} #{top}H#{body.right}L#{body.right - inset} #{middle}H#{body.x + inset}Z"
        end

        def honeycomb_bottom_face_path(body:, middle:, bottom:, inset:)
          "M#{body.x + inset} #{middle}H#{body.right - inset}L#{body.right} #{bottom}H#{body.x}Z"
        end

        def honeycomb_left_edge_path(body:, top:, middle:, bottom:, inset:)
          "M#{body.x} #{top}L#{body.x + inset} #{middle}L#{body.x} #{bottom}Z"
        end

        def honeycomb_right_edge_path(body:, top:, middle:, bottom:, inset:)
          "M#{body.right} #{top}L#{body.right - inset} #{middle}L#{body.right} #{bottom}Z"
        end

        def honeycomb_vertical_offset(body:, offset:)
          case offset
          when :center then body.center_y
          when Numeric
            offset.negative? ? body.bottom + offset : body.y + offset
          else
            raise ArgumentError, "Unknown fabric vertical offset: #{offset}"
          end
        end

        def pleated_face_layers(top_points:, bottom_points:)
          top_points.each_cons(2).with_index.map do |(left_top, right_top), index|
            FabricPatternLayer.new(
              id: "pleat-face-#{index}",
              slot: :under_outline,
              role: index.even? ? :fabric_pleat_face_light : :fabric_pleat_face_mid,
              path: pleated_face_path(
                left_top:,
                right_top:,
                right_bottom: bottom_points[index + 1],
                left_bottom: bottom_points[index]
              )
            )
          end
        end

        def pleated_thread_layers(body:, pleat_xs:, thread_offsets:, thread_width:)
          pleat_centers = pleated_thread_points(pleat_xs:)

          thread_offsets.each_with_index.flat_map do |offset, index|
            y = pleated_vertical_offset(body:, offset:)

            [
              *pleated_thread_segment_layers(pleat_centers:, y:, thread_width:, thread_index: index),
              *pleated_thread_point_layers(pleat_centers:, y:, thread_index: index)
            ]
          end
        end

        def pleated_thread_segment_layers(pleat_centers:, y:, thread_width:, thread_index:)
          pleat_centers.each_cons(2).with_index.filter_map do |(left_x, right_x), segment_index|
            next unless segment_index.even?

            FabricPatternLayer.new(
              id: "thread-#{thread_index}-segment-#{segment_index}",
              slot: :over_outline,
              role: :fabric_pleat_thread,
              box: Box.new(
                x: left_x,
                y: y - (thread_width / 2),
                width: right_x - left_x,
                height: thread_width,
                rx: thread_width / 2
              )
            )
          end
        end

        def pleated_thread_point_layers(pleat_centers:, y:, thread_index:)
          pleat_centers.map.with_index do |x, point_index|
            FabricPatternLayer.new(
              id: "thread-#{thread_index}-point-#{point_index}",
              slot: :over_outline,
              role: :fabric_pleat_thread_point,
              point: Point.new(x:, y:),
              radius: PLEATED_SOLID_THREAD_POINT_RADIUS
            )
          end
        end

        def pleated_thread_points(pleat_xs:)
          pleat_xs.each_cons(2).map { |left, right| left + ((right - left) / 2) }
        end

        def pleat_edge_points(pleat_xs:, origin_y:, amplitude:)
          pleat_xs.each_with_index.map do |x, index|
            Point.new(x:, y: origin_y + (index.even? ? 0 : amplitude))
          end
        end

        def pleated_surface_path(top_points:, bottom_points:)
          top = top_points.each_with_index.map do |point, index|
            command = index.zero? ? "M" : "L"

            "#{command}#{point.x} #{point.y}"
          end
          bottom = bottom_points.reverse.map { |point| "L#{point.x} #{point.y}" }

          "#{top.join}#{bottom.join}Z"
        end

        def pleated_face_path(left_top:, right_top:, right_bottom:, left_bottom:)
          "M#{left_top.x} #{left_top.y}" \
            "L#{right_top.x} #{right_top.y}" \
            "L#{right_bottom.x} #{right_bottom.y}" \
            "L#{left_bottom.x} #{left_bottom.y}Z"
        end

        def pleated_vertical_offset(body:, offset:)
          case offset
          when :center then body.center_y
          when Numeric
            offset.negative? ? body.bottom + offset : body.y + offset
          else
            raise ArgumentError, "Unknown fabric vertical offset: #{offset}"
          end
        end

        def duo_band_boxes(body:, band_count:, start_y:, step:, height:, inset_x:, radius:, role:, prefix:)
          (0...band_count).filter_map do |index|
            y = start_y + (index * step)
            box = clamped_duo_band_box(body:, y:, height:, inset_x:, radius:)
            next unless box

            FabricPatternLayer.new(
              id: "#{prefix}-#{index}",
              slot: :under_outline,
              role:,
              box:
            )
          end
        end

        def clamped_duo_band_box(body:, y:, height:, inset_x:, radius:)
          top = [y, body.y].max
          bottom = [y + height, body.bottom].min
          return if bottom <= top

          resolved_height = bottom - top

          Box.new(
            x: body.x + inset_x,
            y: top,
            width: body.width - (inset_x * 2),
            height: resolved_height,
            rx: [radius, resolved_height / 2].min
          )
        end

        def zip_teeth_path(x:, top:, bottom:, step:, side:, depth: ZIP_TEETH_DEPTH)
          direction = side.to_sym == :right ? 1 : -1
          path = []
          y = top

          while y < bottom
            finish = [y + step, bottom].min
            segment_height = finish - y
            tooth_height = segment_height * ZIP_TOOTH_HEIGHT_RATIO
            tooth_top = y + ((segment_height - tooth_height) / 2)
            tooth_bottom = tooth_top + tooth_height
            outer_x = x + (direction * depth)

            path << "M#{x} #{tooth_top}H#{outer_x}V#{tooth_bottom}H#{x}Z"
            y += step
          end

          path.join
        end

        def left_fastener_path(body:, y:, radius:, edge_inset: 0)
          x = body.x + edge_inset

          "M#{x} #{y - radius}" \
            "A#{radius} #{radius} 0 0 1 #{x} #{y + radius}" \
            "L#{x} #{y - radius}Z"
        end

        def right_fastener_path(body:, y:, radius:, edge_inset: 0)
          x = body.right - edge_inset

          "M#{x} #{y - radius}" \
            "A#{radius} #{radius} 0 0 0 #{x} #{y + radius}" \
            "L#{x} #{y - radius}Z"
        end
      end
    end
  end
end
