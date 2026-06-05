# frozen_string_literal: true

require_relative "callouts"
require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      CanvasGrid = Struct.new(:frame, :minor_step, :major_step, keyword_init: true) do
        def columns
          frame.width / minor_step
        end

        def rows
          frame.height / minor_step
        end

        def minor_path
          path_for(step: minor_step)
        end

        def major_path
          path_for(step: major_step)
        end

        private

        def path_for(step:)
          return "" if step.to_f <= 0

          [
            positions(start: frame.x, finish: frame.right, step:).map { |x| "M#{format_number(x)} #{frame.y}V#{frame.bottom}" },
            positions(start: frame.y, finish: frame.bottom, step:).map { |y| "M#{frame.x} #{format_number(y)}H#{frame.right}" }
          ].flatten.join
        end

        def positions(start:, finish:, step:)
          values = []
          value = start + step

          while value < finish
            values << value
            value += step
          end

          values
        end

        def format_number(value)
          value.to_i == value ? value.to_i : value.round(2)
        end
      end

      ElementSpec = Struct.new(:family, :variant, :width, :height, :rx, keyword_init: true) do
        def box(x:, y:, width: nil, height: nil, rx: nil)
          Box.new(
            x:,
            y:,
            width: width || require_dimension(:width),
            height: height || require_dimension(:height),
            rx: rx || self.rx
          )
        end

        def dimension(name, override: nil)
          return override unless override.nil?

          require_dimension(name)
        end

        private

        def require_dimension(name)
          value = public_send(name)
          raise ArgumentError, "#{family}.#{variant} does not define #{name}" if value.nil?

          value
        end
      end

      module LayoutStandards
        ELEMENTS = {
          housing_zipped_coffre: ElementSpec.new(family: :housing, variant: :zipped_coffre, width: 6_100, height: 260, rx: 38),
          housing_kiss_50: ElementSpec.new(family: :housing, variant: :kiss_50, width: 5_840, height: 340, rx: 86),
          motor_tubular_head: ElementSpec.new(family: :motor, variant: :tubular_head, width: 320, height: 250, rx: 40),
          motor_tubular_tube: ElementSpec.new(family: :motor, variant: :tubular_tube, height: 170, rx: 36),
          fabric_zipped: ElementSpec.new(family: :fabric, variant: :zipped, width: 5_300, height: 2_050, rx: 22),
          fabric_pleated: ElementSpec.new(family: :fabric, variant: :pleated, width: 4_050, height: 1_540, rx: 18),
          fabric_bordered: ElementSpec.new(family: :fabric, variant: :bordered, width: 4_640, height: 1_920, rx: 18),
          rail_horizontal_guide: ElementSpec.new(family: :rail, variant: :horizontal_guide, width: 5_640, height: 260, rx: 42),
          rail_venetian_head: ElementSpec.new(family: :rail, variant: :venetian_head, width: 5_460, height: 230, rx: 40),
          rail_profile_pair: ElementSpec.new(family: :rail, variant: :profile_pair, width: 190, rx: 34),
          rail_double_coulisse: ElementSpec.new(family: :rail, variant: :double_coulisse, width: 240, rx: 42),
          slat_venetian_pack: ElementSpec.new(family: :slat, variant: :venetian_pack, width: 5_080, height: 1_920, rx: 14),
          bar_zipped_load: ElementSpec.new(family: :bar, variant: :zipped_load, height: 180),
          bar_vertical_handle: ElementSpec.new(family: :bar, variant: :vertical_handle, width: 300, rx: 42),
          bar_threshold: ElementSpec.new(family: :bar, variant: :threshold, height: 105, rx: 26),
          bar_bottom_charge: ElementSpec.new(family: :bar, variant: :bottom_charge, height: 150, rx: 34),
          bar_venetian_bottom: ElementSpec.new(family: :bar, variant: :venetian_bottom, width: 5_080, height: 140, rx: 30),
          control_venetian_wand: ElementSpec.new(family: :control, variant: :venetian_wand, width: 90, height: 1_220, rx: 34)
        }.freeze

        GAPS = {
          attached: 0,
          exploded_sm: 180,
          exploded_md: 300,
          exploded_lg: 420,
          exploded_xl: 500,
          guide_to_fabric: 520,
          fabric_to_load_bar: 280,
          rail_to_fabric: 310,
          profile_to_fabric: 470,
          handle_to_fabric: 340,
          headrail_to_slats: 420,
          slats_to_bottom_bar: 300
        }.freeze

        module_function

        def element(key)
          ELEMENTS.fetch(key.to_sym)
        end

        def gap(key)
          GAPS.fetch(key.to_sym)
        end

        def resolve_gap(value)
          value.is_a?(Symbol) ? gap(value) : value
        end
      end

      class CanvasSpec
        DEFAULT_CELL = 120
        DEFAULT_MARGIN = 60
        DEFAULT_MAJOR_EVERY = 4
        DEFAULT_RADIUS = 118
        DEFAULT_SNAP_UNIT = 10

        attr_reader :columns, :rows, :cell, :margin, :major_every, :radius, :snap_unit

        def initialize(
          columns:,
          rows:,
          cell: DEFAULT_CELL,
          margin: DEFAULT_MARGIN,
          major_every: DEFAULT_MAJOR_EVERY,
          radius: DEFAULT_RADIUS,
          snap_unit: DEFAULT_SNAP_UNIT
        )
          @columns = columns
          @rows = rows
          @cell = cell || DEFAULT_CELL
          @margin = margin || DEFAULT_MARGIN
          @major_every = major_every || DEFAULT_MAJOR_EVERY
          @radius = radius || DEFAULT_RADIUS
          @snap_unit = snap_unit || DEFAULT_SNAP_UNIT
        end

        def svg_width
          grid_width + (margin * 2)
        end

        def svg_height
          grid_height + (margin * 2)
        end

        def grid_width
          columns * cell
        end

        def grid_height
          rows * cell
        end

        def frame
          Box.new(
            x: margin,
            y: margin,
            width: columns * cell,
            height: rows * cell,
            rx: radius
          )
        end

        def grid
          CanvasGrid.new(
            frame:,
            minor_step: cell,
            major_step: cell * major_every
          )
        end

        def cell_x(column, offset: 0)
          margin + (column * cell) + offset
        end

        def cell_y(row, offset: 0)
          margin + (row * cell) + offset
        end

        def unit_x(index, offset: 0)
          margin + (index * snap_unit) + offset
        end

        def unit_y(index, offset: 0)
          margin + (index * snap_unit) + offset
        end

        def point(column:, row:, offset_x: 0, offset_y: 0)
          Point.new(x: cell_x(column, offset: offset_x), y: cell_y(row, offset: offset_y))
        end

        def box(column:, row:, columns:, rows:, rx: nil, inset_x: 0, inset_y: 0)
          Box.new(
            x: cell_x(column, offset: inset_x),
            y: cell_y(row, offset: inset_y),
            width: (columns * cell) - (inset_x * 2),
            height: (rows * cell) - (inset_y * 2),
            rx:
          )
        end

        def snap_x(value, step: snap_unit)
          snap(value, step:, origin: margin)
        end

        def snap_y(value, step: snap_unit)
          snap(value, step:, origin: margin)
        end

        def snap_length(value, step: snap_unit)
          snap(value, step:, origin: 0)
        end

        def snap_point(point, step: snap_unit)
          Point.new(x: snap_x(point.x, step:), y: snap_y(point.y, step:))
        end

        def snap_box(box, position_step: snap_unit, size_step: snap_unit, preserve_size: true)
          Box.new(
            x: snap_x(box.x, step: position_step),
            y: snap_y(box.y, step: position_step),
            width: preserve_size ? box.width : snap_length(box.width, step: size_step),
            height: preserve_size ? box.height : snap_length(box.height, step: size_step),
            rx: box.rx
          )
        end

        def aligned_position?(point, step: snap_unit)
          point.x == snap_x(point.x, step:) && point.y == snap_y(point.y, step:)
        end

        def aligned_box?(box, position_step: snap_unit, size_step: snap_unit, include_size: false)
          position_aligned = aligned_position?(Point.new(x: box.x, y: box.y), step: position_step)
          return position_aligned unless include_size

          position_aligned &&
            box.width == snap_length(box.width, step: size_step) &&
            box.height == snap_length(box.height, step: size_step)
        end

        private

        def snap(value, step:, origin:)
          origin + (((value - origin).to_f / step).round * step)
        end
      end

      LayoutGroup = Struct.new(:id, :boxes, :spacing_mode, keyword_init: true) do
        def self.attached(id:, boxes:)
          new(id:, boxes:, spacing_mode: :attached)
        end

        def bounds
          Box.union(boxes)
        end

        def attached?
          spacing_mode&.to_sym == :attached
        end

        def outside_anchor(side:, gap:)
          CalloutAnchor.outside(bounds, side:, gap:)
        end
      end

      module LayoutRules
        module_function

        def below(reference, gap:, x: reference.x, width: reference.width, height:, rx: nil)
          Box.new(x:, y: reference.bottom + gap, width:, height:, rx:)
        end

        def above(reference, gap:, x: reference.x, width: reference.width, height:, rx: nil)
          Box.new(x:, y: reference.y - gap - height, width:, height:, rx:)
        end

        def right_of(reference, gap:, y: reference.y, width:, height: reference.height, rx: nil)
          Box.new(x: reference.right + gap, y:, width:, height:, rx:)
        end

        def left_of(reference, gap:, y: reference.y, width:, height: reference.height, rx: nil)
          Box.new(x: reference.x - gap - width, y:, width:, height:, rx:)
        end

        def expand(box, inset_x:, inset_y:)
          Box.new(
            x: box.x - inset_x,
            y: box.y - inset_y,
            width: box.width + (inset_x * 2),
            height: box.height + (inset_y * 2),
            rx: box.rx
          )
        end

        def hit_box(box, inset_x:, inset_y:)
          expand(box, inset_x:, inset_y:)
        end

        def mirror_x(box, canvas_width:)
          Box.new(
            x: canvas_width - box.x - box.width,
            y: box.y,
            width: box.width,
            height: box.height,
            rx: box.rx
          )
        end

        def centered_on(center_x:, center_y:, width:, height:, rx: nil)
          Box.new(
            x: center_x - (width / 2),
            y: center_y - (height / 2),
            width:,
            height:,
            rx:
          )
        end

        def inside_bottom_centered(parent, width:, height:, bottom_gap:, rx: nil)
          Box.new(
            x: parent.center_x - (width / 2),
            y: parent.bottom - bottom_gap - height,
            width:,
            height:,
            rx:
          )
        end

        def point_outside(box, side:, gap:)
          CalloutAnchor.outside(box, side:, gap:)
        end

        def centered_point(box, offset_x: 0, offset_y: 0)
          Point.new(x: box.center_x + offset_x, y: box.center_y + offset_y)
        end

        def snap(value, step:, origin: 0)
          origin + (((value - origin).to_f / step).round * step)
        end
      end
    end
  end
end
