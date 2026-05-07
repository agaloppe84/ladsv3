# frozen_string_literal: true

class PublicV2::Content::SectionHeaderComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default home].freeze

  def initialize(kicker:, title:, text: nil, level: 2, variant: :default, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @level = level
    @variant = normalize_option(variant, VARIANTS, :default)
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :level, :variant, :classes

  def component_classes
    component_class_names(
      section_header_class,
      "pv2-ui-section-header",
      debug_class,
      classes
    )
  end

  def heading_tag
    "h#{level.to_i.clamp(1, 6)}"
  end

  def intro_classes
    "max-w-[680px]" if variant == :home
  end

  def text_classes
    "max-w-[680px]" if variant == :home
  end

  def section_header_class
    if variant == :home
      "pv2-home-section__head grid w-full min-w-0 gap-[0.55rem]"
    else
      "pv2-ui-section-header--stacked grid w-full min-w-0 grid-cols-1 gap-4 pt-[0.95rem] min-[821px]:grid-cols-[minmax(0,.78fr)_minmax(260px,.7fr)] min-[821px]:items-end"
    end
  end
end
