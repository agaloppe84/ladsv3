# frozen_string_literal: true

class PublicV2::Home::ShowroomSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(home_page:, debug: false)
    @home_page = home_page
    @debug = debug
  end

  private

  attr_reader :home_page

  def component_classes
    component_class_names(
      "pv2-home-section pv2-home-warm__showroom",
      "grid w-full min-w-0 grid-cols-1 items-stretch gap-4 min-[1121px]:grid-cols-[minmax(0,.58fr)_minmax(320px,.72fr)]",
      debug_class
    )
  end
end
