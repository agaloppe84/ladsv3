# frozen_string_literal: true

class PublicV2::Contact::ShowroomSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def component_classes
    [
      "pv2-contact-showroom pv2-contact-showroom-v2",
      "grid w-full min-w-0 grid-cols-1 items-stretch gap-4 min-[1121px]:grid-cols-[minmax(360px,.62fr)_minmax(0,.82fr)]",
      debug_class
    ].compact.join(" ")
  end
end
