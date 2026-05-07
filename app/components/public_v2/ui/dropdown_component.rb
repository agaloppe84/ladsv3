# frozen_string_literal: true

require "securerandom"

class PublicV2::Ui::DropdownComponent < ViewComponent::Base
  include PublicV2::Debuggable

  renders_one :trigger
  renders_one :panel

  WIDTHS = %i[sm md lg theme].freeze
  ALIGNS = %i[left right].freeze

  def initialize(label:, id: nil, align: :right, width: :md, classes: nil, trigger_classes: nil, panel_classes: nil, data: {})
    @label = label
    @id = id.presence || "pv2-dropdown-#{SecureRandom.hex(4)}"
    @align = ALIGNS.include?(align.to_sym) ? align.to_sym : :right
    @width = WIDTHS.include?(width.to_sym) ? width.to_sym : :md
    @classes = classes
    @trigger_classes = trigger_classes
    @panel_classes = panel_classes
    @data = data
  end

  private

  attr_reader :label, :id, :align, :width, :classes, :trigger_classes, :panel_classes, :data

  def panel_id
    "#{id}-panel"
  end

  def component_classes
    [
      "pv2-ui-dropdown",
      "pv2-ui-dropdown--#{align}",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def trigger_button_classes
    [
      "pv2-ui-dropdown__trigger",
      "inline-flex items-center justify-center",
      trigger_classes
    ].compact.join(" ")
  end

  def menu_classes
    [
      "pv2-ui-dropdown__panel",
      "pv2-ui-dropdown__panel--#{width}",
      "grid min-w-0 gap-3",
      panel_classes
    ].compact.join(" ")
  end

  def component_data
    with_debug_data(data).merge(
      controller: [data[:controller], "dropdown"].compact.join(" "),
      action: [data[:action], "keydown.escape@window->dropdown#close click@window->dropdown#closeOnOutsideClick"].compact.join(" ")
    )
  end
end
