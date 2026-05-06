# frozen_string_literal: true

class PublicV2::Ui::ChoiceTileComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default soft flashy].freeze

  def initialize(kicker:, title:, text: nil, path: nil, active: false, variant: :default, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @path = path
    @active = active
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :default
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :path, :variant, :classes

  def component_classes
    [
      "pv2-ui-choice-tile",
      "pv2-ui-choice-tile--#{variant}",
      ("is-active" if active?),
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def active?
    @active
  end
end
