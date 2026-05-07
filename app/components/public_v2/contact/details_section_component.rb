# frozen_string_literal: true

class PublicV2::Contact::DetailsSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  private

  def contact_cards
    PublicV2::ContactInfo.contact_cards
  end

  def map_src
    PublicV2::ContactInfo.map_src
  end

  def component_classes
    [
      "pv2-contact-layout",
      "grid w-full min-w-0 grid-cols-1 items-stretch gap-4 min-[1121px]:grid-cols-[minmax(0,.74fr)_minmax(420px,1fr)]",
      debug_class
    ].compact.join(" ")
  end
end
