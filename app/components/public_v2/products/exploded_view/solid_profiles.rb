# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      SolidBand = Struct.new(:offset, :height, :tone, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def tone
          self[:tone].to_sym
        end
      end

      SolidPoint = Struct.new(:point, :radius, :tone, keyword_init: true) do
        def self.coerce(value, radius: 20, tone: :dark)
          case value
          when self
            value
          when Point
            new(point: value, radius:, tone:)
          else
            new(**value)
          end
        end

        def radius
          self[:radius] || 20
        end

        def tone
          (self[:tone] || :dark).to_sym
        end
      end

      SolidHousingFeature = Struct.new(:id, :kind, :box, :tone, :rx, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def kind
          (self[:kind] || :rect).to_sym
        end

        def tone
          (self[:tone] || :mid).to_sym
        end

        def rx
          self[:rx] || box.rx || 0
        end
      end

      SolidBarFeature = Struct.new(:id, :kind, :box, :tone, :rx, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def kind
          (self[:kind] || :rect).to_sym
        end

        def tone
          (self[:tone] || :mid).to_sym
        end

        def rx
          self[:rx] || box.rx || 0
        end
      end

      SolidSupportFeature = Struct.new(:id, :kind, :box, :tone, :rx, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def kind
          (self[:kind] || :rect).to_sym
        end

        def tone
          (self[:tone] || :mid).to_sym
        end

        def rx
          self[:rx] || box.rx || 0
        end
      end

      SolidControlFeature = Struct.new(:id, :kind, :box, :tone, :rx, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def kind
          (self[:kind] || :rect).to_sym
        end

        def tone
          (self[:tone] || :dark).to_sym
        end

        def rx
          self[:rx] || box.rx || 0
        end
      end

      SolidMotorFeature = Struct.new(:id, :kind, :box, :tone, :rx, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def kind
          (self[:kind] || :rect).to_sym
        end

        def tone
          (self[:tone] || :light).to_sym
        end

        def rx
          self[:rx] || box.rx || 0
        end
      end

      SolidAccessoryFeature = Struct.new(:id, :kind, :box, :path, :tone, :rx, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def kind
          (self[:kind] || :rect).to_sym
        end

        def tone
          (self[:tone] || :dark).to_sym
        end

        def rx
          self[:rx] || box&.rx || 0
        end
      end

      class SolidHousingProfile
        attr_reader :id, :variant, :body, :body_tone, :features, :points

        def initialize(id:, body:, features: [], points: [], variant: :front_box, body_tone: :light)
          @id = id.to_s
          @variant = variant.to_sym
          @body = body
          @body_tone = body_tone.to_sym
          @features = features.map { |feature| SolidHousingFeature.coerce(feature) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
        end

        def tones
          ([body_tone] + features.map(&:tone) + points.map(&:tone)).uniq
        end
      end

      class SolidSupportProfile
        attr_reader :id, :variant, :body, :body_tone, :features, :points

        def initialize(id:, body:, features: [], points: [], variant: :mount_support, body_tone: :light)
          @id = id.to_s
          @variant = variant.to_sym
          @body = body
          @body_tone = body_tone.to_sym
          @features = features.map { |feature| SolidSupportFeature.coerce(feature) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
        end

        def tones
          ([body_tone] + features.map(&:tone) + points.map(&:tone)).uniq
        end
      end

      class SolidControlProfile
        attr_reader :id, :variant, :features, :points, :clip_box

        def initialize(id:, features: [], points: [], variant: :control, clip_box: nil)
          @id = id.to_s
          @variant = variant.to_sym
          @features = features.map { |feature| SolidControlFeature.coerce(feature) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
          @clip_box = clip_box || Box.union(@features.map(&:box), point_boxes(@points))
        end

        def tones
          (features.map(&:tone) + points.map(&:tone)).uniq
        end

        private

        def point_boxes(points)
          points.map do |point|
            radius = point.radius
            Box.new(
              x: point.point.x - radius,
              y: point.point.y - radius,
              width: radius * 2,
              height: radius * 2,
              rx: radius
            )
          end
        end
      end

      class SolidMotorProfile
        attr_reader :id, :variant, :features, :points, :clip_box

        def initialize(id:, features: [], points: [], variant: :tubular_motor, clip_box: nil)
          @id = id.to_s
          @variant = variant.to_sym
          @features = features.map { |feature| SolidMotorFeature.coerce(feature) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
          @clip_box = clip_box || Box.union(@features.map(&:box), point_boxes(@points))
        end

        def tones
          (features.map(&:tone) + points.map(&:tone)).uniq
        end

        private

        def point_boxes(points)
          points.map do |point|
            radius = point.radius
            Box.new(
              x: point.point.x - radius,
              y: point.point.y - radius,
              width: radius * 2,
              height: radius * 2,
              rx: radius
            )
          end
        end
      end

      class SolidAccessoryProfile
        attr_reader :id, :variant, :features, :points, :clip_box

        def initialize(id:, features: [], points: [], variant: :accessory, clip_box: nil)
          @id = id.to_s
          @variant = variant.to_sym
          @features = features.map { |feature| SolidAccessoryFeature.coerce(feature) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
          @clip_box = clip_box || Box.union(@features.map(&:box), point_boxes(@points))
        end

        def tones
          (features.map(&:tone) + points.map(&:tone)).uniq
        end

        private

        def point_boxes(points)
          points.map do |point|
            radius = point.radius
            Box.new(
              x: point.point.x - radius,
              y: point.point.y - radius,
              width: radius * 2,
              height: radius * 2,
              rx: radius
            )
          end
        end
      end

      class SolidBarProfile
        AXES = %i[horizontal vertical].freeze

        attr_reader :id, :variant, :axis, :body, :clip_box, :body_tone, :features, :points

        def initialize(id:, body:, features: [], points: [], variant: :horizontal_bar, axis: :horizontal, body_tone: :light, clip_box: nil)
          @id = id.to_s
          @variant = variant.to_sym
          @axis = axis.to_sym
          raise ArgumentError, "Unknown solid bar axis: #{axis}" unless AXES.include?(@axis)

          @body = body
          @body_tone = body_tone.to_sym
          @features = features.map { |feature| SolidBarFeature.coerce(feature) }.freeze
          @clip_box = solid_bar_clip_box(clip_box)
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
        end

        def tones
          ([body_tone] + features.map(&:tone) + points.map(&:tone)).uniq
        end

        private

        def solid_bar_clip_box(clip_box)
          raw_box = clip_box || Box.union(body, features.map(&:box))
          Box.new(
            x: raw_box.x,
            y: raw_box.y,
            width: raw_box.width,
            height: raw_box.height,
            rx: raw_box.rx || solid_bar_clip_radius(raw_box)
          )
        end

        def solid_bar_clip_radius(raw_box)
          return body.rx || 0 if raw_box.x == body.x &&
                                 raw_box.y == body.y &&
                                 raw_box.width == body.width &&
                                 raw_box.height == body.height

          0
        end
      end

      class SolidProfile
        AXES = %i[horizontal vertical].freeze

        attr_reader :id, :variant, :axis, :box, :clip_box, :bands, :points

        def initialize(id:, box:, bands:, points: [], variant: :linear_profile, axis: :horizontal, clip_box: nil)
          @id = id.to_s
          @variant = variant.to_sym
          @axis = axis.to_sym
          raise ArgumentError, "Unknown solid profile axis: #{axis}" unless AXES.include?(@axis)

          @box = box
          @clip_box = clip_box || box
          @bands = bands.map { |band| SolidBand.coerce(band) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
        end

        def tones
          (bands.map(&:tone) + points.map(&:tone)).uniq
        end

        def horizontal?
          axis == :horizontal
        end

        def vertical?
          axis == :vertical
        end
      end

      module SolidProfiles
        LINEAR_THREE_BAND_TONES = {
          cap: :light,
          middle: :mid,
          point: :dark
        }.freeze
        HOUSING_TONES = {
          body: :light,
          cheek: :mid,
          opening: :dark,
          point: :dark
        }.freeze
        FRONT_COFFRE_DEFAULTS = {
          cheeks: {
            width: 120
          },
          opening: {
            inset_x: 480,
            height: 70,
            bottom_gap: 0,
            rx: 24
          }
        }.freeze
        BAR_TONES = {
          body: :light,
          detail: :mid,
          embout: :mid,
          grip: :dark,
          point: :dark
        }.freeze
        SUPPORT_TONES = {
          body: :light,
          detail: :mid,
          point: :dark
        }.freeze
        CONTROL_TONES = {
          segment: :dark,
          point: :dark,
          body: :dark
        }.freeze
        MOTOR_TONES = {
          tube: :light,
          cap: :mid,
          head: :light,
          hole: :dark
        }.freeze
        ACCESSORY_TONES = {
          body: :dark,
          point: :dark
        }.freeze

        module_function

        def horizontal_rail(id:, box:, screw_points:, cap_ratio: 0.29, point_radius: 24, tones: {})
          linear_three_band(
            id:,
            box:,
            axis: :horizontal,
            variant: :horizontal_rail,
            points: screw_points,
            cap_ratio:,
            point_radius:,
            tones:
          )
        end

        def vertical_rail(id:, box:, slot_ys:, cap_ratio: 0.29, point_radius: 18, tones: {})
          linear_three_band(
            id:,
            box:,
            axis: :vertical,
            variant: :vertical_rail,
            points: slot_ys.map { |y| Point.new(x: box.center_x, y:) },
            cap_ratio:,
            point_radius:,
            tones:
          )
        end

        def vertical_rail_pair(id:, left:, right:, slot_ys:, cap_ratio: 0.29, point_radius: 18, tones: {})
          {
            left: vertical_rail(id: "#{id}-left", box: left, slot_ys:, cap_ratio:, point_radius:, tones:),
            right: vertical_rail(id: "#{id}-right", box: right, slot_ys:, cap_ratio:, point_radius:, tones:)
          }
        end

        def linear_three_band(id:, box:, axis:, points:, cap_ratio:, point_radius:, tones:, variant:)
          cross_size = axis.to_sym == :vertical ? box.width : box.height
          cap_size = (cross_size * cap_ratio).round
          middle_size = cross_size - (cap_size * 2)
          raise ArgumentError, "#{variant} solid profile needs a positive middle band" if middle_size <= 0

          resolved_tones = LINEAR_THREE_BAND_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidProfile.new(
            id:,
            variant:,
            axis:,
            box:,
            bands: [
              SolidBand.new(offset: 0, height: cap_size, tone: resolved_tones.fetch(:cap)),
              SolidBand.new(offset: cap_size, height: middle_size, tone: resolved_tones.fetch(:middle)),
              SolidBand.new(offset: cross_size - cap_size, height: cap_size, tone: resolved_tones.fetch(:cap))
            ],
            points: points.map do |point|
              SolidPoint.new(point:, radius: point_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end

        def horizontal_bar(
          id:,
          box:,
          body_tone: nil,
          detail: nil,
          embouts: nil,
          grip: nil,
          extensions: [],
          tabs: [],
          points: [],
          point_radius: 18,
          features: [],
          axis: :horizontal,
          tones: {}
        )
          resolved_tones = BAR_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidBarProfile.new(
            id:,
            variant: :horizontal_bar,
            axis:,
            body: box,
            body_tone: body_tone || resolved_tones.fetch(:body),
            features: bar_features(
              box:,
              detail:,
              embouts:,
              grip:,
              extensions:,
              tabs:,
              features:,
              tones: resolved_tones
            ),
            points: points.map do |point|
              SolidPoint.new(point:, radius: point_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end

        def mount_support_pair(
          id:,
          left:,
          right:,
          point_inset: nil,
          point_radius: 20,
          point_specs: nil,
          detail_inset_x: 42,
          detail_inset_y: 62,
          detail_height: 10,
          detail_rows: nil,
          detail_style: :horizontal_pair,
          tones: {}
        )
          {
            left: mount_support(
              id: "#{id}-left",
              box: left,
              point_inset:,
              point_radius:,
              point_specs:,
              detail_inset_x:,
              detail_inset_y:,
              detail_height:,
              detail_rows:,
              detail_style:,
              tones:
            ),
            right: mount_support(
              id: "#{id}-right",
              box: right,
              point_inset:,
              point_radius:,
              point_specs:,
              detail_inset_x:,
              detail_inset_y:,
              detail_height:,
              detail_rows:,
              detail_style:,
              tones:
            )
          }
        end

        def mount_support(
          id:,
          box:,
          point_inset: nil,
          point_radius: 20,
          point_specs: nil,
          detail_inset_x: 42,
          detail_inset_y: 62,
          detail_height: 10,
          detail_rows: nil,
          detail_style: :horizontal_pair,
          tones: {}
        )
          resolved_tones = SUPPORT_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidSupportProfile.new(
            id:,
            variant: :mount_support,
            body: box,
            body_tone: resolved_tones.fetch(:body),
            features: support_detail_features(
              box:,
              inset_x: detail_inset_x,
              inset_y: detail_inset_y,
              height: detail_height,
              rows: detail_rows,
              style: detail_style,
              tone: resolved_tones.fetch(:detail)
            ),
            points: support_points(
              box:,
              point_inset:,
              point_radius:,
              point_specs:,
              tones: resolved_tones
            )
          )
        end

        def control_pair(id:, xs:, top:, bottom:, dot_ys:, segment_width: 14, point_radius: 18, tones: {})
          half_width = segment_width / 2

          control_segments(
            id:,
            variant: :vertical_control_pair,
            segment_boxes: xs.map { |x| Box.new(x: x - half_width, y: top, width: segment_width, height: bottom - top, rx: half_width) },
            points: xs.flat_map { |x| dot_ys.map { |y| Point.new(x:, y:) } },
            point_radius:,
            tones:
          )
        end

        def control_segments(id:, segment_boxes:, points: [], point_radius: 18, variant: :control_segments, tones: {})
          resolved_tones = CONTROL_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidControlProfile.new(
            id:,
            variant:,
            features: segment_boxes.map.with_index do |box, index|
              SolidControlFeature.new(
                id: "segment-#{index + 1}",
                kind: :rect,
                box:,
                tone: resolved_tones.fetch(:segment),
                rx: box.rx || 0
              )
            end,
            points: points.map do |point|
              SolidPoint.new(point:, radius: point_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end

        def bead_chain(id:, x:, top:, bottom:, bead_ys:, segment_width: 12, bead_radius: 20, tones: {})
          half_width = segment_width / 2

          control_segments(
            id:,
            variant: :bead_chain,
            segment_boxes: [Box.new(x: x - half_width, y: top, width: segment_width, height: bottom - top, rx: half_width)],
            points: bead_ys.map { |y| Point.new(x:, y:) },
            point_radius: bead_radius,
            tones:
          )
        end

        def wand_control(id:, body:, cord_x:, top:, bottom:, bead_ys:, segment_width: 12, bead_radius: 20, tones: {})
          resolved_tones = CONTROL_TONES.merge((tones || {}).transform_keys(&:to_sym))
          half_width = segment_width / 2

          SolidControlProfile.new(
            id:,
            variant: :wand_control,
            features: [
              SolidControlFeature.new(
                id: "body",
                kind: :rect,
                box: body,
                tone: resolved_tones.fetch(:body),
                rx: body.rx || 0
              ),
              SolidControlFeature.new(
                id: "cord",
                kind: :rect,
                box: Box.new(x: cord_x - half_width, y: top, width: segment_width, height: bottom - top, rx: half_width),
                tone: resolved_tones.fetch(:segment),
                rx: half_width
              )
            ],
            points: bead_ys.map do |y|
              SolidPoint.new(point: Point.new(x: cord_x, y:), radius: bead_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end

        def control_rect(id:, box:, tone: nil, tones: {})
          resolved_tones = CONTROL_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidControlProfile.new(
            id:,
            variant: :control_rect,
            features: [
              SolidControlFeature.new(
                id: "body",
                kind: :rect,
                box:,
                tone: tone || resolved_tones.fetch(:body),
                rx: box.rx || 0
              )
            ]
          )
        end

        def tubular_motor(
          id:,
          tube:,
          head:,
          cap_width:,
          large_hole:,
          small_holes:,
          large_hole_radius: 45,
          small_hole_radius: 18,
          tones: {}
        )
          resolved_tones = MOTOR_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidMotorProfile.new(
            id:,
            variant: :tubular_motor,
            features: [
              SolidMotorFeature.new(
                id: "tube",
                kind: :left_rounded_rect,
                box: tube,
                tone: resolved_tones.fetch(:tube),
                rx: tube.rx || 0
              ),
              SolidMotorFeature.new(
                id: "tube-cap",
                kind: :left_rounded_rect,
                box: Box.new(x: tube.x, y: tube.y, width: cap_width, height: tube.height, rx: tube.rx),
                tone: resolved_tones.fetch(:cap),
                rx: tube.rx || 0
              ),
              SolidMotorFeature.new(
                id: "head",
                kind: :right_rounded_rect,
                box: head,
                tone: resolved_tones.fetch(:head),
                rx: head.rx || 0
              )
            ],
            points: [
              SolidPoint.new(point: large_hole, radius: large_hole_radius, tone: resolved_tones.fetch(:hole)),
              *small_holes.map do |hole|
                SolidPoint.new(point: hole, radius: small_hole_radius, tone: resolved_tones.fetch(:hole))
              end
            ]
          )
        end

        def magnetic_receivers(
          id:,
          points:,
          radius:,
          base_width: nil,
          base_height: 16,
          base_offset_y: 58,
          base_rx: nil,
          point_radius: 22,
          tones: {}
        )
          resolved_tones = ACCESSORY_TONES.merge((tones || {}).transform_keys(&:to_sym))
          resolved_base_width = base_width || ((radius * 2) + 84)
          resolved_base_rx = base_rx || (base_height / 2)

          SolidAccessoryProfile.new(
            id:,
            variant: :magnetic_receivers,
            features: points.map.with_index do |point, index|
              SolidAccessoryFeature.new(
                id: "receiver-base-#{index + 1}",
                kind: :rect,
                box: Box.new(
                  x: point.x - (resolved_base_width / 2),
                  y: point.y + base_offset_y - (base_height / 2),
                  width: resolved_base_width,
                  height: base_height,
                  rx: resolved_base_rx
                ),
                tone: resolved_tones.fetch(:body),
                rx: resolved_base_rx
              )
            end,
            points: points.map do |point|
              SolidPoint.new(point:, radius: point_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end

        def accessory_rect_pair(
          id:,
          left:,
          right:,
          tone: :body,
          variant: :accessory_rect_pair,
          tones: {}
        )
          resolved_tones = ACCESSORY_TONES.merge((tones || {}).transform_keys(&:to_sym))
          resolved_tone = resolved_tones.fetch(tone.to_sym, tone.to_sym)

          SolidAccessoryProfile.new(
            id:,
            variant:,
            features: [
              SolidAccessoryFeature.new(
                id: "left",
                kind: :rect,
                box: left,
                tone: resolved_tone,
                rx: left.rx || 0
              ),
              SolidAccessoryFeature.new(
                id: "right",
                kind: :rect,
                box: right,
                tone: resolved_tone,
                rx: right.rx || 0
              )
            ]
          )
        end

        def plissee_lock(id:, catches:, radius:, echo_offsets: [34, 74, 114], catch_tone: :point, tones: {})
          resolved_tones = ACCESSORY_TONES.merge((tones || {}).transform_keys(&:to_sym))
          resolved_catch_tone = resolved_tones.fetch(catch_tone.to_sym, catch_tone.to_sym)

          SolidAccessoryProfile.new(
            id:,
            variant: :plissee_lock,
            features: catches.flat_map.with_index do |point, index|
              [
                SolidAccessoryFeature.new(
                  id: "catch-#{index + 1}",
                  kind: :path,
                  box: accessory_arc_box(point, radius),
                  path: accessory_half_disc_path(point, radius),
                  tone: resolved_catch_tone
                ),
                *echo_offsets.map.with_index do |offset, echo_index|
                  echo_radius = radius + offset
                  SolidAccessoryFeature.new(
                    id: "echo-#{index + 1}-#{echo_index + 1}",
                    kind: :echo_path,
                    box: accessory_arc_box(point, echo_radius),
                    path: accessory_echo_path(point, echo_radius)
                  )
                end
              ]
            end
          )
        end

        def front_housing(
          id:,
          box:,
          points: [],
          point_radius: 22,
          variant: :front_box,
          opening: nil,
          cheeks: nil,
          features: [],
          tones: {}
        )
          resolved_tones = HOUSING_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidHousingProfile.new(
            id:,
            variant:,
            body: box,
            body_tone: resolved_tones.fetch(:body),
            features: housing_features(box:, opening:, cheeks:, features:, tones: resolved_tones),
            points: points.map do |point|
              SolidPoint.new(point:, radius: point_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end

        def front_coffre(
          id:,
          box:,
          points: [],
          point_radius: 22,
          opening: {},
          cheeks: {},
          features: [],
          tones: {}
        )
          front_housing(
            id:,
            box:,
            points:,
            point_radius:,
            variant: :front_coffre,
            opening: housing_style_options(FRONT_COFFRE_DEFAULTS.fetch(:opening), opening),
            cheeks: housing_style_options(FRONT_COFFRE_DEFAULTS.fetch(:cheeks), cheeks),
            features:,
            tones:
          )
        end

        def support_detail_features(box:, inset_x:, inset_y:, height:, rows:, style:, tone:)
          return support_row_detail_features(box:, rows:, default_height: height, tone:) if rows
          return support_cross_detail_features(box:, inset_x:, inset_y:, height:, tone:) if style.to_sym == :center_cross

          width = box.width - (inset_x * 2)
          rx = height / 2

          [
            SolidSupportFeature.new(
              id: "top-detail",
              kind: :rect,
              box: Box.new(x: box.x + inset_x, y: box.y + inset_y, width:, height:, rx:),
              tone:,
              rx:
            ),
            SolidSupportFeature.new(
              id: "bottom-detail",
              kind: :rect,
              box: Box.new(x: box.x + inset_x, y: box.bottom - inset_y - height, width:, height:, rx:),
              tone:,
              rx:
            )
          ]
        end

        def support_row_detail_features(box:, rows:, default_height:, tone:)
          rows.map.with_index do |row, index|
            options = row.transform_keys(&:to_sym)
            height = options.fetch(:height, default_height)
            center_y = support_relative_position(box, options.fetch(:y), axis: :y)
            inset_x = options.fetch(:inset_x, 42)
            width = options.fetch(:width, box.width - (inset_x * 2))
            rx = options.fetch(:rx, height / 2)

            SolidSupportFeature.new(
              id: options.fetch(:id, "row-detail-#{index + 1}"),
              kind: :rect,
              box: Box.new(
                x: options.fetch(:x, box.x + inset_x),
                y: center_y - (height / 2),
                width:,
                height:,
                rx:
              ),
              tone: options.fetch(:tone, tone),
              rx:
            )
          end
        end

        def support_points(box:, point_inset:, point_radius:, point_specs:, tones:)
          specs = if point_specs
                    point_specs
                  else
                    resolved_point_inset = point_inset || (box.width * 0.32).round
                    [
                      { x: resolved_point_inset, y: :center, radius: point_radius },
                      { x: -resolved_point_inset, y: :center, radius: point_radius }
                    ]
                  end

          specs.map do |spec|
            options = spec.transform_keys(&:to_sym)
            SolidPoint.new(
              point: Point.new(
                x: support_relative_position(box, options.fetch(:x), axis: :x),
                y: support_relative_position(box, options.fetch(:y, :center), axis: :y)
              ),
              radius: options.fetch(:radius, point_radius),
              tone: options.fetch(:tone, tones.fetch(:point))
            )
          end
        end

        def support_relative_position(box, value, axis:)
          case value
          when :center
            axis == :x ? box.center_x : box.center_y
          when Numeric
            if axis == :x
              value.negative? ? box.right + value : box.x + value
            else
              value.negative? ? box.bottom + value : box.y + value
            end
          else
            raise ArgumentError, "Unsupported support relative position: #{value.inspect}"
          end
        end

        def support_cross_detail_features(box:, inset_x:, inset_y:, height:, tone:)
          horizontal_width = box.width - (inset_x * 2)
          vertical_height = box.height - (inset_y * 2)
          rx = height / 2

          [
            SolidSupportFeature.new(
              id: "center-horizontal-detail",
              kind: :rect,
              box: Box.new(x: box.x + inset_x, y: box.center_y - (height / 2), width: horizontal_width, height:, rx:),
              tone:,
              rx:
            ),
            SolidSupportFeature.new(
              id: "center-vertical-detail",
              kind: :rect,
              box: Box.new(x: box.center_x - (height / 2), y: box.y + inset_y, width: height, height: vertical_height, rx:),
              tone:,
              rx:
            )
          ]
        end

        def accessory_half_disc_path(point, radius)
          "M#{point.x} #{point.y - radius}" \
            "A#{radius} #{radius} 0 0 1 #{point.x} #{point.y + radius}" \
            "L#{point.x} #{point.y - radius}Z"
        end

        def accessory_echo_path(point, radius)
          "M#{point.x} #{point.y - radius}" \
            "A#{radius} #{radius} 0 0 1 #{point.x} #{point.y + radius}"
        end

        def accessory_arc_box(point, radius)
          padding = 6

          Box.new(
            x: point.x - padding,
            y: point.y - radius - padding,
            width: radius + (padding * 2),
            height: (radius * 2) + (padding * 2)
          )
        end

        def bar_features(box:, detail:, embouts:, grip:, extensions:, tabs:, features:, tones:)
          [
            *bar_extension_features(box:, extensions:, tone: tones.fetch(:detail)),
            *bar_embout_features(box:, embouts:, tone: tones.fetch(:embout)),
            bar_center_detail_feature(box:, detail:, tone: tones.fetch(:detail)),
            bar_grip_feature(box:, grip:, tone: tones.fetch(:grip)),
            *bar_tab_features(box:, tabs:, tone: tones.fetch(:grip)),
            *features
          ].compact
        end

        def bar_embout_features(box:, embouts:, tone:)
          return [] unless embouts

          options = embouts == true ? {} : embouts.transform_keys(&:to_sym)
          width = options.fetch(:width, FRONT_COFFRE_DEFAULTS.fetch(:cheeks).fetch(:width))
          height = options.fetch(:height, box.height)
          y = options.fetch(:y, box.center_y - (height / 2))
          rx = options.fetch(:rx, 0)
          feature_tone = options.fetch(:tone, tone)

          [
            SolidBarFeature.new(
              id: options.fetch(:left_id, "left-embout"),
              kind: :rect,
              box: Box.new(x: box.x, y:, width:, height:, rx:),
              tone: feature_tone,
              rx:
            ),
            SolidBarFeature.new(
              id: options.fetch(:right_id, "right-embout"),
              kind: :rect,
              box: Box.new(x: box.right - width, y:, width:, height:, rx:),
              tone: feature_tone,
              rx:
            )
          ]
        end

        def bar_extension_features(box:, extensions:, tone:)
          solid_feature_options_list(extensions).map do |options|
            side = options.fetch(:side).to_sym
            height = options.fetch(:height)
            width = options.fetch(:width, box.width)
            x = options.fetch(:x, box.center_x - (width / 2))
            y = options.fetch(:y, side == :top ? box.y - height : box.bottom)
            rx = options.fetch(:rx, 0)

            SolidBarFeature.new(
              id: options.fetch(:id, "#{side}-extension"),
              kind: options.fetch(:kind, side == :top ? :top_rounded_rect : :bottom_rounded_rect),
              box: Box.new(x:, y:, width:, height:, rx:),
              tone: options.fetch(:tone, tone),
              rx:
            )
          end
        end

        def bar_center_detail_feature(box:, detail:, tone:)
          return unless detail

          options = detail == true ? {} : detail.transform_keys(&:to_sym)
          height = options.fetch(:height, 8)
          inset_x = options.fetch(:inset_x, 0)
          width = options.fetch(:width, box.width - (inset_x * 2))

          SolidBarFeature.new(
            id: options.fetch(:id, "center-detail"),
            kind: :rect,
            box: Box.new(
              x: options.fetch(:x, box.x + inset_x),
              y: options.fetch(:y, box.center_y - (height / 2)),
              width:,
              height:,
              rx: options.fetch(:rx, height / 2)
            ),
            tone: options.fetch(:tone, tone),
            rx: options.fetch(:rx, height / 2)
          )
        end

        def bar_grip_feature(box:, grip:, tone:)
          return unless grip

          if grip.is_a?(Box)
            grip_box = grip
            options = {}
          else
            options = grip == true ? {} : grip.transform_keys(&:to_sym)
            grip_box = options[:box]
          end

          unless grip_box
            width = options.fetch(:width)
            height = options.fetch(:height)
            grip_box = Box.new(
              x: options.fetch(:x, box.center_x - (width / 2)),
              y: options.fetch(:y, box.center_y - (height / 2)),
              width:,
              height:,
              rx: options.fetch(:rx, height / 2)
            )
          end

          SolidBarFeature.new(
            id: options.fetch(:id, "grip"),
            kind: :rect,
            box: grip_box,
            tone: options.fetch(:tone, tone),
            rx: options.fetch(:rx, grip_box.rx)
          )
        end

        def bar_tab_features(box:, tabs:, tone:)
          solid_feature_options_list(tabs).flat_map do |options|
            side = options.fetch(:side).to_sym
            width = options.fetch(:width)
            height = options.fetch(:height)
            overlap = options.fetch(:overlap, 0)
            y = options.fetch(:y, side == :top ? box.y - height + overlap : box.bottom - overlap)
            rx = options.fetch(:rx, 0)

            options.fetch(:x_positions).each_with_index.map do |x_position, index|
              SolidBarFeature.new(
                id: "#{options.fetch(:id, "#{side}-tab")}-#{index + 1}",
                kind: :rect,
                box: Box.new(
                  x: x_position - (width / 2),
                  y:,
                  width:,
                  height:,
                  rx:
                ),
                tone: options.fetch(:tone, tone),
                rx:
              )
            end
          end
        end

        def solid_feature_options_list(config)
          case config
          when nil, false
            []
          when Array
            config.map { |options| options.transform_keys(&:to_sym) }
          when Hash
            [config.transform_keys(&:to_sym)]
          else
            raise ArgumentError, "solid feature config must be a Hash or an Array of Hashes"
          end
        end

        def housing_features(box:, opening:, cheeks:, features:, tones:)
          [
            *housing_cheek_features(box:, cheeks:, tone: tones.fetch(:cheek)),
            housing_opening_feature(box:, opening:, tone: tones.fetch(:opening)),
            *features
          ].compact
        end

        def housing_cheek_features(box:, cheeks:, tone:)
          return [] unless cheeks

          options = cheeks.transform_keys(&:to_sym)
          width = options.fetch(:width)
          rx = options.fetch(:rx, 0)
          feature_tone = options.fetch(:tone, tone)

          [
            SolidHousingFeature.new(
              id: "left-cheek",
              kind: :rect,
              box: Box.new(x: box.x, y: box.y, width:, height: box.height, rx:),
              tone: feature_tone,
              rx:
            ),
            SolidHousingFeature.new(
              id: "right-cheek",
              kind: :rect,
              box: Box.new(x: box.right - width, y: box.y, width:, height: box.height, rx:),
              tone: feature_tone,
              rx:
            )
          ]
        end

        def housing_opening_feature(box:, opening:, tone:)
          return unless opening

          options = opening.transform_keys(&:to_sym)
          width = options[:width] ||
                  (options[:inset_x] ? box.width - (options.fetch(:inset_x) * 2) : nil) ||
                  (box.width * options.fetch(:width_ratio, 0.84)).round
          height = options.fetch(:height)
          bottom_gap = options.fetch(:bottom_gap, 0)
          rx = options.fetch(:rx, 0)

          SolidHousingFeature.new(
            id: "opening",
            kind: :top_rounded_rect,
            box: Box.new(
              x: box.center_x - (width / 2),
              y: box.bottom - bottom_gap - height,
              width:,
              height:,
              rx:
            ),
            tone: options.fetch(:tone, tone),
            rx:
          )
        end

        def housing_style_options(defaults, override)
          return nil if override == false

          defaults.merge((override || {}).transform_keys(&:to_sym))
        end
      end
    end
  end
end
