# frozen_string_literal: true

class PublicV2::Ui::TrustClusterComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft compact dark].freeze

  def initialize(items:, kicker: nil, title: nil, text: nil, variant: :default, classes: nil, debug: false)
    @items = items
    @kicker = kicker
    @title = title
    @text = text
    @variant = normalize_variant(variant)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :kicker, :title, :text, :variant, :classes

  def component_classes
    [
      "pv2-ui-trust-cluster",
      "pv2-ui-trust-cluster--#{variant}",
      "grid w-full min-w-0 gap-3",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def render_header?
    kicker.present? || title.present? || text.present?
  end

  def normalize_variant(value)
    candidate = value.to_sym
    VARIANTS.include?(candidate) ? candidate : :default
  end
end
