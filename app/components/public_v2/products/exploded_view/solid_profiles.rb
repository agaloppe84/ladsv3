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
