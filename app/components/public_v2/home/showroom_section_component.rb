# frozen_string_literal: true

class PublicV2::Home::ShowroomSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  FOCUS_ITEMS = [
    { icon: "icons/lucide-waves-horizontal.svg", label: "Toiles", text: "Comparer la texture, le filtrage et la tenue des couleurs." },
    { icon: "icons/lucide-swatch-book.svg", label: "Finitions", text: "Choisir coffre, rails, coloris et détails de pose." }
  ].freeze

  def initialize(home_page:, debug: false)
    @home_page = home_page
    @debug = debug
  end

  private

  attr_reader :home_page

  def focus_items
    FOCUS_ITEMS
  end

  def component_classes
    component_class_names(
      "pv2-home-section pv2-home-warm__showroom pv2-home-showroom-story",
      "grid w-full min-w-0 gap-6",
      debug_class
    )
  end
end
