# frozen_string_literal: true

class PublicV2::Ui::SpotlightPanelComponent < ViewComponent::Base
  renders_one :actions
  renders_one :footer

  VARIANTS = %i[soft flashy].freeze
  SIZES = %i[md lg].freeze
  TAGS = %i[article aside div section].freeze

  def initialize(kicker: nil, title: nil, text: nil, id: nil, variant: :soft, size: :md, tag: :section, data: {}, classes: nil)
    @kicker = kicker
    @title = title
    @text = text
    @id = id
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :soft
    @size = SIZES.include?(size.to_sym) ? size.to_sym : :md
    @html_tag = TAGS.include?(tag.to_sym) ? tag.to_sym : :section
    @data = data
    @classes = classes
  end

  private

  attr_reader :kicker, :title, :text, :id, :variant, :size, :html_tag, :data, :classes

  def component_classes
    [
      "pv2-ui-spotlight-panel",
      "pv2-ui-spotlight-panel--#{variant}",
      "pv2-ui-spotlight-panel--#{size}",
      "grid w-full min-w-0",
      classes
    ].compact.join(" ")
  end

  def render_header?
    kicker.present? || title.present? || text.present?
  end

  def render_body?
    content.present?
  end
end
