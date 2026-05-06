# frozen_string_literal: true

class PublicV2::Ui::QuoteIntakeComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft compact].freeze

  def initialize(kicker: nil, title:, text: nil, steps: [], primary_label: nil, primary_path: nil, secondary_label: nil, secondary_path: nil, variant: :default, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @steps = steps
    @primary_label = primary_label
    @primary_path = primary_path
    @secondary_label = secondary_label
    @secondary_path = secondary_path
    @variant = normalize_variant(variant)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :steps, :primary_label, :primary_path, :secondary_label, :secondary_path, :variant, :classes

  def component_classes
    [
      "pv2-ui-quote-intake",
      "pv2-ui-quote-intake--#{variant}",
      "grid w-full min-w-0 gap-4",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def render_actions?
    primary_label.present? || secondary_label.present?
  end

  def step_kicker(step, index)
    step[:kicker].presence || Kernel.format("%02d", index + 1)
  end

  def normalize_variant(value)
    candidate = value.to_sym
    VARIANTS.include?(candidate) ? candidate : :default
  end
end
