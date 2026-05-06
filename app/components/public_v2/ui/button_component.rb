# frozen_string_literal: true

class PublicV2::Ui::ButtonComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(label: nil, path: nil, variant: :primary, type: "button", data: {}, method: nil, classes: nil, size: :md, shape: :soft, full_width: false, debug: false)
    @label = label
    @path = path
    @variant = variant
    @type = type
    @data = data
    @method = method
    @classes = classes
    @size = size
    @shape = shape
    @full_width = full_width
    @debug = debug
  end

  private

  attr_reader :label, :path, :variant, :type, :data, :method, :classes, :size, :shape, :full_width

  def component_classes
    [
      "pv2-ui-button",
      "pv2-ui-button--#{variant}",
      "pv2-ui-button--#{size}",
      "pv2-ui-button--#{shape}",
      ("pv2-ui-button--full" if full_width),
      "inline-flex items-center justify-center gap-[0.42rem]",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def link_data
    return with_debug_data(data) unless method

    with_debug_data(data.to_h.merge(turbo_method: method))
  end

  def button_data
    with_debug_data(data)
  end

  def button_content
    label.presence || content
  end
end
