# frozen_string_literal: true

class PublicV2::Home::ShowroomSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(debug: false)
    @debug = debug
  end

  private

  def component_classes
    [
      "pv2-home-section pv2-home-warm__showroom",
      "grid w-full min-w-0 grid-cols-1 items-center gap-4 min-[1121px]:grid-cols-[minmax(0,.8fr)_minmax(320px,.7fr)]",
      debug_class
    ].compact.join(" ")
  end
end
