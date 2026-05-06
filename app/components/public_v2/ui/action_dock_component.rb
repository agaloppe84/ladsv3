# frozen_string_literal: true

class PublicV2::Ui::ActionDockComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft flashy dark].freeze

  def initialize(kicker:, title:, text: nil, primary_label: nil, primary_path: nil, secondary_label: nil, secondary_path: nil, meta: nil, variant: :default, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @primary_label = primary_label
    @primary_path = primary_path
    @secondary_label = secondary_label
    @secondary_path = secondary_path
    @meta = meta
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :default
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :primary_label, :primary_path, :secondary_label, :secondary_path, :meta, :variant, :classes

  def component_classes
    [
      "pv2-ui-action-dock",
      "pv2-ui-action-dock--#{variant}",
      "grid w-full min-w-0 gap-3",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def render_actions?
    primary_label.present? || secondary_label.present?
  end
end
