# frozen_string_literal: true

class PublicV2::Contact::DetailsSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def component_classes
    component_class_names(
      "pv2-contact-layout pv2-contact-details-v2",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 min-[1121px]:grid-cols-[minmax(0,.78fr)_minmax(380px,.52fr)]",
      debug_class
    )
  end
end
