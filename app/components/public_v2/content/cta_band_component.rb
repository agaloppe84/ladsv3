# frozen_string_literal: true

class PublicV2::Content::CtaBandComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(kicker:, title:, text: nil, action_label:, action_path:, secondary_label: nil, secondary_path: nil, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @action_label = action_label
    @action_path = action_path
    @secondary_label = secondary_label
    @secondary_path = secondary_path
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :action_label, :action_path, :secondary_label, :secondary_path, :classes

  def component_classes
    component_class_names(
      "pv2-public-cta",
      "pv2-ui-cta-band",
      "grid w-full min-w-0 grid-cols-1 gap-4 p-[1.2rem] min-[821px]:grid-cols-[minmax(0,1fr)_auto] min-[821px]:items-center",
      debug_class,
      classes
    )
  end
end
