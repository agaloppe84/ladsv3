# frozen_string_literal: true

class PublicV2::Contact::DetailsSectionComponent < ViewComponent::Base
  private

  def contact_cards
    PublicV2::ContactInfo.contact_cards
  end

  def map_src
    PublicV2::ContactInfo.map_src
  end
end
