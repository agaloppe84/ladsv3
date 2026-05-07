# frozen_string_literal: true

class PublicV2::Contact::CtaSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def component_classes
    [
      "pv2-contact-cta-v2",
      "grid w-full min-w-0 grid-cols-1 items-start gap-4 min-[1121px]:grid-cols-[minmax(0,.68fr)_minmax(320px,.48fr)]",
      debug_class
    ].compact.join(" ")
  end
end
