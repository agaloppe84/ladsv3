# frozen_string_literal: true

class PublicV2::Contact::HeroSectionComponent < ViewComponent::Base
  private

  def contact_info
    PublicV2::ContactInfo
  end
end
